terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    mysql = {
      source  = "terraform-providers/mysql"
      version = "~> 1.0"
    }
  }
}


#Este archivo define la versión mínima requerida de Terraform y los proveedores necesarios para el proyecto.