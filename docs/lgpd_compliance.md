# ⚖️ Fundamentação Jurídica e Técnica (Law-as-Code)

Este documento detalha como a arquitetura do projeto **LGPD DSR Automation** atende aos requisitos da Lei 13.709/2018. Como **Arquiteto de Software** e **Bacharel em Direito**, utilizei os princípios de *Privacy by Design* para garantir conformidade nativa.

## 1. Atendimento aos Direitos do Titular (Art. 18)
O sistema foi desenhado para automatizar as requisições previstas no Art. 18 da LGPD, especificamente:
* **Confirmação da existência de tratamento:** Implementada via API Gateway e busca em tabelas de usuários.
* **Acesso aos dados:** Fluxo de extração segura de dados sensíveis.
* **Eliminação de dados:** Lógica de deleção lógica e física (via TTL no DynamoDB) para atender ao "Direito ao Esquecimento".

## 2. Prazos Legais e Resposta (Art. 19)
Conforme o Art. 19, a confirmação deve ser fornecida imediatamente em formato simplificado ou em até 15 dias para declaração clara.
* **Implementação:** A função Lambda (`src/handler.py`) gera um protocolo de atendimento imediato e define o `prazo_legal_dias` na resposta da API, garantindo transparência ao titular.

## 3. Segurança e Sigilo (Art. 46)
A lei exige medidas de segurança capazes de proteger os dados pessoais de acessos não autorizados.
* **Criptografia (Security by Design):** Uso de AWS KMS para encriptar evidências no S3 e logs no DynamoDB.
* **Trilha de Auditoria:** Cada requisição gera um log imutável, essencial para a atuação como **Perito Judicial** em caso de incidentes ou auditorias da ANPD.

## 4. Minimização e Privacidade
* **Mascaramento de Logs:** O código implementa o mascaramento de PII (Personally Identifiable Information) antes da gravação em logs do CloudWatch, garantindo que nem mesmo os administradores do sistema tenham acesso desnecessário aos dados do titular.

---
**Vinícius Marinheiro**
*Arquiteto de Sistemas e Software | Bacharel em Direito | Perito Judicial (TJSP 142228)*
