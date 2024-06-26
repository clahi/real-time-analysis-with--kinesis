resource "aws_s3_bucket" "myDestiBucket" {
  bucket = "my-dest-bucket-76sdf700"
}

resource "aws_s3_bucket_ownership_controls" "bucketOwnerControlsDesti" {
  bucket = aws_s3_bucket.myDestiBucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "accessBlockDesti" {
  bucket = aws_s3_bucket.myDestiBucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}

resource "aws_s3_bucket_acl" "bucketAclDesti" {
  bucket = aws_s3_bucket.myDestiBucket.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.bucketOwnerControlsDesti,
    aws_s3_bucket_public_access_block.accessBlockDesti
  ]
}