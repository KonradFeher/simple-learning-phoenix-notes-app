terraform {
  required_providers {
    porkbun = {
      source  = "cullenmcdermott/porkbun"
      version = "~> 0.3"
    }
  }
}

provider "porkbun" {
  api_key    = var.porkbun_api_key
  secret_key = var.porkbun_secret_key
}

# Root domain
resource "porkbun_dns_record" "root" {
  domain = var.domain
  name   = "@"
  type   = "A"
  content = var.vps_ip
}

# Notes app
resource "porkbun_dns_record" "notes" {
  domain  = var.domain
  name    = "notes"
  type    = "A"
  content = var.vps_ip
}

# Grafana
resource "porkbun_dns_record" "grafana" {
  domain  = var.domain
  name    = "grafana"
  type    = "A"
  content = var.vps_ip
}

# Prometheus
resource "porkbun_dns_record" "prometheus" {
  domain  = var.domain
  name    = "prometheus"
  type    = "A"
  content = var.vps_ip
}
