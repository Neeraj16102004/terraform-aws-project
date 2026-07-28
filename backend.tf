terraform {
  backend "s3" {
    bucket = "terraformbucket1610"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
