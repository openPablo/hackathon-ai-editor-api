variable "region" {
    default = "eu-west-1"
}

variable "project" {
    default = "vc-pilot-backend"
}

variable "TAG" {
    default = "" 
}
variable "containerPort" {
    default = 8000
}
variable "squad" {}
variable "route53Zone" {}
variable "ecsCluster" {}
variable "lbName" {}
variable "environment" {}
variable "vpcEnvironment" {}
variable "maxContainers" {}
variable "minContainers" {}
variable "lbSGName" {}
variable "promSGName" {}