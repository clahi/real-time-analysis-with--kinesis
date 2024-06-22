data "archive_file" "consumeLambda" {
  type        = "zip"
  source_file = "${path.module}/consumeLambda.py"
  output_path = "${path.module}/consumeLambda.zip"
}

resource "aws_lambda_function" "consumeKinesisEvents" {
  role             = aws_iam_role.lambdaRole.arn
  filename         = data.archive_file.consumeLambda.output_path
  source_code_hash = data.archive_file.consumeLambda.output_base64sha256
  function_name    = "consumeKinesisEvents"
  runtime          = "python3.9"
  handler          = "consumeLambda.lambda_handler"
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_kinesis_stream.TelemetricsStream.arn
  function_name     = aws_lambda_function.consumeKinesisEvents.arn
  batch_size        = 10
  starting_position = "LATEST"
  depends_on = [ 
    aws_kinesis_stream.TelemetricsStream,
    aws_lambda_function.consumeKinesisEvents,
    aws_iam_role.lambdaRole
   ]
}

resource "aws_lambda_permission" "KinesisPermision" {
  statement_id  = "AllowExecutionFromKinesis"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.consumeKinesisEvents.function_name
  principal     = "kinesis.amazonaws.com"
  source_arn    = aws_kinesis_stream.TelemetricsStream.arn
}