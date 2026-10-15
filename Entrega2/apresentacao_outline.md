# Roteiro — Apresentação Corporativa Final

> Texto-base usado para montar `apresentacao.pptx` (12 slides). **v2 (15/10/2026)** — atualizado para o modelo de 17 entidades, em resposta à avaliação do professor na [issue #1](https://github.com/matheusmontagner8/Modelagem-de-Dados/issues/1). O texto abaixo é para a fala de quem apresenta, não para copiar no slide.

Tempo sugerido: ~10-12 min de pitch + perguntas (cresceu ~2 min em relação à v1, por causa dos dois slides novos de produção/financeiro).

---

### 1. Contextualização do problema (slide 2)
**No slide:** nome da empresa, foto da fachada/oficina, 4 bullets curtos.
**Fala:** Contrasti Bolsas e Acessórios é uma indústria e comércio de bolsas e acessórios de couro (São Paulo/SP). O controle de insumos, ficha técnica/custo de produto, produção e vendas é hoje descentralizado/manual (Seção 1 do README) — sem rastreabilidade de insumo por fornecedor, sem cálculo padronizado de custo, sem visão unificada entre produção, vendas e financeiro.

### 2. Apresentação da solução (slide 3)
**No slide:** o DER de **17 entidades** (`Diagrama/Diagrama.png`), reduzido/legível.
**Fala:** Um banco de dados relacional que cobre o fluxo completo: Compras → Produção → Vendas → Financeiro. Esta é a versão **corrigida** do modelo — a avaliação formal do professor (issue #1) apontou lacunas estruturais na Entrega 1, e o DER foi reconstruído: cardinalidade mínima e máxima em toda relação, nenhuma FK no diagrama, e as entidades de produção/financeiro que faltavam.

### 3. Correção aplicada (slide 4) — **novo**
**No slide:** tabela de 2 colunas (apontamento do professor × correção aplicada) + a evidência concreta de dois fornecedores para o mesmo insumo.
**Fala:** Este é o slide mais importante da defesa. Percorrer as 4 linhas da tabela uma a uma. Fechar com a evidência de dados: rodar ao vivo a consulta 5.4 do `script.sql`, que mostra a Bolsa Tote Caramelo usando couro de dois fornecedores diferentes — prova concreta de que a correção funciona, não só no papel.

### 4. Defesa do modelo lógico (slides 5-6) — **dividido em 2 por causa das 17 tabelas**
**No slide:** tabela de PK/FK — slide 5 cobre o núcleo de compras/vendas (9 tabelas), slide 6 cobre produção/financeiro (8 tabelas novas).
**Fala — pontos para defender se o professor perguntar:**
- Por que `ficha_tecnica` trocou a PK composta (produto_id+insumo_id, que tinha FK como identificador) por uma chave própria (`id_ficha`).
- Por que `insumo` não tem mais FK direta para `fornecedor` — a origem de cada recebimento agora vive em `lote_insumo`.
- Por que `execucao_etapa` é uma associativa de três vias (ordem de produção × etapa × artesão/facção) — é o que sustenta o pagamento por etapa (RF15).
- Por que `pedido.vl_total` e `insumo.qt_estoque_atual` são denormalizações **controladas** (não um erro) — e como o script garante que fiquem consistentes.

### 5. Demonstração da implementação (SQL rodando) (slide 7, ao vivo)
**Roteiro de demo sugerido:**
1. Rodar `script.sql` do zero (banco vazio, 17 `CREATE TABLE`) — mostrar que não dá erro.
2. Mostrar o `CREATE TABLE lote_insumo` no slide (a tabela que resolve a correção do item 3).
3. Mostrar a massa de dados carregada (`SELECT * FROM ordem_producao;` ou `execucao_etapa`).

### 6. Demonstração de consultas (gerenciais/auditoria) (slide 8, "menu" + ao vivo)
**Rodar ao vivo, nesta ordem (todas já prontas no `script.sql`, Seções 5, 8 e 9):**
- Gerencial: faturamento por mês (8.1), margem por produto (8.3), comissão por vendedor (5.7), aproveitamento de corte por artesão (8.6).
- Auditoria: checagem da especialização TD (9.4) e, se der tempo, fornecedor sem lote (9.6) — ambas vêm vazias/com o caso esperado, provando consistência.

### 7. Margem por produto (slide 9)
**No slide:** gráfico de barras já pronto no `.pptx`, com os valores reais do script.

### 8. Potencial para BI e IA (slide 10)
**No slide:** 4 KPIs (faturamento mensal, margem por categoria, comissão por vendedor/canal, aging de contas a pagar/receber — os dois últimos são novos nesta versão).
**Fala:** mencionar o paralelo com esquema estrela, agora com dois processos de negócio representados (vendas e produção), e 1-2 aplicações de IA (previsão de demanda sazonal; previsão de aproveitamento de corte por profissional, a partir do histórico de `execucao_etapa`).

### 9. Benefícios diretos para a tomada de decisão (slide 11, fechamento)
**No slide:** 3 números-chave (17 tabelas, 76 pedidos, R$ 87 mil) + 3 bullets de benefício.

### 10. Perguntas (slide 12)
**No slide:** 3 perguntas já respondidas, incluindo a que o próprio grupo havia previsto na v1 deste roteiro ("cadê ordem de produção, financeiro?") — e que acabou sendo exatamente o que o professor apontou.

---

### Perguntas que o professor provavelmente vai fazer (preparar resposta curta)
- "Por que a FK direta FORNECEDOR–INSUMO foi removida?" → contradizia a rastreabilidade por lote; `LOTE_INSUMO` resolve, com evidência concreta nos dados (ver slide 4).
- "Por que `ficha_tecnica` não usa mais a chave composta?" → FK como identificador era um agravante apontado na avaliação; `id_ficha` + `UNIQUE(produto_id, insumo_id)` mantém a mesma regra de negócio sem esse problema.
- "Essa massa de dados é real?" → não, é fictícia por exigência da própria atividade (privacidade); está documentado na Seção 2 do Relatório Técnico (Uso de IA).
- "O `apresentacao.pptx` já reflete tudo isso?" → sim, nesta rodada de correção; `script.sql` e `modelo_logico.md` foram testados em MySQL real antes dos slides serem atualizados.
