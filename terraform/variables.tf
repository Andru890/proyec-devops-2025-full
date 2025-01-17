variable "project_name" {
  description = "Proyecto de despliegue"
  type        = string
  default     = "devops-2025"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
}

#Este archivo define las variables que se utilizarán en el proyecto. Las variables permiten parametrizar la configuración de Terraform, facilitando la reutilización y la gestión de diferentes entornos (como dev y prod)


