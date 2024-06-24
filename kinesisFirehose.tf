data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_test_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_policy" "firehosePolicy" {
  name = "lambdaPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:*"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
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

resource "aws_iam_policy_attachment" "firehosePolicyAttachment" {
  name       = "lambdaRoleAttachment"
  roles      = [aws_iam_role.firehose_role.name]
  policy_arn = aws_iam_policy.firehosePolicy.arn
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "terraform-kinesis-firehose-extended-s3-test-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.myDestiBucket.arn

    buffer_size     = 5
    buffer_interval = 60
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.TelemetricsStream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  tags = {
    Product = "Demo"
  }
}