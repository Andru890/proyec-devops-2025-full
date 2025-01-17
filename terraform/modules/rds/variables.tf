variable "project_name" {
  description = "Project"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}