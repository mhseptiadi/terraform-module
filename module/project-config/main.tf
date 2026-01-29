locals {
  septiadi_com_config = {
    dev = {
      project_id      = ""
      service_account = ""
    }
    staging = {
      project_id      = ""
      service_account = ""
    }
    prod = {
      project_id      = "PROJECT_ID"
      service_account  = "PROJECT_NUMBER-compute@developer.gserviceaccount.com"
    }
  }


  project_config = var.project_type == "septiadi.com" ? local.septiadi_com_config : local.septiadi_com_config
}
