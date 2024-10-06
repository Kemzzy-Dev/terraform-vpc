terraform {
  backend "s3" {
    bucket = "kemzzy-terraform-backend"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}


resource "aws_s3_bucket" "backend_bucket" {
  bucket = var.backend_bucket_name

}

resource "aws_s3_bucket_versioning" "backend_bucket" {
  bucket = aws_s3_bucket.backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}