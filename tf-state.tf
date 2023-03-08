terraform {
  backend "s3" {
    bucket = "abc-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
