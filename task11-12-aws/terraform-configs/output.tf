output "public_ip" { 
  value = aws_instance.prometheus.public_ip 
  description = "The public IP of the prometheus server" 
} 

output "public_ip_targets" {
  value = [for instance in aws_instance.targets : instance.public_ip]
  description = "The public IP of the target servers"
}
