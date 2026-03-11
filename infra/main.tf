# Configuração do Provedor AWS
provider "aws" {
  region = "us-east-1" # Região padrão para o Free Tier
}

# 1. Tabela de Auditoria (Audit Trail) - Conformidade LGPD
resource "aws_dynamodb_table" "lgpd_audit" {
  name         = "lgpd_audit_trail"
  billing_mode = "PAY_PER_REQUEST" # Foco em FinOps (paga apenas o que usar)
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
    Project     = "LGPD-DSR-Automation"
    Environment = "Dev"
    LawContext  = "Art-18-LGPD"
  }
}

# 2. IAM Role para a Lambda (Segurança por Design)
resource "aws_iam_role" "lambda_role" {
  name = "lgpd_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 3. Política de Acesso ao DynamoDB e Logs
resource "aws_iam_policy" "lambda_policy" {
  name        = "lgpd_lambda_policy"
  description = "Permissões mínimas para gravar auditoria e logs"

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

# 4. Função Lambda (O Coração da Automação)
resource "aws_lambda_function" "dsr_handler" {
  filename      = "lambda_function_payload.zip" # Você precisará zipar a pasta src/
  function_name = "lgpd_dsr_handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.13" # Versão mais recente do Python

  environment {
    variables = {
      DSR_AUDIT_TABLE = aws_dynamodb_table.lgpd_audit.name
    }
  }
}
