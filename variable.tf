
variable "subnet" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "db_instance" {
    default = "db.t3.micro"
}

# variable "availability_zone" {
#   type = list(string)
# }

variable "public_cidrs" {
}
variable "private_cidrs" {
}
