variable "aws_region" {
  description = "Região da AWS para deploy dos recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para fins de tag e organização"
  type        = string
  default     = "lgpd-dsr-automation"
}

variable "audit_table_name" {
  description = "Nome da tabela no DynamoDB"
  type        = string
  default     = "lgpd_audit_trail"
}
