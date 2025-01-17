output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_ip" {
  value = module.ec2.public_ip
}

//Este archivo define las salidas de Terraform, que son valores que se pueden utilizar fuera de Terraform, por ejemplo, para configurar otros servicios o para mostrar información al usuario. En este caso, se definen las salidas vpc_id y ec2_ip, que contienen la ID de la VPC y la IP pública de la instancia EC2, respectivamente.

#Este archivo define las salidas de Terraform, que son valores que se pueden utilizar fuera de Terraform, por ejemplo, para configurar otros servicios o para mostrar información al usuario. En este caso, se definen las salidas vpc_id, rds_endpoint y ec2_ip, que contienen la ID de la VPC, el endpoint de la base de datos RDS y la IP pública de la instancia EC2, respectivamente.

