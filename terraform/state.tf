terraform {
  backend "s3" {
    bucket       = "in-crop-terraform-state-bucket"
    key          = "state"
    region       = "us-east-2"
    use_lockfile = true
  }
}
