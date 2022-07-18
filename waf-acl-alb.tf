
resource "aws_wafv2_web_acl" "web_acl_alb_app" {
  name  = "web_acl_alb_app_${var.ProjectName}_${var.env}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # rule {
  #   name     = "RequestURLValidation"
  #   priority = 1

  #   action {
  #     block {}
  #   }

  #   statement {
  #     not_statement {
  #       statement {
  #         byte_match_statement{
  #           field_to_match {
  #             single_header {
  #               name = "host"
  #             }
  #           }
  #           positional_constraint = "EXACTLY"
  #           search_string = "${var.web_url}"
  #           text_transformation {
  #             priority = 0
  #             type = "NONE"
  #           }
  #         }
  #       }
  #     }
  #   }

  #   visibility_config {
  #       cloudwatch_metrics_enabled = true
  #       metric_name                = "Invalid-RequestURL"
  #       sampled_requests_enabled   = true
  #   }
  # }


  visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "web_acl_alb_app_${var.ProjectName}_${var.env}"
        sampled_requests_enabled   = false
  }
}

//Associate WAF web acl to the ALB APP
resource "aws_wafv2_web_acl_association" "web_acl_association_alb_app" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl_alb_app.arn
}