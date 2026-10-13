# Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final

Artefatos desta etapa (continuação da Entrega 1, na raiz do repositório — DER e Dicionário de Dados de 9 entidades):

| Arquivo | Conteúdo | Seção do esqueleto oficial |
|---|---|---|
| [`RELATORIO_TECNICO.md`](RELATORIO_TECNICO.md) | Revisão do conceitual, conversão para o lógico, PKs/FKs, normalização (1FN/2FN/3FN), justificativas técnicas, proposta de BI/IA, Uso de IA | Seções 1.1–1.6 e 6 |
| [`modelo_logico.md`](modelo_logico.md) | Tabelas, colunas, tipos, PK/FK, restrições e cardinalidades já convertidas — serve também como o **Dicionário de Dados atualizado** (nível lógico) pedido na Seção 5 do esqueleto; o `Dicionario_de_Dados.html` da raiz continua sendo a referência conceitual da Entrega 1 | Seção 2 |
| [`script.sql`](script.sql) | Script completo: `CREATE DATABASE`/`CREATE TABLE`/constraints, massa de dados fictícia, `SELECT` com `JOIN`, `UPDATE`, `DELETE`, consultas gerenciais e de auditoria | Seções 3 e 4 |
| [`apresentacao_outline.md`](apresentacao_outline.md) | Roteiro/conteúdo original dos slides (texto-base usado para montar o `.pptx` abaixo) | Seção 7 |
| [`apresentacao.pptx`](apresentacao.pptx) | Slides prontos (10), com o DER, fotos da visita, 2 gráficos nativos (faturamento por mês, margem por produto) e anotações do apresentador em cada slide | Seção 7 |

**Pendências do grupo antes de entregar** :
- Rodar `script.sql` em um MySQL/MariaDB real antes da entrega (validado logicamente com dados de teste nesta sessão — ver nota técnica no Relatório — mas não executado em um servidor MySQL de verdade, que não estava disponível neste ambiente).
- Abrir `apresentacao.pptx` no PowerPoint e conferir o visual com atenção: esta sessão não tinha LibreOffice disponível para gerar a prévia das imagens dos slides (QA visual do próprio processo de geração), então o arquivo passou pela validação estrutural (`validate.py`, sem erros) e pela checagem de conteúdo (texto completo, sem placeholder esquecido), mas **não foi visto renderizado** antes de entrar no repositório.
- Ensaiar o tempo da apresentação (10 slides, ~8-10 min sugeridos no roteiro) e decidir quem fala em qual parte.
