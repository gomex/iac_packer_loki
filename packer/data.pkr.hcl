data "hcp-packer-image" "base-image" {
  bucket_name     = "base-image"
  channel         = "production"
  cloud_provider  = "aws"
  region          = "us-east-1"
}