resource "aws_cloudwatch_event_rule" "every_n_minutes" {
    name = "every-${var.trigger_timer}-minutes"
    description = "Fires every ${var.trigger_timer} minutes"
    schedule_expression = "rate(${var.trigger_timer} minutes)"
}

resource "aws_cloudwatch_event_target" "check_ec2_every_n_minutes" {
    rule = aws_cloudwatch_event_rule.every_n_minutes.name
    target_id = aws_lambda_function.health_check_lambda.id
    arn = aws_lambda_function.health_check_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.health_check_lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_n_minutes.arn
}