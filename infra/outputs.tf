# Saídas para validação de conformidade e integração

output "dynamodb_table_arn" {
  description = "ARN da tabela de auditoria para fins de perícia digital"
  value       = aws_dynamodb_table.lgpd_audit.arn
}

output "lambda_function_name" {
  description = "Nome da função Lambda que processa os direitos do titular"
  value       = aws_lambda_function.dsr_handler.function_name
}

output "iam_role_arn" {
  description = "ARN da Role IAM para auditoria de permissões (Least Privilege)"
  value       = aws_iam_role.lambda_role.arn
}
