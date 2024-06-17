
variable bucket_id {
    type = string
}

variable name {
    type = string
}

variable source_file {
    type = string
}

data "aws_s3_bucket" "selected" {
  bucket = var.bucket_id
}

resource "aws_s3_object" "object" {
  bucket = data.aws_s3_bucket.selected.id
  key    = "plugins/${basename(var.source_file)}"
  source = var.source_file
  etag = filemd5(var.source_file)
}

resource "aws_mskconnect_custom_plugin" "custom_plugin" {
  name        = var.name
  content_type = "ZIP"

  location {
    s3 {
      bucket_arn = data.aws_s3_bucket.selected.arn
      file_key   = aws_s3_object.object.key
    }
  }
}

output "plugin_arn" {
    value = aws_mskconnect_custom_plugin.custom_plugin.arn
}

output "plugin_latest_revision" {
    value = aws_mskconnect_custom_plugin.custom_plugin.latest_revision
}