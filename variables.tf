output "nameservers" {
  value = "${aws_route53_zone.zone.name_servers}"
}

variable "max_availability_zones" {
  default = "2"
}

variable "account_id" {}
variable "region" {}

variable "email" {}

variable "key_name" {}

variable "jenkins_user" {}
variable "jenkins_pass" {}

variable "custom_domain" {}