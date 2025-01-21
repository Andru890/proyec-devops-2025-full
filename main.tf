# Provider Configuration
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Variables
variable "dockerhub_username" {
  type    = string
  default = "andrespistone"
}

variable "dockerhub_image" {
  type    = string
  default = "andrespistone/project-devops-2025:latest"
}

variable "mysql_user" {
  type    = string
  default = "dev_user"
}

variable "mysql_password" {
  type      = string
  sensitive = true
  default   = "dev_password"
}

variable "mysql_database" {
  type    = string
  default = "devops_db"
}

variable "mysql_root_password" {
  type      = string
  sensitive = true
  default   = "root_password"
}

variable "aws_default_region" {
  type    = string
  default = "us-east-1"
}

# Namespace
resource "kubernetes_namespace" "example" {
  metadata {
    name = "example"
  }
}

# Secrets
resource "kubernetes_secret" "mysql_credentials" {
  metadata {
    name      = "mysql-credentials"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  data = {
    username      = var.mysql_user
    password      = var.mysql_password
    database      = var.mysql_database
    root_password = var.mysql_root_password
  }
}

# MySQL Deployment
resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "db"
      }
    }

    template {
      metadata {
        labels = {
          app = "db"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"

          resources {
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          port {
            container_port = 3306
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql_credentials.metadata[0].name
                key  = "root_password"
              }
            }
          }

          env {
            name = "MYSQL_DATABASE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql_credentials.metadata[0].name
                key  = "database"
              }
            }
          }

          env {
            name = "MYSQL_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql_credentials.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql_credentials.metadata[0].name
                key  = "password"
              }
            }
          }

          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }

          liveness_probe {
            exec {
              command = ["mysqladmin", "ping", "-h", "localhost"]
            }
            initial_delay_seconds = 30
            period_seconds       = 10
            timeout_seconds      = 5
            failure_threshold    = 5
          }
        }

        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# MySQL PVC
resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name      = "mysql-pvc"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# MySQL Service
resource "kubernetes_service" "mysql" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    selector = {
      app = "db"
    }
    port {
      port        = 3306
      target_port = 3306
      node_port   = 30307
    }
    type = "NodePort"
  }
}

# Backend Application Deployment
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = "${var.dockerhub_username}/project-devops-2025:latest"
          port {
            container_port = 3000
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# Backend Service
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    selector = {
      app = "backend"
    }
    port {
      port        = 3000
      target_port = 3000
    }
    type = "NodePort"
  }
}

# Localstack Deployment
resource "kubernetes_deployment" "localstack" {
  metadata {
    name      = "localstack"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "localstack"
      }
    }

    template {
      metadata {
        labels = {
          app = "localstack"
        }
      }

      spec {
        container {
          image = "localstack/localstack:latest"
          name  = "localstack"

          resources {
            limits = {
              cpu    = "2000m"
              memory = "4Gi"
            }
            requests = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }

          port {
            container_port = 4566
          }

          env {
            name  = "SERVICES"
            value = "ec2,rds,vpc,s3,iam,lambda"
          }

          env {
            name  = "DEFAULT_REGION"
            value = var.aws_default_region
          }

          env {
            name  = "DEBUG"
            value = "0"
          }

          env {
            name  = "DATA_DIR"
            value = "/var/lib/localstack"
          }

          volume_mount {
            name       = "localstack-data"
            mount_path = "/var/lib/localstack"
          }

          liveness_probe {
            http_get {
              path = "/_localstack/health"
              port = 4566
            }
            initial_delay_seconds = 30
            period_seconds       = 30
            timeout_seconds      = 10
            failure_threshold    = 3
          }
        }

        volume {
          name = "localstack-data"
          empty_dir {}
        }
      }
    }
  }
}

# Localstack Service
resource "kubernetes_service" "localstack" {
  metadata {
    name      = "localstack"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    selector = {
      app = "localstack"
    }
    port {
      port        = 4566
      target_port = 4566
    }
    type = "ClusterIP"
  }
}

# Prometheus Helm Release
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.example.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "15.3.0"

  values = [
    <<-EOT
    server:
      global:
        scrape_interval: 15s
      persistentVolume:
        enabled: true
        size: 10Gi
      service:
        type: NodePort
    alertmanager:
      persistentVolume:
        enabled: true
        size: 2Gi
      service:
        type: NodePort
    EOT
  ]

  depends_on = [
    kubernetes_deployment.backend,
    kubernetes_deployment.mysql,
    kubernetes_deployment.localstack
  ]
}

# Grafana Helm Release
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.example.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "8.3.0"  # Actualiza a una versión disponible

  values = [
    <<-EOT
    adminPassword: "admin"
    persistence:
      enabled: true
      size: 5Gi
    service:
      type: NodePort
    securityContext:
      enabled: false
    podSecurityPolicy:
      enabled: false
    datasources:
      datasources.yaml:
        apiVersion: 1
        datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-server
          access: proxy
          isDefault: true
    dashboardProviders:
      dashboardproviders.yaml:
        apiVersion: 1
        providers:
        - name: 'default'
          orgId: 1
          folder: ''
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards
    dashboards:
      default:
        node-exporter:
          gnetId: 1860
          revision: 23
          datasource: Prometheus
        mysql-overview:
          gnetId: 7362
          revision: 5
          datasource: Prometheus
        kubernetes-cluster:
          gnetId: 6417
          revision: 1
          datasource: Prometheus
    EOT
  ]

  depends_on = [
    helm_release.prometheus
  ]
}