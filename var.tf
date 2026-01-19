variable "ec2_instance_type" {
     type = string
     default = "t2.micro"
}

variable "storage_size" {
    default = 15
    type = number
    description = "This is the storage of the instance"
}

variable "ec2_ami-id" {
    type = number
    default = "12345678"
    description = "This is the ami id use for the instance"
  
}