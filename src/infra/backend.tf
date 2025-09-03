terraform {
  backend "s3" {
    bucket  = "datascientest-end-to-end-terraform-state-xyz"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
