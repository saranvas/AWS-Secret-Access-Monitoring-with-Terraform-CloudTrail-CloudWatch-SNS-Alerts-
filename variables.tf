variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "secret_name"{
    type = string
    default = "TopSecret"
}

variable "env" {
    type= string
    default = "dev"  
}

variable "cloudtrail_name"{
    type = string
    default = "secret-access-trail"
}

variable "notification_email" {
  type = string
  description = "Email address to receive SNS notifications. Must confirm subscription."
}
