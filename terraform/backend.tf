terraform {
  backend "s3" {
    bucket       = "REPLACE-WITH-YOUR-UNIQUE-STATE-BUCKET"
    key          = "nationalvote/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
