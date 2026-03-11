import json
import boto3
import os
import uuid
import logging
from datetime import datetime, timedelta

# Configuração de infraestrutura e governança
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# O nome da tabela será injetado via Terraform (IaC) posteriormente
TABLE_NAME = os.environ.get('DSR_AUDIT_TABLE', 'lgpd_audit_trail')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    """
    Handler para Automação de Direitos do Titular (DSR) - Art. 18 LGPD.
    Implementa Privacy by Design e Auditoria Imutável.
    """
    protocolo = str(uuid.uuid4())
    agora = datetime.utcnow()
    
    try:
        # 1. Recebimento e Parsing (API Gateway)
        body = json.loads(event.get('body', '{}'))
        email_titular = body.get('email')
        tipo_direito = body.get('tipo_direito', 'CONSULTA') # Ex: ACESSO, EXCLUSAO, PORTABILIDADE
        
        if not email_titular:
            return {
                'statusCode': 400,
                'body': json.dumps({'erro': 'E-mail do titular é obrigatório para validação.'})
            }

        # 2. Privacy by Design: Mascaramento preventivo para Logs do CloudWatch
        # Demonstra cuidado com a exposição de PII em logs operacionais
        email_mascarado = f"{email_titular[:3]}***@{email_titular.split('@')[-1]}"
        logger.info(f"Protocolo: {protocolo} | Solicitação: {tipo_direito} | Titular: {email_mascarado}")

        # 3. Persistência de Auditoria (Audit Trail para Perícia)
        # O TTL define que o log será deletado automaticamente após 2 anos (prazo prescricional comum)
        prazo_prescricional = int((agora + timedelta(days=730)).timestamp())
        
        item_auditoria = {
            'PK': protocolo,
            'SK': 'METADADOS_SOLICITACAO',
            'email_titular': email_titular, # No DynamoDB o dado é cifrado via KMS (at rest)
            'tipo_direito': tipo_direito,
            'data_solicitacao': agora.isoformat(),
            'status': 'PENDENTE',
            'prazo_legal_atendimento': (agora + timedelta(days=15)).isoformat(), # Art. 19 LGPD
            'ttl': prazo_prescricional
        }
        
        table.put_item(Item=item_auditoria)

        # 4. Resposta ao Titular (Conformidade Art. 19)
        return {
            'statusCode': 202,
            'body': json.dumps({
                'mensagem': 'Solicitação recebida com sucesso conforme Art. 18 da LGPD.',
                'protocolo': protocolo,
                'prazo_estimado_dias': 15,
                'instrucoes': 'Você receberá uma confirmação detalhada no e-mail informado.'
            }, ensure_ascii=False)
        }

    except Exception as e:
        logger.error(f"Falha crítica no processamento do protocolo {protocolo}: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'erro': 'Erro interno ao processar requisição de privacidade.'})
        }
