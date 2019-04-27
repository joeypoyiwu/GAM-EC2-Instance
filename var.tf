#sets variables for access_key and secret_key

variable "access_key" {}
variable "secret_key" {}
variable "region" {
#enter your AWS region
  default = ""
}
variable "availability_zone" {
#enter your AWS AZ
  default = ""
}
variable "ami_id" {}
variable "ami_name" {}
variable "ami_key_pair_name" {}
