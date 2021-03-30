# terraform plan時にzipファイルを作成
data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "../src" # main.pyやrequirement.txtが入ってるディレクトリ
  output_path = "../zip/functions.zip" # zipファイルの出力先
}

# zipファイルをアップロードするバケット
resource "google_storage_bucket" "zip_bucket" {
  name          = "zip-bucket-${var.gcp_project_id}"
  location      = "us-west2"
  storage_class = "STANDARD"
  force_destroy = true
}

# 画像をアップロードするバケット
resource "google_storage_bucket" "images_bucket" {
  name          = "image-upload-bucket-${var.gcp_project_id}"
  location      = "us-west2"
  storage_class = "STANDARD"
  force_destroy = true
}

# ローカルのzipファイルをアップロードする
resource "google_storage_bucket_object" "packages" {
  name   = "packages/functions.${data.archive_file.function_archive.output_md5}.zip"
  bucket = google_storage_bucket.zip_bucket.name
  source = data.archive_file.function_archive.output_path
}

resource "google_cloudfunctions_function" "function" {
  name                  = "ocr-test"
  runtime               = "python38"
  source_archive_bucket = google_storage_bucket.zip_bucket.name
  source_archive_object = google_storage_bucket_object.packages.name
  available_memory_mb   = 128
  timeout               = 120
  entry_point           = "uploaded_image"
  event_trigger {
      event_type = "google.storage.object.finalize"
      resource = google_storage_bucket.images_bucket.name
  }

  environment_variables = {
    GCP_PROJECT = var.gcp_project_id
  }
}