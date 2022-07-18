locals {
  id = "${replace(var.origin, " ", "-")}"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.ProjectName}-${var.env}-OAI for S3"
}


resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "${var.ProjectName}-${var.env}-security-headers-policy"
  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    # content_security_policy {
    #   content_security_policy = "default-src 'self'"
    #   override = true
    # }
  }
  custom_headers_config {
    items {
      header = "Cache-Control"
      value = "no-store"
      override = true
    }
    items {
      header = "Pragma"
      value = "no-cache"
      override = true
    }
  }
}

resource "aws_cloudfront_distribution" "cloudfront" {
    origin {
        domain_name = aws_s3_bucket.web-frontend.bucket_regional_domain_name
        origin_id = "S3-${local.id}"
        s3_origin_config { 
          origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
        }
    }
    # By default, show index.html file
    default_root_object = "index.html"
    enabled = true
    # If there is a 404, return index.html with a HTTP 200 Response
    custom_error_response {
        error_caching_min_ttl = 10
        error_code = 404
        response_code = 200
        response_page_path = "/index.html"
    }
    custom_error_response {
        error_caching_min_ttl = 10
        error_code = 403
        response_code = 200
        response_page_path = "/index.html"
    }

    web_acl_id = aws_wafv2_web_acl.web_acl_cf_cdn.arn
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-${local.id}"
        response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id
        # Forward all query strings, cookies and headers
        forwarded_values {
            query_string = true
            cookies {
                forward = "none"
                    }
        }
        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 0
        max_ttl = 0
    }

    # Distributes content to US and Europe
    price_class = "PriceClass_100"
    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }
    # SSL certificate for the service.
    # aliases = ["example.com", "www.example.com"]
    viewer_certificate {
        cloudfront_default_certificate = true
        #acm_certificate_arn = 
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method = "sni-only"
    }
    tags = merge(
    local.common_tags,
    {
      "Name"  = "${var.ProjectName}-${var.env}-cdn-distb"
    },
  )
}
