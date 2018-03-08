# required variables
variable "hostname" {
  description = "name of the machine to create"
  default = "datacloudprod" # update Hostname of the VM
}

variable "environment" {
  description = "name of the machine to create"
  default = "prod" # Tag your environment
}

variable "name_prefix" {
  description = "unique part of the name to give to resources"
  default = "production" # Append this to all resource
}

variable "WorkerCount" {
    type = "string"
    default = "2"
}


variable "ssh_public_key" {
  description = "public key for ssh access"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH/euL/q2G2OHBOzRqbiqmRtIC0Oz8sH8Y0wAEK4uUiVdiUmljQre6ZGpcpfSFeBYCzCBm6RCeDLXxMItRbeEYTw/DhY9qwNtJY3Y1T+RvmtxS3P/i5Nbilkqi2S24swy9qbWxfmckDu4UuobDcbnibvfoLf8M42+f77X6mvh+2eBOh54/TNXeT/JlSb+uOKK5q5C0rUADaTxXkQHZCrg8UkFKKoObkSaYmGlDU+qu1HCK0kLROZJTaU4Z+ESXSx+hEHO7devELQGnhgl5GAI6fs3BVSHz8YjIOVtMhSWMma9Ju/H/db0FwcLgz2SH1lf9+ZCZ3Grae/Fvpxa///fV suriya@railsfactory-suriya" # Change this to your ssh public key 
}

# optional variables
variable "location" {
  description = "region where the resources should exist"
  default     = "westus"
}

variable "vnet_address_space" {
  description = "full address space allowed to the virtual network"
  default     = "10.0.0.0/16"
}

variable "subnet_address_space" {
  description = "the subset of the virtual network for this subnet"
  default     = "10.0.1.0/24"
}

variable "storage_account_type" {
  description = "type of storage account"
  default     = "Standard"
}

variable "vm_size" {
  description = "size of the vm to create"
  default     = "Standard_A0"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "datacloud"
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
  default     = "notused"
}

variable "disable_password_authentication" {
  description = "toggle for password auth (recommended to keep disabled)"
  default     = true
}
