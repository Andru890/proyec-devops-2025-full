provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = var.aws_region

  endpoints {
    ec2  = "http://localhost:4566"
    rds  = "http://localhost:4566"
    s3   = "http://localhost:4566"
    iam  = "http://localhost:4566"
  }

  skip_credentials_validation = true
  skip_metadata_api_check    = true
  skip_requesting_account_id = true
}

#Este archivo configura el proveedor de AWS, incluyendo las credenciales y los endpoints para LocalStack. 

