variable "aws_region"{
    type = string
    default = "us-east-1"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16" 
}

variable "subnet_cidr" {
    type = string
    default = "10.0.1.0/24"
}

variable "pathToSaveSshKey" {
    type = string
    default = "../ssh-key.pem"
    description = "Path where terraform should save generated SSH private key"
}

variable "pairKeyName" {
    type = string
    default = "prometheusTerraform"
}

variable "instance_tag" {
    type = string
    default = "prometheus"
    description = "tag to identificate instance"
}

variable "target_instance_tags" {
  default = [
    "wordpress",
    "docker"
  ]
}

variable "iam_role_name" {
  default = "PrometheusEC2sdConfigRole"
}

variable "policy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

variable "profile_name" {
  default = "prometheus_profile"
}