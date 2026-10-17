terraform {
  backend "s3" {
    bucket       = "capstone-project-voting-app"
    key          = "nationalvote/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
