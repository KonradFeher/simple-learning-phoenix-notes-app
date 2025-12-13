variable "porkbun_api_key" {
  type      = string
  sensitive = true
}

variable "porkbun_secret_key" {
  type      = string
  sensitive = true
}

variable "domain" {
  type = string
}

variable "vps_ip" {
  type = string
}
