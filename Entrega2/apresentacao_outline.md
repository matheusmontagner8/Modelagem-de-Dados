# Roteiro — Apresentação Corporativa Final

> Rascunho de conteúdo/roteiro para os slides (Seção 7 do esqueleto da Entrega 2). Ainda não é o arquivo `.pptx` final — é a base de texto para o grupo montar os slides com estética limpa e minimalista, **sem blocos longos de texto na tela** (o texto abaixo é para a fala de quem apresenta, não para copiar no slide). Peça para a IA gerar o `.pptx` a partir daqui se for útil — ela consegue montar um primeiro rascunho de arquivo PowerPoint.

Tempo sugerido: ~8-10 min de pitch + perguntas. Um slide por bloco abaixo, exceto onde indicado.

---

### 1. Contextualização do problema (1 slide)
**No slide:** nome da empresa, foto da fachada/oficina (já temos em `evidencias/`), 2-3 bullets curtos.
**Fala:** Contrasti Bolsas e Acessórios é uma indústria e comércio de bolsas de couro de pequeno/médio porte (São Paulo/SP). Hoje o controle de insumos, ficha técnica/custo de produto, estoque e vendas é descentralizado/manual (Seção 1 do README) — sem rastreabilidade de insumo por fornecedor, sem cálculo padronizado de custo, sem visão unificada de vendas.

### 2. Apresentação da solução (1 slide)
**No slide:** o DER de 9 entidades (`Diagrama/Diagrama.png`), reduzido/legível.
**Fala:** Um banco de dados relacional que cobre o núcleo "o que preciso para produzir e vender uma peça": fornecedor → insumo → ficha técnica → produto (bolsa/acessório) → pedido → cliente. Mencionar que o modelo foi deliberadamente recortado (9 entidades) para este primeiro ciclo — módulos de produção detalhada, logística e financeiro ficam documentados como requisito para uma próxima iteração (Seção 1.1 do Relatório Técnico).

### 3. Defesa do modelo lógico (1-2 slides)
**No slide:** a tabela de PK/FK (`modelo_logico.md`) resumida — só nomes de tabela + PK/FK, sem a descrição toda.
**Fala — pontos para defender se o professor perguntar:**
- Por que especialização virou "tabela por subtipo" (bolsa/acessório) em vez de uma tabela só.
- Por que `ficha_tecnica` e `item_pedido` têm chave composta/própria (entidades associativas).
- Por que `pedido.valor_total` é uma denormalização **controlada** (não um erro) — e como o script garante que ela fique consistente (Seção 6 do script + auditoria 9.1).
- Por que não existe nenhuma tabela N:N "pura" no modelo (já resolvidas desde o conceitual).

### 4. Demonstração da implementação (SQL rodando) (ao vivo, sem slide de texto)
**Roteiro de demo sugerido:**
1. Rodar `script.sql` do zero (banco vazio) — mostrar que não dá erro.
2. Mostrar 2-3 `CREATE TABLE` com `CHECK`/`FOREIGN KEY` no código.
3. Mostrar a massa de dados carregada (`SELECT * FROM produto;`).

### 5. Demonstração de consultas (gerenciais/auditoria) (ao vivo, 1 slide de "menu")
**No slide:** lista dos nomes das consultas (sem o SQL).
**Rodar ao vivo, nesta ordem (todas já prontas no `script.sql`, Seções 8 e 9):**
- Gerencial: faturamento por mês (8.1), curva ABC de produtos (8.2), margem por produto (8.3).
- Auditoria: checagem da especialização TD (9.4) — mostrar que vem vazia, prova que a regra "todo produto é bolsa OU acessório" está sendo respeitada pelos dados.

### 6. Potencial para BI e IA (1 slide)
**No slide:** os KPIs da tabela da Seção 1.6 do Relatório Técnico (escolher 3-4, não os 6).
**Fala:** mencionar o paralelo com esquema estrela (item_pedido como fato, cliente/produto/insumo/fornecedor como dimensões) e 1-2 aplicações de IA mais concretas (previsão de demanda sazonal — Dia das Mães/Natal já aparecem no levantamento de requisitos; detecção de anomalia de preço, que já existe como consulta SQL simples e poderia evoluir).

### 7. Benefícios diretos para a tomada de decisão (1 slide, fechamento)
**No slide:** 3 bullets de benefício, ligados a dor real da Seção 1 do README.
**Fala, ligando de volta ao problema do slide 1:**
- Rastreabilidade de insumo por fornecedor → decisão de compra baseada em dado, não em memória.
- Custo de produto calculado a partir da ficha técnica → margem real por peça, não estimativa.
- Histórico de pedidos por cliente → identificar os clientes mais importantes (ranking pronto na consulta 8.4).

---

### Perguntas que o professor provavelmente vai fazer (preparar resposta curta)
- "Por que vocês reduziram de 21 para 9 entidades entre a Entrega 1 e agora?" → decisão de escopo documentada na Seção 1.1/8 do material da Entrega 1 e 1.1 desta entrega.
- "Cadê ordem de produção, financeiro, expedição?" → estavam no levantamento de requisitos (README Seções 2-4), fora do recorte modelado nesta entrega; é trabalho futuro.
- "Essa massa de dados é real?" → não, é fictícia por exigência da própria atividade (privacidade); está documentado na Seção 4 do esqueleto e na Seção 6 (Uso de IA) do Relatório Técnico.
