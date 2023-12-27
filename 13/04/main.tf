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


resource "yandex_vpc_network" "mynet" {
  name = "mynet"
}

resource "yandex_vpc_security_group" "mysql-sg" {
  name       = "mysql-sg"
  network_id = yandex_vpc_network.mynet.id

  ingress {
    description    = "MySQL"
    port           = 3306
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "yandex_vpc_subnet" "mysubnet-a" {
  name             = var.mysubnet-a.name
  zone             = var.mysubnet-a.zone
  network_id       = yandex_vpc_network.mynet.id
  v4_cidr_blocks   = [var.mysubnet-a.v4_cidr_blocks]
}

resource "yandex_vpc_subnet" "mysubnet-b" {
  name             = var.mysubnet-b.name
  zone             = var.mysubnet-b.zone
  network_id       = yandex_vpc_network.mynet.id
  v4_cidr_blocks   = [var.mysubnet-b.v4_cidr_blocks]
}

resource "yandex_vpc_subnet" "mysubnet-c" {
  name             = var.mysubnet-c.name
  zone             = var.mysubnet-c.zone
  network_id       = yandex_vpc_network.mynet.id
  v4_cidr_blocks   = [var.mysubnet-c.v4_cidr_blocks]
}



resource "yandex_mdb_mysql_cluster" "my-mysql-3" {
  name                = var.mysql.name
  environment         = var.mysql.environment
  network_id          = yandex_vpc_network.mynet.id
  version             = var.mysql.version
  security_group_ids  = [ yandex_vpc_security_group.mysql-sg.id ]
  deletion_protection = true
  resources {
    resource_preset_id = var.mysql.resource_preset_id
    disk_type_id       = var.mysql.disk_type_id
    disk_size          = var.mysql.disk_size
  }

  host {
    zone             = yandex_vpc_subnet.mysubnet-a.zone
    subnet_id        = yandex_vpc_subnet.mysubnet-a.id
    assign_public_ip = false
  }

  host {
    zone             = yandex_vpc_subnet.mysubnet-b.zone
    subnet_id        = yandex_vpc_subnet.mysubnet-b.id
    assign_public_ip = false
    backup_priority  = 10
  }

  host {
    zone             = yandex_vpc_subnet.mysubnet-c.zone
    subnet_id        = yandex_vpc_subnet.mysubnet-c.id
    assign_public_ip = false
  }

  backup_window_start {
    hours = var.mysql.back_hours
    minutes = var.mysql.back_minutes
  }
  maintenance_window {
    type = var.mysql.maint_window_type
  }
}

resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.my-mysql-3.id
  name       = var.mysql.db_name
}

resource "yandex_mdb_mysql_user" "user1" {
  cluster_id = yandex_mdb_mysql_cluster.my-mysql-3.id
  name       = var.db_sa_name
  password   = var.db_sa_pass
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}




resource "yandex_kubernetes_cluster" "k8s-regional" {
  name = "k8s-regional"
  network_id = yandex_vpc_network.k8s-net.id
  master {
    public_ip = true
    regional {
      region = var.k8s_node_group.region
      location {
        zone      = yandex_vpc_subnet.k8s-subnet-a.zone
        subnet_id = yandex_vpc_subnet.k8s-subnet-a.id
      }
      location {
        zone      = yandex_vpc_subnet.k8s-subnet-b.zone
        subnet_id = yandex_vpc_subnet.k8s-subnet-b.id
      }
      location {
        zone      = yandex_vpc_subnet.k8s-subnet-c.zone
        subnet_id = yandex_vpc_subnet.k8s-subnet-c.id
      }
    }
    security_group_ids = ["${yandex_vpc_security_group.regional-k8s-sg.id}", "${yandex_vpc_security_group.k8s-master-whitelist.id}"]
  }
  service_account_id      = yandex_iam_service_account.my-regional-account.id
  node_service_account_id = yandex_iam_service_account.my-regional-account.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_vpc_network" "k8s-net" {
  name = "k8s-net"
}

resource "yandex_vpc_subnet" "k8s-subnet-a" {
  name = "k8s-subnet-a"
  v4_cidr_blocks = [var.k8s-subnet-a.v4_cidr_blocks]
  zone           = var.k8s-subnet-a.zone
  network_id     = yandex_vpc_network.k8s-net.id
}

resource "yandex_vpc_subnet" "k8s-subnet-b" {
  name = "k8s-subnet-b"
  v4_cidr_blocks = [var.k8s-subnet-b.v4_cidr_blocks]
  zone           = var.k8s-subnet-b.zone
  network_id     = yandex_vpc_network.k8s-net.id
}

resource "yandex_vpc_subnet" "k8s-subnet-c" {
  name = "k8s-subnet-c"
  v4_cidr_blocks = [var.k8s-subnet-c.v4_cidr_blocks]
  zone           = var.k8s-subnet-c.zone
  network_id     = yandex_vpc_network.k8s-net.id
}

resource "yandex_iam_service_account" "my-regional-account" {
  name        = "regional-k8s-account"
  description = "K8S regional service account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  # Сервисному аккаунту назначается роль "kms.keys.encrypterDecrypter".
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ Yandex Key Management Service для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_vpc_security_group" "regional-k8s-sg" {
  name        = "regional-k8s-sg"
  description = "Правила группы обеспечивают базовую работоспособность кластера Managed Service for Kubernetes. Примените ее к кластеру и группам узлов."
  network_id  = yandex_vpc_network.k8s-net.id
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks    = concat(yandex_vpc_subnet.k8s-subnet-a.v4_cidr_blocks, yandex_vpc_subnet.k8s-subnet-b.v4_cidr_blocks, yandex_vpc_subnet.k8s-subnet-c.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}
resource "yandex_vpc_security_group" "k8s-master-whitelist" {
  name        = "k8s-master-whitelist"
  description = "Правила группы разрешают доступ к API Kubernetes из интернета. Примените правила только к кластеру."
  network_id  = yandex_vpc_network.k8s-net.id

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 6443 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 443 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}
resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-regional.id}"
  name        = var.k8s_node_group.name
  description = var.k8s_node_group.name
  version     = var.k8s_node_group.version


  instance_template {
    platform_id = var.vm_resources.platform_id
    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.k8s-subnet-a.id}"]
      security_group_ids = ["${yandex_vpc_security_group.regional-k8s-sg.id}"]
    }

    resources {
      memory = var.vm_resources.memory
      cores  = var.vm_resources.cores
      core_fraction = var.vm_resources.core_fraction

    }

    boot_disk {
      type = var.vm_resources.disk_type
      size = var.vm_resources.disk_size
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = var.k8s_node_group.container_runtime
    }
  }

  scale_policy {
    auto_scale {
      min = var.k8s_node_group.min
      max = var.k8s_node_group.max
      initial = var.k8s_node_group.min
    }
  }

  allocation_policy {

    location {

      zone = var.k8s-subnet-a.zone
     }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}