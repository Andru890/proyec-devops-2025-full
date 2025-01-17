// Elimina todo el bloque de configuración de RDS
// resource "aws_db_instance" "main" {
//   identifier        = "${var.project_name}-db"
//   engine            = "mysql"
//   engine_version    = "5.7"
//   instance_class    = "db.t3.micro"
//   allocated_storage = 20
  
//   username = var.db_username
//   password = var.db_password

//   skip_final_snapshot = true

//   tags = {
//     Environment = var.environment
//   }
// }

// Elimina el bloque de salida que hace referencia al endpoint de la base de datos
// output "db_endpoint" {
//   value = aws_db_instance.main.endpoint
// }