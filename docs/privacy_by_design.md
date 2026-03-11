# 🛡️ Memorial Descritivo: Privacy by Design

Este documento descreve as escolhas arquiteturais baseadas no conceito de *Privacy by Design*, garantindo que a proteção de dados não seja um "adicional", mas parte intrínseca do sistema.

## 1. Minimização de Dados (Art. 6º, III - LGPD)
A arquitetura foi desenhada para coletar apenas o estritamente necessário para identificar o titular e processar sua requisição.
* **Implementação:** O formulário de entrada não solicita dados excessivos. Toda a validação interna é feita com identificadores únicos (UUID), reduzindo a exposição de PII (Informações Pessoais Identificáveis) nos microserviços.

## 2. Segurança Progressiva (Art. 46 - LGPD)
Como **Arquiteto de Sistemas**, apliquei camadas de defesa em profundidade:
* **Criptografia de Ponta a Ponta:** Uso de TLS para trânsito e AWS KMS (AES-256) para persistência no DynamoDB e S3.
* **Segregação de Logs:** Logs operacionais (CloudWatch) não contêm dados em texto claro, utilizando máscaras de sanitização implementadas no `handler.py`.

## 3. Gerenciamento do Ciclo de Vida (Direito ao Esquecimento)
O sistema automatiza o descarte de dados, um dos maiores desafios jurídicos atuais.
* **Implementação:** Uso da funcionalidade **TTL (Time to Live)** do DynamoDB para garantir que os logs de requisição sejam deletados automaticamente após o prazo prescricional legal, sem intervenção manual.

## 4. Transparência e Auditoria (Accountability)
Cada ação do sistema gera um rastro imutável, permitindo que eu, como **Perito Judicial**, possa auditar a conformidade do sistema em caso de incidentes.
* **Evidência Digital:** O uso de hashes para garantir a integridade dos logs de auditoria assegura que a trilha de conformidade não foi alterada.

---
**Vinícius Marinheiro**
*Cód. Perito TJSP: 142228*
