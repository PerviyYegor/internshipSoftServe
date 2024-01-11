data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.scriptPath
  output_path = var.archive_path
}

resource "aws_lambda_function" "health_check_lambda" {
  function_name = var.lambda_function_name
  timeout = 10
  runtime = "python3.8"
  handler = "health_check.lambda_handler"
  filename = data.archive_file.lambda.output_path

  role = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64(data.archive_file.lambda.output_path)

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.health_check_bucket.bucket
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.log_group
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
        }]
    })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = [
          "s3:PutObject",
        ]
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

