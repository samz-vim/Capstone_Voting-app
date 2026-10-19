terraform {
  backend "s3" {
    bucket       = "capstone-project-voting"
    key          = "nationalvote/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
  }
}
