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
    default = "dockerTerraform"
}

variable "instance_tag" {
    type = string
    default = "docker"
    description = "tag to identificate instance"
}