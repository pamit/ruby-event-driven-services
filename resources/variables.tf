variable "auth0_domain" {
  type = string
}

variable "auth0_audience" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "bucket_name" {
  type    = string
}

variable "sns_test_email" {
  type    = string
  default = ""
}
