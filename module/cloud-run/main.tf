resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.location

  deletion_protection = false
  
  invoker_iam_disabled = var.public_access

  ingress = var.ingress

  labels = var.labels

  template {
    labels = var.template_labels

    dynamic "scaling" {
      for_each = var.max_instance_count != null ? [1] : []
      content {
        max_instance_count = var.max_instance_count
      }
    }

    service_account         = var.service_account
    timeout                 = var.timeout
    execution_environment   = var.execution_environment
    session_affinity        = var.session_affinity

    dynamic "volumes" {
      for_each = var.volumes
      content {
        name = volumes.value.name
        dynamic "gcs" {
          for_each = volumes.value.gcs != null ? [volumes.value.gcs] : []
          content {
            bucket    = gcs.value.bucket
            read_only = gcs.value.read_only
          }
        }
      }
    }

    containers {
      image = var.image

      command = var.container_command 
      args    = var.container_args

      dynamic "ports" {
        for_each = var.container_port != null ? [1] : []
        content {
          container_port = var.container_port
        }
      }

      resources {
        cpu_idle = true
        startup_cpu_boost  = var.startup_cpu_boost

        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      dynamic "volume_mounts" {
        for_each = var.volume_mounts
        content {
          name       = volume_mounts.value.name
          mount_path = volume_mounts.value.mount_path
        }
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      dynamic "env" {
        for_each = var.secrets
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = env.value.secret_name
              version = env.value.version
            }
          }
        }
      }
    }
  }

  lifecycle {
    prevent_destroy = true
    
    ignore_changes = [
      # template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count    = var.public_access ? 1 : 0
  name     = google_cloud_run_v2_service.default.name
  location = google_cloud_run_v2_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
