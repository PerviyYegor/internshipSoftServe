data "aws_vpc" "default" {
  default = true
} 

resource "aws_default_subnet" "main" {
  availability_zone = "${var.aws_region}a"
}

