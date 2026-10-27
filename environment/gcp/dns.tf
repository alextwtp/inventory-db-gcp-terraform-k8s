# 1. Establish GCP Cloud DNS Managed Zone
resource "google_dns_managed_zone" "primary_zone" {
  name        = "my-domain-zone"
  dns_name    = "alextwtp.online."  # Replace with your domain (remember to add the trailing dot .)
  description = "Managed DNS zone for Cloud Run"
  project     = var.gcp_project_id
}

# 2. Configure Cloud Run Domain Mapping
resource "google_cloud_run_domain_mapping" "custom_domain" {
  location = var.gcp_region
  name     = "api.alextwtp.online"   # Replace with your full subdomain
  project  = var.gcp_project_id

  metadata {
    namespace = var.gcp_project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.default.name # Replace with the Cloud Run resource name in main.tf
  }
}

# 3. Write pointer records in Cloud DNS
resource "google_dns_record_set" "cloud_run_record" {
  name = "${google_cloud_run_domain_mapping.custom_domain.name}."
# name         = google_cloud_run_domain_mapping.custom_domain.name
  type         = google_cloud_run_domain_mapping.custom_domain.status[0].resource_records[0].type
  ttl          = 300
  managed_zone = google_dns_managed_zone.primary_zone.name
  project      = var.gcp_project_id

  rrdatas = [
    google_cloud_run_domain_mapping.custom_domain.status[0].resource_records[0].rrdata
  ]
}

# 4. Print 4 NS records
output "gcp_dns_nameservers" {
  description = "Please paste these 4 NS records into Namecheap Custom DNS"
  value       = google_dns_managed_zone.primary_zone.name_servers
}