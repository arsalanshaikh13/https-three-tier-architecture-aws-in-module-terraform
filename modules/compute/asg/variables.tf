
variable "ami_type_name" {
  type        = string
  description = "ami_type_name variable"
}

variable "project_name" {
  type        = string
  description = "project_name variable"
}

variable "frontend_instance_type" {
  type        = string
  description = "cpu variable"
}
variable "backend_instance_type" {
  type        = string
  description = "cpu variable"
}

variable "client_key_name" {
  type        = string
  description = "client_key_name variable"
}

variable "internal_alb_dns_name" {
  type        = string
  description = "internal_alb_dns_name variable"
}

variable "bucket_name" {
  type        = string
  description = "bucket_name variable"
}

variable "ssh_username" {
  type        = string
  description = "ssh_username variable"
}

variable "client_sg_id" {
  type        = string
  description = "client_sg_id variable"
}

variable "s3_ssm_cw_instance_profile_name" {
  type        = string
  description = "s3_ssm_cw_instance_profile_name variable"
}

variable "frontend_volume_type" {
  type        = string
  description = "frontend_volume_type variable"
}

variable "backend_volume_size" {
  type        = number
  description = "backend_volume_size variable"
}

variable "environment" {
  type        = string
  description = "environment variable"
}

variable "server_key_name" {
  type        = string
  description = "server_key_name variable"
}

variable "server_sg_id" {
  type        = string
  description = "server_sg_id variable"
}

variable "db_dns_address" {
  type        = string
  description = "db_dns_address variable"
}

variable "db_username" {
  type        = string
  description = "db_username variable"
}

variable "db_password" {
  type        = string
  description = "db_password variable"
}

variable "db_name" {
  type        = string
  description = "db_name variable"
}

variable "db_secret_name" {
  type        = string
  description = "db_secret_name variable"
}

variable "region" {
  type        = string
  description = "region variable"
}

variable "backend_volume_type" {
  type        = string
  description = "backend_volume_type variable"
}

variable "max_size" {
  type        = number
  description = "max_size variable"
}

variable "min_size" {
  type        = number
  description = "min_size variable"
}

variable "desired_cap" {
  type        = number
  description = "desired_cap variable"
}

variable "asg_health_check_type" {
  type        = string
  description = "asg_health_check_type variable"
}

variable "pri_sub_3a_id" {
  type        = string
  description = "pri_sub_3a_id variable"
}

variable "pri_sub_4b_id" {
  type        = string
  description = "pri_sub_4b_id variable"
}

variable "tg_arn" {
  type        = string
  description = "tg_arn variable"
}


variable "pri_sub_5a_id" {
  type        = string
  description = "pri_sub_5a_id variable"
}

variable "pri_sub_6b_id" {
  type        = string
  description = "pri_sub_6b_id variable"
}

variable "internal_tg_arn" {
  type        = string
  description = "internal_tg_arn variable"
}


