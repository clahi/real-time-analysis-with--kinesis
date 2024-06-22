resource "aws_iam_role" "lambdaRole" {
  name = "lambdaRole"
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "sts:AssumeRole"
        ]
        Principal : {
          Service : [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_policy" "mylambdaPolicy" {
  name = "mylambdaPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*",
        "Effect" : "Allow",
        "Sid" : "CloudWatchLogsAccess"
      },
      {
        "Action" : [
          "kinesis:*"
        ],
        "Resource" : "*",
        "Effect" : "Allow",
        "Sid" : "KinesisAccess"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambdaRoleAttachment" {
  name       = "lambdaRoleAttachment"
  roles      = [aws_iam_role.lambdaRole.name]
  policy_arn = aws_iam_policy.mylambdaPolicy.arn
}

data "archive_file" "sourceLambdaFile" {
  type        = "zip"
  source_file = "${path.module}/sourceLambda.py"
  output_path = "${path.module}/sourceLambda.zip"
}

resource "aws_lambda_function" "sourceLambda" {
  role             = aws_iam_role.lambdaRole.arn
  filename         = data.archive_file.sourceLambdaFile.output_path
  source_code_hash = data.archive_file.sourceLambdaFile.output_base64sha256
  function_name    = "sourceLambda"
  runtime          = "python3.9"
  handler          = "sourceLambda.lambda_handler"
  timeout = 30
}