resource "aws_kinesis_stream" "TelemetricsStream" {
  name = "TelemetricsStream"
  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}