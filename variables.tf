
variable "zone_id" {
    default = "Z04042331YAVAJS5WAC3G"
}

variable "domain_name" {
    default = "lakshman.site"
}

variable "instances" {
  type        = map
  default     = {
    Ansible = "t3.small"
    weserver = "t3.micro"    
  }
}