variable "aws_region"{
    type = string
    default = "us-east-1"
}

variable "scriptPath"{
    type = string
    default = "../health_check.py"
}

variable "archive_path"{
    type = string
    default = "./files/health_check.zip"
}

variable "trigger_timer"{
    type = string
    default = "3"
}

variable "lambda_function_name" {
   type = string
    default = "healthCheckLambda"
}

variable "bucket_name" {
    type = string
    default = "status-check-bucket"
}