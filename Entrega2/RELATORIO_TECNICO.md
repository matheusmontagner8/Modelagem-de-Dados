# Relatório Técnico Final — Entrega 2
### Contrasti Bolsas e Acessórios Ltda — Modelo Lógico, Implementação SQL

> Continuação da Entrega 1. Ver `README.md` na raiz do repositório para a caracterização completa da organização, evidências de visita, processos de negócio, requisitos e o Dicionário de Dados Conceitual.

---

## 1.1 Revisão do Modelo Conceitual

O DER da Entrega 1 (`Diagrama/Diagrama.png`) **foi reconstruído** nesta etapa, em resposta à avaliação do professor: de 9 para 17 entidades e de 6 para 16 relacionamentos, todos agora com cardinalidade mínima e máxima em ambas as pontas, sem nenhuma marcação de FK no diagrama. O detalhamento completo dessa correção está no `README.md` da raiz (Seções 5–9) e no `Dicionario_de_Dados.html`; este relatório parte diretamente do modelo já corrigido.

Oito entidades novas entraram no recorte: duas essenciais (`ORDEM_PRODUCAO`, `LOTE_INSUMO`) e seis desejáveis (`ETAPA_PRODUCAO`, `ARTESAO`, `EXECUCAO_ETAPA`, `VENDEDOR`, `CONTAS_RECEBER`, `CONTAS_PAGAR`). A conversão lógica abaixo cobre as 17.

As evidências da organização (fotos, endereço, contato) seguem as mesmas da Entrega 1, pois não houve nova visita de campo nesta etapa.

---

## 1.2 Conversão do Modelo Conceitual para o Modelo Lógico

### Entidades → Tabelas

Cada uma das 17 entidades do DER virou uma tabela. A especialização PRODUTO → BOLSA/ACESSÓRIO segue a estratégia tabela por subtipo: PRODUTO guarda os atributos comuns, e BOLSA/ACESSÓRIO guardam só os atributos exclusivos de cada subtipo, com a própria chave primária de PRODUTO reaproveitada como chave primária e estrangeira (`id_produto`). Essa é a estratégia mais fiel à especialização Total e Disjunta (TD) do DER: ela evita colunas que ficariam sempre nulas para um dos dois subtipos e não perde a identidade comum de PRODUTO.

| Entidade conceitual | Tabela(s) lógica(s) |
|---|---|
| FORNECEDOR | `fornecedor` |
| INSUMO | `insumo` |
| LOTE_INSUMO | `lote_insumo` |
| FICHA_TÉCNICA | `ficha_tecnica` |
| PRODUTO | `produto` |
| BOLSA | `bolsa` |
| ACESSÓRIO | `acessorio` |
| ORDEM_PRODUÇÃO | `ordem_producao` |
| ETAPA_PRODUÇÃO | `etapa_producao` |
| ARTESÃO_FACÇÃO | `artesao` |
| EXECUÇÃO_ETAPA | `execucao_etapa` |
| CLIENTE | `cliente` |
| VENDEDOR | `vendedor` |
| PEDIDO | `pedido` |
| ITEM_PEDIDO | `item_pedido` |
| CONTAS_RECEBER | `contas_receber` |
| CONTAS_PAGAR | `contas_pagar` |

### Atributos → Colunas

Os atributos do dicionário de dados da Entrega 1 viraram colunas com tipo de dado explícito e nome prefixado (`id_`/`nm_`/`ds_`/`dt_`/`vl_`/`qt_`/`pc_`/`tp_`/`nr_`/`un_` — mesma convenção do `Dicionario_de_Dados.html`). Decisões de tipagem que valem registro:

- `vl_*` (preços, valores de título) → `DECIMAL(10,2)` (nunca `FLOAT`/`DOUBLE`, para não acumular erro de arredondamento em valor monetário).
- `qt_necessaria`, `qt_recebida` (lote/ficha técnica) → `DECIMAL(10,3)`, uma casa decimal a mais que valores monetários, porque quantidades de insumo (metros de linha, m² de couro) usam frações mais finas que centavos.
- `pc_aproveitamento`, `pc_perda`, `pc_comissao` → `DECIMAL(5,2)`, suficiente para um percentual com duas casas.
- Atributos de domínio fechado (`tp_categoria`, `un_medida`, `tp_produto`, `tp_status`, `tp_pagamento`, `tp_canal`, `tp_status_kanban`, `tp_vinculo`) viraram `VARCHAR` com `CHECK ... IN (...)` em vez de tabelas de domínio separadas — domínios pequenos e estáveis (3 a 6 valores fixos), exceto `ETAPA_PRODUCAO`, que **é** uma tabela de domínio própria porque também carrega a ordem sequencial do processo produtivo (`nr_ordem_sequencial`), um dado que não cabe num `CHECK`.

### Relacionamentos → Chaves

| Relacionamento conceitual | Tradução no modelo lógico |
|---|---|
| FORNECEDOR (1,1) — fornece — (0,N) LOTE_INSUMO | `lote_insumo.fornecedor_id` → FK para `fornecedor.id_fornecedor` |
| INSUMO (1,1) — é_recebido_como — (0,N) LOTE_INSUMO | `lote_insumo.insumo_id` → FK para `insumo.id_insumo` |
| LOTE_INSUMO (1,1) — gera — (0,N) CONTAS_PAGAR | `contas_pagar.lote_id` → FK para `lote_insumo.id_lote` |
| PRODUTO (1,1) — é_detalhado_em — (0,N) FICHA_TÉCNICA | `ficha_tecnica.produto_id` → FK para `produto.id_produto` |
| INSUMO (1,1) — compõe — (0,N) FICHA_TÉCNICA | `ficha_tecnica.insumo_id` → FK para `insumo.id_insumo` |
| PRODUTO (1,1) — é_produzido_em — (0,N) ORDEM_PRODUÇÃO | `ordem_producao.produto_id` → FK para `produto.id_produto` |
| ORDEM_PRODUÇÃO (1,1) — se_desdobra_em — (0,N) EXECUÇÃO_ETAPA | `execucao_etapa.op_id` → FK para `ordem_producao.id_op` |
| ETAPA_PRODUÇÃO (1,1) — classifica — (0,N) EXECUÇÃO_ETAPA | `execucao_etapa.etapa_id` → FK para `etapa_producao.id_etapa` |
| ARTESÃO (1,1) — realiza — (0,N) EXECUÇÃO_ETAPA | `execucao_etapa.artesao_id` → FK para `artesao.id_artesao` |
| PRODUTO — TD — BOLSA / ACESSÓRIO | `bolsa.id_produto` e `acessorio.id_produto` → FK para `produto.id_produto`, e também PK de cada subtipo |
| CLIENTE (1,1) — realiza — (0,N) PEDIDO | `pedido.cliente_id` → FK para `cliente.id_cliente` |
| VENDEDOR (1,1) — atende — (0,N) PEDIDO | `pedido.vendedor_id` → FK para `vendedor.id_vendedor` |
| PEDIDO (1,1) — contém — (1,N) ITEM_PEDIDO | `item_pedido.pedido_id` → FK para `pedido.id_pedido` |
| PRODUTO (1,1) — é_vendido_em — (0,N) ITEM_PEDIDO | `item_pedido.produto_id` → FK para `produto.id_produto` |
| PEDIDO (1,1) — gera — (0,N) CONTAS_RECEBER | `contas_receber.pedido_id` → FK para `pedido.id_pedido` |

Regra geral aplicada: em todo relacionamento 1:N, a chave estrangeira migra para a tabela do lado "N". Diferente da Entrega 1 original, **nenhuma dessas FKs aparece no DER conceitual**, elas só existem a partir desta conversão lógica.

### Cardinalidades

- **1:N** (a maioria dos relacionamentos do modelo) → FK simples na tabela do lado N, `NOT NULL` em todos os casos, porque toda cardinalidade mínima do lado 1 no DER corrigido é (1,1).
- **N:N** — não existe nenhum relacionamento N:N puro neste modelo; todas as associações com atributo próprio (`lote_insumo`, `ficha_tecnica`, `execucao_etapa`, `item_pedido`) já nasceram como entidades associativas desde o conceitual.
- **1:1** (especialização TD) → chave primária compartilhada entre `produto` e `bolsa`/`acessorio`, com `ON DELETE CASCADE`.

---

## 1.3 Definição de Chaves Primárias e Estrangeiras

| Tabela | Chave Primária (PK) | Chaves Estrangeiras (FK) |
|---|---|---|
| `fornecedor` | `id_fornecedor` | — |
| `insumo` | `id_insumo` | — |
| `lote_insumo` | `id_lote` | `insumo_id` → `insumo.id_insumo`; `fornecedor_id` → `fornecedor.id_fornecedor` |
| `produto` | `id_produto` | — |
| `bolsa` | `id_produto` | `id_produto` → `produto.id_produto` |
| `acessorio` | `id_produto` | `id_produto` → `produto.id_produto` |
| `ficha_tecnica` | `id_ficha` | `produto_id` → `produto.id_produto`; `insumo_id` → `insumo.id_insumo` |
| `ordem_producao` | `id_op` | `produto_id` → `produto.id_produto` |
| `etapa_producao` | `id_etapa` | — |
| `artesao_` | `id_artesao` | — |
| `execucao_etapa` | `id_execucao` | `op_id` → `ordem_producao.id_op`; `etapa_id` → `etapa_producao.id_etapa`; `artesao_id` → `artesao.id_artesao` |
| `cliente` | `id_cliente` | — |
| `vendedor` | `id_vendedor` | — |
| `pedido` | `id_pedido` | `cliente_id` → `cliente.id_cliente`; `vendedor_id` → `vendedor.id_vendedor` |
| `item_pedido` | `id_item_pedido` | `pedido_id` → `pedido.id_pedido`; `produto_id` → `produto.id_produto` |
| `contas_receber` | `id_titulo_receber` | `pedido_id` → `pedido.id_pedido` |
| `contas_pagar` | `id_titulo_pagar` | `lote_id` → `lote_insumo.id_lote` |


---

## 1.4 Processo de Normalização (1FN, 2FN e 3FN)

### 1FN — eliminação de grupos repetitivos/atributos multivalorados

Nenhuma tabela tem coluna multivalorada ou grupo repetitivo. O único atributo que poderia ser questionado é `ds_endereco` (em `fornecedor` e `cliente`), guardado como uma única string em vez de decomposto em logradouro/número/bairro/cidade/UF/CEP. Decisão consciente do grupo: nenhum requisito levantado (Seção 3 do README) pede filtrar ou agrupar por cidade/UF separadamente — o endereço é usado só como dado de contato/entrega, exibido inteiro.

### 2FN — eliminação de dependências parciais

2FN só é uma preocupação real em tabelas com **chave composta** — e, nesta versão, nenhuma tabela tem PK composta (a antiga `ficha_tecnica` foi a exceção na v1; ver Seção 1.3). Todas as tabelas têm PK simples (uma coluna gerada), então 2FN é satisfeita trivialmente em todo o modelo.

### 3FN — eliminação de dependências transitivas

Todas as colunas não-chave de cada tabela dependem diretamente da PK, com duas exceções **deliberadas**:

1. **`pedido.vl_total`** — formalmente calculável a partir de outra tabela (`SUM(item_pedido.vl_subtotal)` para aquele pedido). O grupo optou por mantê-lo como coluna própria (denormalização controlada), por dois motivos: (a) já estava no Dicionário de Dados desde a Entrega 1, e (b) consultas gerenciais de faturamento são executadas com muito mais frequência do que pedidos são alterados. Para não deixar a denormalização "solta": a Seção 6 (UPDATE) do script recalcula `vl_total` a partir da soma real dos itens sempre que necessário, e a Seção 9 (auditoria, 9.1) detecta qualquer pedido fora de sincronia.
2. **`insumo.qt_estoque_atual`** — na prática, um agregado do que entrou via `lote_insumo` menos o que foi consumido pela produção. Mantido como coluna própria pelo mesmo motivo do item anterior (consulta de estoque é operação frequente e não pode depender de somar todo o histórico de lotes a cada leitura); a atualização fica a cargo da aplicação/rotina de baixa (RF13), fora do escopo deste script de demonstração.

`item_pedido.vl_subtotal`, por outro lado, **não** tem esse problema: é `GENERATED ALWAYS AS (...) STORED`, calculado pelo próprio SGBD a partir de colunas da mesma linha — nunca pode ficar inconsistente.

---

## 1.5 Justificativas Técnicas das Decisões

- **Chaves primárias:** surrogate (`AUTO_INCREMENT`) em toda tabela, inclusive `ficha_tecnica` (ver Seção 1.3) — nenhum atributo natural é garantidamente estável e único ao longo do tempo, e CNPJ/CPF não foram usados como PK para não propagar um dado sensível (protegido por LGPD) como chave estrangeira em outras tabelas.
- **Chaves estrangeiras:** todas as FKs do modelo lógico correspondem 1:1 às linhas da tabela de relacionamentos da Seção 6 do README (Entrega 1) — nenhuma FK foi criada "a mais"; cada uma implementa exatamente um relacionamento do DER corrigido.
- **Restrições de obrigatoriedade/unicidade:** `UNIQUE` em `fornecedor.nr_cnpj`, `cliente.nr_cpf`, `ordem_producao.nr_op` e `etapa_producao.nr_ordem_sequencial`. `NOT NULL` em toda coluna que o dicionário descreve como obrigatória.
- **Valores permitidos (`CHECK`):** todo atributo de domínio fechado do dicionário virou `CHECK ... IN (...)` — o banco recusa a linha mesmo se alguém inserir direto via SQL.
- **`ON DELETE CASCADE`:** em `bolsa`, `acessorio`, `ficha_tecnica`, `item_pedido` e `execucao_etapa` — se o "todo" (produto, pedido, ordem de produção) for excluído, não faz sentido manter órfãs as linhas que o detalham. Já `insumo`, `cliente`, `fornecedor`, `lote_insumo`, `etapa_producao`, `artesao`, `pedido` e `vendedor` **não** têm cascade a partir deles — excluir, por exemplo, um fornecedor não deveria apagar silenciosamente o histórico de lotes recebidos dele (é um erro operacional que o banco deve barrar, não propagar). Essa é exatamente a razão pela qual a Seção 7.2 do script escolhe um insumo **sem nenhuma dependência** para demonstrar o DELETE, em vez de forçar uma exclusão em cascata através do histórico de compras.
- **`LOTE_INSUMO` em vez de FK direta `insumo.fornecedor_id`:** a versão anterior prendia cada insumo a um único fornecedor fixo, contradizendo a própria regra de rastreabilidade por lote (um mesmo insumo pode ser recebido de fornecedores diferentes). A consulta 5.4 do script demonstra isso: "Bolsa Tote Caramelo" usa couro recebido de **dois** fornecedores diferentes (Curtume Vaqueta Ouro e Curtume Linhares Couros).
- **Decisões arquiteturais gerais:** o modelo ficou com 17 tabelas, o mesmo número de entidades do conceitual corrigido — nenhuma tabela associativa nova foi necessária além das já previstas no DER, e a especialização TD seguiu com tabela-por-subtipo (Seção 1.2).

---

## 1.6 Proposta de Arquitetura Analítica para BI e IA

### Informações estratégicas extraíveis dos dados

- Faturamento por período, canal (loja física/e-commerce/atacado) e categoria de produto.
- Composição de custo de cada peça (matéria-prima via `ficha_tecnica` × `insumo.vl_preco_referencia`) versus preço praticado — margem real por produto.
- Consumo de insumos projetado a partir das vendas, para antecipar reposição junto aos fornecedores certos (via `lote_insumo`, agora com histórico multi-fornecedor).
- Concentração de receita por cliente e comissão devida por vendedor/canal (consulta 5.7 do script).
- Produtividade e qualidade por etapa de produção: aproveitamento/perda de couro por artesão/facção na etapa de Corte (consulta 8.6).
- Saúde financeira: aging de títulos a pagar/receber em aberto (consultas 8.7 e 9.7).

### Indicadores e métricas gerenciais propostos (KPIs)

| KPI | Cálculo | Tabelas envolvidas |
|---|---|---|
| Faturamento mensal | `SUM(vl_total)` de pedidos faturados/expedidos, por mês | `pedido` |
| Ticket médio | `AVG(vl_total)` por pedido | `pedido` |
| Margem média por categoria | `AVG(vl_preco_base - custo_materia_prima)` agrupado por `tp_categoria` | `produto`, `ficha_tecnica`, `insumo` |
| Giro de estoque por produto | unidades vendidas no período ÷ `qt_estoque_total` | `item_pedido`, `produto` |
| Dependência por fornecedor | % do custo de matéria-prima concentrado em cada `fornecedor_id` | `insumo`, `ficha_tecnica`, `lote_insumo`, `fornecedor` |
| Taxa de cancelamento | pedidos com `tp_status = 'Cancelado'` ÷ total de pedidos | `pedido` |
| Comissão por vendedor/canal | `SUM(vl_total) * pc_comissao / 100`, agrupado por vendedor e canal | `pedido`, `vendedor` |
| Aproveitamento médio de corte | `AVG(pc_aproveitamento)` na etapa "Corte", por artesão/facção | `execucao_etapa`, `etapa_producao`, `artesao` |
| Aging de contas a receber/pagar | dias entre `dt_vencimento` e a data de referência, para títulos "em aberto" | `contas_receber`, `contas_pagar` |

### Potencial dos dados para BI

A estrutura normalizada (fatos em `pedido`/`item_pedido`/`execucao_etapa`, dimensões em `cliente`/`vendedor`/`produto`/`insumo`/`fornecedor`/`artesao`) já se parece com um esquema estrela simplificado, agora com dois processos de negócio representados (vendas e produção), não só um. As consultas gerenciais da Seção 8 do script já são, na prática, protótipos de dashboards.

### Aplicações analíticas e de IA

- **Previsão de demanda:** série histórica de `item_pedido.qt_quantidade` por produto/mês, para antecipar compra de insumos sazonais (Dia das Mães, Natal).
- **Recomendação:** padrão de coocorrência de produtos no mesmo pedido, para sugestão de combos.
- **Detecção de anomalia de preço:** a consulta de auditoria 9.5 (limiar fixo de 10%) poderia evoluir para um modelo estatístico (desvio padrão por categoria).
- **Previsão de aproveitamento de corte:** a série de `execucao_etapa.pc_aproveitamento` por artesão (consulta 8.6) já dá histórico suficiente para um modelo simples de produtividade esperada por profissional, útil tanto para planejamento de produção quanto para conferência do pagamento por etapa.
- **Classificação de risco de crédito:** se o atributo de perfil/crédito do cliente (presente no levantamento de requisitos original, mas fora do recorte modelado) for incorporado em uma iteração futura, os dados de `pedido`/`contas_receber` já dão histórico suficiente (incluindo atraso de pagamento) para treinar um modelo simples de propensão a atraso.

---

## 2. Uso de Inteligência Artificial

| Item | Registro |
|---|---|
| **Ferramenta e etapa** | Claude (Claude Code / Sonnet 5, Anthropic) — usado em quatro momentos nesta Entrega 2: (1) conversão do modelo conceitual original (9 entidades) para o primeiro modelo lógico — tabelas/colunas/tipos, normalização (1FN/2FN/3FN), script SQL (DDL + massa de dados + consultas) e este relatório técnico; (2) ampliação da massa de dados de 15 para 77 pedidos e montagem do rascunho de slides (`.pptx`); (3) instalação de um MySQL Community Server 8.4.10 LTS local e execução completa do `script.sql` nele; (4) **reescrita completa** de `modelo_logico.md`, `script.sql`, deste relatório, `apresentacao_outline.md` e `apresentacao.pptx` para o modelo de 17 entidades, em resposta à avaliação do professor na [issue #1](https://github.com/matheusmontagner8/Modelagem-de-Dados/issues/1) — renomeação de colunas para o padrão de prefixos, substituição da FK direta `insumo.fornecedor_id` por `lote_insumo`, troca da PK composta de `ficha_tecnica` por chave própria, adição de 8 tabelas novas (`lote_insumo`, `ordem_producao`, `etapa_producao`, `artesao`, `execucao_etapa`, `vendedor`, `contas_receber`, `contas_pagar`) com dados e consultas coerentes, e reconstrução dos slides (12, com um novo slide de "correção aplicada"). |
| **Motivação** | Acelerar a conversão sistemática de entidades conceituais em tabelas relacionais; depois, fechar lacunas de volume de dados e apresentação; validar o script em um SGBD real; por fim, manter a Entrega 2 sincronizada com o DER/dicionário corrigidos da Entrega 1, em vez de deixá-la descrevendo um modelo já superado. |
| **Prompt(s) utilizados** | "Me ajude com o esqueleto da entrega 2"; "Faça todos os ajustes que faltam e que você conseguir"; "Por favor, me ajude a instalar o MySQL na minha máquina"; "Faça o ajuste na entrega 2/readme.md de acordo com as mudanças pedidas pelo professor" (resposta: README + os artefatos, conforme opção escolhida). |
| **Resposta recebida** | O script SQL completo (9 tabelas), este relatório e `modelo_logico.md`; depois, 62 pedidos adicionais e `apresentacao.pptx`; depois, validação real em MySQL 8.4.10 (0 erros); nesta rodada, `modelo_logico.md`, `script.sql` e este relatório reescritos para 17 tabelas, com os dados de produção/financeiro gerados programaticamente (`gen_entrega2_v2.py`, determinístico — sem aleatoriedade, para reprodutibilidade) e **validados novamente em MySQL real**, com 0 erros e todas as auditorias retornando o resultado esperado; e `apresentacao_outline.md`/`apresentacao.pptx` reconstruídos (12 slides) e validados estruturalmente (`validate.py`) e por conteúdo (`markitdown`). |
| **Fontes consultadas e verificadas** | Nenhuma fonte externa. A reescrita partiu exclusivamente do DER e do dicionário já corrigidos na Entrega 1 (`README.md`, `Dicionario_de_Dados.html`, `Diagrama/Diagrama.png`) e da avaliação literal do professor na issue #1. |
| **Trechos rejeitados ou corrigidos** | A primeira versão do `script.sql` (9 tabelas, `insumo.fornecedor_id` como FK direta, `ficha_tecnica` com PK composta) foi inteiramente substituída. Durante a geração dos dados novos, o grupo (via IA) decidiu deliberadamente deixar o insumo 10 (Caixa de Papelão Kraft) sem nenhum lote registrado — não porque a situação real exigisse isso, mas para que a demonstração de DELETE/auditoria (Seções 7.2/9.3/9.6) continuasse funcionando sem esbarrar em uma FK de `lote_insumo` apontando para ele (o que aconteceria se o insumo já tivesse sido comprado — nesse caso a exclusão deveria ser bloqueada pelo banco, não forçada). |
| **Justificativa da escolha final** | O modelo lógico passa a refletir fielmente as 17 entidades do conceitual corrigido, sem nenhuma FK "a mais" nem "a menos" em relação à tabela de relacionamentos do README. A denormalização controlada de `pedido.vl_total` foi mantida pelos mesmos motivos da v1 (ver Seção 1.4); `insumo.qt_estoque_atual` ganhou a mesma trava conceitual, agora explicitada, porque LOTE_INSUMO introduziu uma fonte de verdade alternativa (soma dos lotes) que o grupo decidiu não sincronizar automaticamente nesta entrega, por ser um recálculo trivial de implementar depois (fora do escopo de "ajustar conforme o professor pediu"). |
| **Reflexão crítica** | Assim como na v1, este material **ainda não foi validado com a organização real** (Osmar, Contrasti) — os números de `lote_insumo`, `execucao_etapa`, `vendedor` e os títulos financeiros são inteiramente fictícios, criados para demonstrar a estrutura corrigida, não para representar a operação real da Contrasti com precisão. Antes de uma eventual reapresentação, o grupo deveria: (1) confirmar com Osmar se a comissão de 3%/7% e o lead time de pagamento de 30 dias usados aqui fazem sentido; (2) decidir se `insumo.qt_estoque_atual` deve passar a ser recalculado automaticamente a partir de `lote_insumo` (trigger ou view) em vez de mantido manualmente; (3) `apresentacao.pptx` **também foi reescrito** nesta rodada (12 slides, novo DER, slide de "correção aplicada", tabelas de PK/FK separadas em núcleo/produção-financeiro) e passou pela validação estrutural e de conteúdo, mas **não foi visto renderizado** (sem LibreOffice disponível nesta sessão) — abrir no PowerPoint antes de apresentar. |
