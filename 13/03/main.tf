terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
}


resource "yandex_iam_service_account" "sa" {
  name = var.sa_name
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}
// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Создание симметричного ключа
resource "yandex_kms_symmetric_key" "key-a" {
  name              = "example-symetric-key"
  description       = "description for key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}



// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "bucket" {
  depends_on = [yandex_cm_certificate.le-certificate,yandex_kms_symmetric_key.key-a]
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket.name
  max_size   = var.bucket.max_size
  default_storage_class = var.bucket.storage_class
  anonymous_access_flags {
    read = true
    list = false
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
   https {
    certificate_id = yandex_cm_certificate.le-certificate.id
  }
// Шифорвание содержимого бакета
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

//Загружаем файлы
resource "yandex_storage_object" "index-html" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.bucket.id
  key        = var.bucket.index_html
  source     = var.bucket.index_html
}

resource "yandex_storage_object" "error-html" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.bucket.id
  key        = var.bucket.error_html
  source     = var.bucket.error_html
}


resource "yandex_dns_zone" "zone1" {
  name        = var.dns.name
  description = var.dns.description
  zone        = var.dns.zone
  public      = true
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "@"
  type    = "CNAME"
  ttl     = 200
  data    = ["mkv.banksgb.ru.website.yandexcloud.net."]
}


resource "yandex_cm_certificate" "le-certificate" {
  name    = var.dns.name
  domains = [var.bucket.name]

  managed {
  challenge_type = "DNS_CNAME"
  }
}

resource "yandex_dns_recordset" "validation-record" {
  zone_id = yandex_dns_zone.zone1.id
  name    = yandex_cm_certificate.le-certificate.challenges[0].dns_name
  type    = yandex_cm_certificate.le-certificate.challenges[0].dns_type
  data    = [yandex_cm_certificate.le-certificate.challenges[0].dns_value]
  ttl     = 600
}

data "yandex_cm_certificate" "example" {
  depends_on      = [yandex_dns_recordset.validation-record]
  certificate_id  = yandex_cm_certificate.le-certificate.id
  wait_validation = true
}

# Use data.yandex_cm_certificate.example.id to get validated certificate

output "cert-id" {
  description = "Certificate ID"
  value       = data.yandex_cm_certificate.example.id
}





