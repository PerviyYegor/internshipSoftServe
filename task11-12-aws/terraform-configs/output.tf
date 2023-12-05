output "public_ip" { 
  value = aws_instance.prometheus.public_ip 
  description = "The public IP of the prometheus server" 
} 