# Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final

Artefatos desta etapa (continuação da Entrega 1, na raiz do repositório — DER e Dicionário de Dados de 9 entidades):

| Arquivo | Conteúdo | Seção do esqueleto oficial |
|---|---|---|
| [`RELATORIO_TECNICO.md`](RELATORIO_TECNICO.md) | Revisão do conceitual, conversão para o lógico, PKs/FKs, normalização (1FN/2FN/3FN), justificativas técnicas, proposta de BI/IA, Uso de IA | Seções 1.1–1.6 e 6 |
| [`modelo_logico.md`](modelo_logico.md) | Tabelas, colunas, tipos, PK/FK, restrições e cardinalidades já convertidas — serve também como o **Dicionário de Dados atualizado** (nível lógico) pedido na Seção 5 do esqueleto; o `Dicionario_de_Dados.html` da raiz continua sendo a referência conceitual da Entrega 1 | Seção 2 |
| [`script.sql`](script.sql) | Script completo: `CREATE DATABASE`/`CREATE TABLE`/constraints, massa de dados fictícia, `SELECT` com `JOIN`, `UPDATE`, `DELETE`, consultas gerenciais e de auditoria | Seções 3 e 4 |
| [`apresentacao_outline.md`](apresentacao_outline.md) | Roteiro/conteúdo para os slides da apresentação final (ainda não é o `.pptx`) | Seção 7 |

**Pendências do grupo antes de entregar** (não geráveis por IA — ver "Reflexão crítica" em `RELATORIO_TECNICO.md`):
- Validar a massa de dados e os volumes com a organização real (Osmar, Contrasti).
- Montar os slides de fato (`.pptx`) a partir do roteiro.
- Rodar `script.sql` em um MySQL/MariaDB real antes da entrega (foi validado logicamente com dados de teste nesta sessão, mas não executado em um servidor MySQL de verdade).
