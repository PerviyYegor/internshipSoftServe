output "public_ip" { 
  value = aws_instance.ec_instance.public_ip 
  description = "The public IP of the wordpress server" 
} 