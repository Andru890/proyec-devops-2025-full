resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"  
  instance_type = "t2.micro"

  tags = {
    Name        = "${var.project_name}-app"
    Environment = var.environment
  }
}

output "public_ip" {
  value = aws_instance.app.public_ip
}


