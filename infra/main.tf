# Configuração do Provedor AWS utilizando variáveis
provider "aws" {
  region = var.aws_region
}

# 1. Tabela de Auditoria (Audit Trail) - Conformidade LGPD
resource "aws_dynamodb_table" "lgpd_audit" {
  name         = var.audit_table_name
  billing_mode = "PAY_PER_REQUEST" 
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  # Implementação do Direito ao Esquecimento via TTL
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = var.audit_table_name
    Project     = var.project_name
    Environment = "Dev"
    LawContext  = "Art-18-LGPD"
  }
}

# 2. IAM Role para a Lambda (Segurança por Design)
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 3. Política de Acesso (Princípio do Menor Privilégio)
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.project_name}-lambda-policy"
  description = "Permissões restritas para gravação de auditoria LGPD"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem"]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.lgpd_audit.arn
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# 4. Função Lambda (Law-as-Code)
resource "aws_lambda_function" "dsr_handler" {
  filename      = "lambda_function_payload.zip"
  function_name = "${var.project_name}-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.13"

  environment {
    variables = {
      DSR_AUDIT_TABLE = aws_dynamodb_table.lgpd_audit.name
    }
  }
}
