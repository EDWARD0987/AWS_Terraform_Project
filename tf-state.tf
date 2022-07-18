terraform {
  backend "s3" {
    bucket = "abc-bucket"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}