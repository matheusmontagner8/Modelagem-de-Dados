# Relatório Técnico Final — Entrega 2
### Contrasti Bolsas e Acessórios Ltda — Modelo Lógico, Implementação SQL

> Continuação da Entrega 1 (mesma organização real, mesmo DER de 9 entidades). Ver `README.md` na raiz do repositório para a caracterização completa da organização, evidências de visita, processos de negócio, requisitos e o Dicionário de Dados Conceitual.

---

## 1.1 Revisão do Modelo Conceitual

O DER da Entrega 1 (`Diagrama/Diagrama.png`) não foi alterado em conteúdo nesta etapa — as 9 entidades (FORNECEDOR, INSUMO, FICHA_TÉCNICA, PRODUTO, BOLSA, ACESSÓRIO, ITEM_PEDIDO, PEDIDO, CLIENTE) e os 6 relacionamentos seguem os mesmos da versão final da Entrega 1, já com a correção de cardinalidade aplicada entre INSUMO–FICHA_TÉCNICA–PRODUTO (padrão 1:N dos dois lados, coerente com uma entidade associativa de chave composta).

As evidências da organização (fotos, endereço, contato) seguem as mesmas da Entrega 1 — não houve nova visita de campo nesta etapa; o grupo usou o modelo conceitual já validado como base direta para a conversão lógica abaixo.

---

## 1.2 Conversão do Modelo Conceitual para o Modelo Lógico

### Entidades → Tabelas

Cada uma das 9 entidades do DER virou uma tabela. A especialização PRODUTO → BOLSA/ACESSÓRIO foi convertida pela estratégia **"tabela por subtipo"**: PRODUTO guarda os atributos comuns, e BOLSA/ACESSÓRIO guardam só os atributos exclusivos de cada subtipo, com a própria chave primária de PRODUTO reaproveitada como chave primária e estrangeira (`id_produto`). Essa é a estratégia mais fiel à especialização Total e Disjunta (TD) do DER: ela evita colunas que ficariam sempre nulas para um dos dois subtipos (o que aconteceria se tudo fosse uma tabela só) e não perde a identidade comum de PRODUTO (o que aconteceria se BOLSA e ACESSÓRIO virassem tabelas totalmente independentes).

| Entidade conceitual | Tabela(s) lógica(s) |
|---|---|
| FORNECEDOR | `fornecedor` |
| INSUMO | `insumo` |
| FICHA_TÉCNICA | `ficha_tecnica` |
| PRODUTO | `produto` |
| BOLSA | `bolsa` |
| ACESSÓRIO | `acessorio` |
| ITEM_PEDIDO | `item_pedido` |
| PEDIDO | `pedido` |
| CLIENTE | `cliente` |

### Atributos → Colunas

Os atributos do dicionário de dados da Entrega 1 viraram colunas com tipo de dado explícito (ver a tabela completa na Seção 2 — Modelo Lógico Relacional). Três decisões de tipagem valem registro:

- `preco_unitario`, `preco_base`, `estoque_atual`, `valor_total`, `subtotal` → `DECIMAL(10,2)` (nunca `FLOAT`/`DOUBLE`, para não acumular erro de arredondamento em valor monetário).
- `quantidade_necessaria` (ficha técnica) → `DECIMAL(10,3)`, com uma casa decimal a mais que os valores monetários, porque quantidades de insumo (ex.: metros de linha, m² de couro) usam frações mais finas que centavos.
- Atributos de domínio fechado do dicionário (`categoria_fornecedor`, `unidade_medida`, `tipo_produto`, `status`, `forma_pagamento`) viraram `VARCHAR` com `CHECK ... IN (...)` em vez de tabelas de domínio separadas —o grupo considerou esses domínios pequenos e estáveis o bastante (4 a 6 valores fixos) para não justificar uma tabela extra.

### Relacionamentos → Chaves

| Relacionamento conceitual | Tradução no modelo lógico |
|---|---|
| FORNECEDOR (1,1) — fornece — (0,N) INSUMO | `insumo.fornecedor_id` → FK para `fornecedor.id_fornecedor` |
| INSUMO (1,1) — compõe — (0,N) FICHA_TÉCNICA | `ficha_tecnica.insumo_id` → FK para `insumo.id_insumo` (parte da PK composta) |
| FICHA_TÉCNICA (0,N) — detalha — (1,1) PRODUTO | `ficha_tecnica.produto_id` → FK para `produto.id_produto` (parte da PK composta) |
| PRODUTO — TD — BOLSA / ACESSÓRIO | `bolsa.id_produto` e `acessorio.id_produto` → FK para `produto.id_produto`, e também PK de cada subtipo |
| PRODUTO (1,1) — integra — (0,N) ITEM_PEDIDO | `item_pedido.produto_id` → FK para `produto.id_produto` |
| ITEM_PEDIDO (0,N) — pertence_a — (1,1) PEDIDO | `item_pedido.pedido_id` → FK para `pedido.id_pedido` |
| PEDIDO (0,N) — é_efetuado_por — (1,1) CLIENTE | `pedido.cliente_id` → FK para `cliente.id_cliente` |

Regra geral aplicada: em todo relacionamento 1:N, a chave estrangeira migra para a tabela do lado "N" — exatamente como o DER já antecipava, marcando essas chaves como `(FK)` diretamente nas entidades.

### Cardinalidades

- **1:N** (a maioria dos relacionamentos do modelo) → FK simples na tabela do lado N, `NOT NULL` quando a cardinalidade mínima do lado 1 é (1,1) (ex.: `insumo.fornecedor_id`, `pedido.cliente_id`, `item_pedido.pedido_id`, `item_pedido.produto_id`).
- **N:N** — não existe nenhum relacionamento N:N puro neste modelo; INSUMO×PRODUTO já era resolvido via FICHA_TÉCNICA desde o conceitual (duas relações 1:N em cadeia), então não foi necessário criar nenhuma tabela associativa nova nesta etapa — `ficha_tecnica` e `item_pedido` já nasceram como tabelas na conversão direta das entidades associativas do DER.
- **1:1** (especialização TD) → chave primária compartilhada entre `produto` e `bolsa`/`acessorio`, com `ON DELETE CASCADE` (se o produto for excluído, a linha do subtipo correspondente também é).

---

## 1.3 Definição de Chaves Primárias e Estrangeiras

| Tabela | Chave Primária (PK) | Chaves Estrangeiras (FK) |
|---|---|---|
| `fornecedor` | `id_fornecedor` | — |
| `insumo` | `id_insumo` | `fornecedor_id` → `fornecedor.id_fornecedor` |
| `produto` | `id_produto` | — |
| `bolsa` | `id_produto` | `id_produto` → `produto.id_produto` |
| `acessorio` | `id_produto` | `id_produto` → `produto.id_produto` |
| `ficha_tecnica` | `(produto_id, insumo_id)` *(composta)* | `produto_id` → `produto.id_produto`; `insumo_id` → `insumo.id_insumo` |
| `cliente` | `id_cliente` | — |
| `pedido` | `id_pedido` | `cliente_id` → `cliente.id_cliente` |
| `item_pedido` | `id_item_pedido` | `pedido_id` → `pedido.id_pedido`; `produto_id` → `produto.id_produto` |

Todas as PKs de entidade "forte" são substitutas (`INT AUTO_INCREMENT`), exceto `ficha_tecnica`, que usa chave composta natural (`produto_id` + `insumo_id`) — ela já identifica a linha sem precisar de um `id` artificial, e a composição reforça a regra de negócio "cada par produto/insumo aparece uma única vez na ficha técnica" diretamente no banco (não dá para inserir o mesmo par duas vezes, a PK barra).

---

## 1.4 Processo de Normalização (1FN, 2FN e 3FN)

### 1FN — eliminação de grupos repetitivos/atributos multivalorados

Nenhuma tabela tem coluna multivalorada ou grupo repetitivo. O único atributo que poderia ser questionado é `endereco` (em `fornecedor` e `cliente`), guardado como uma única string em vez de decomposto em logradouro/número/bairro/cidade/UF/CEP. Decisão consciente do grupo: nenhum requisito levantado (Seção 3 do README) pede filtrar ou agrupar por cidade/UF separadamente — o endereço é usado só como dado de contato/entrega, exibido inteiro. Decompor essa string exigiria 5-6 colunas novas sem nenhum ganho funcional nesta etapa, então o atributo foi mantido atômico "para o uso que o sistema dá a ele", critério de atomicidade relativa.

### 2FN — eliminação de dependências parciais

2FN só é uma preocupação real em tabelas com **chave composta** — no modelo, apenas `ficha_tecnica` (PK = `produto_id` + `insumo_id`). O único atributo não-chave dessa tabela, `quantidade_necessaria`, depende dos **dois** componentes da chave ao mesmo tempo (a quantidade de couro necessária só faz sentido para o par "este produto, este insumo" — não dá pra dizer que `quantidade_necessaria` depende só de `produto_id` ou só de `insumo_id`). Logo, não há dependência parcial e a tabela está em 2FN. As demais tabelas têm PK simples (uma coluna), então 2FN é satisfeita trivialmente.

### 3FN — eliminação de dependências transitivas

Todas as colunas não-chave de cada tabela dependem diretamente da PK, com uma exceção **deliberada**: `pedido.valor_total`. Formalmente, esse valor é calculável a partir de outra tabela (`SUM(item_pedido.subtotal)` para aquele pedido) — ou seja, não depende só de `pedido.id_pedido`, e sim (indiretamente) dos itens. Isso seria uma violação de 3FN se fosse mantido sem controle.

O grupo optou por manter `valor_total` como coluna própria (denormalização controlada), por dois motivos:
1. **Já estava no Dicionário de Dados da Entrega 1** (`pedido.valor_total`), então removê-lo quebraria a continuidade entre as duas entregas.
2. **Uso real do valor**: consultas gerenciais de faturamento (Seção 8 do script SQL) são executadas com muito mais frequência do que pedidos são alterados — manter o total pronto evita recalcular a soma a cada relatório.

Para não deixar essa denormalização "solta", o script SQL documenta explicitamente como mantê-la consistente: toda vez que `item_pedido` muda, a Seção 6 (UPDATE) do script recalcula `pedido.valor_total` a partir da soma real dos itens, e a Seção 9 (auditoria) traz uma consulta (9.1) que detecta qualquer pedido fora de sincronia. `item_pedido.subtotal`, por outro lado, **não** tem esse problema: é `GENERATED ALWAYS AS (quantidade * preco_unitario) STORED`, ou seja, uma coluna calculada pelo próprio SGBD a partir de colunas da mesma linha — nunca pode ficar inconsistente, porque não é possível escrever um valor diferente nela.

---

## 1.5 Justificativas Técnicas das Decisões

- **Chaves primárias:** surrogate (`AUTO_INCREMENT`) em toda entidade "forte", porque nenhum atributo natural é garantidamente estável e único ao longo do tempo (CNPJ e CPF são únicos, mas o grupo preferiu não usá-los como PK para não propagar um dado sensível — protegido por LGPD — como chave estrangeira em outras tabelas). `ficha_tecnica` é a exceção justificada na Seção 1.3.
- **Chaves estrangeiras:** todas as FKs do modelo lógico correspondem 1:1 às linhas da tabela de relacionamentos da Seção 6 do README (Entrega 1) — nenhuma FK foi criada "a mais"; cada uma implementa exatamente um relacionamento do DER.
- **Restrições de obrigatoriedade/unicidade:** `UNIQUE` em `fornecedor.cnpj` e `cliente.cpf` (regra de negócio explícita: "não pode existir mais de um fornecedor/cliente com o mesmo documento", Seção 5 do dicionário). `NOT NULL` em toda coluna que o dicionário descreve como "Obrigatório".
- **Valores permitidos (`CHECK`):** todo atributo de domínio fechado do dicionário (`categoria_fornecedor`, `unidade_medida`, `tipo_produto`, `status`, `forma_pagamento`) virou `CHECK ... IN (...)`, em vez de confiar só na aplicação para validar — o banco recusa a linha mesmo se alguém inserir direto via SQL.
- **`ON DELETE CASCADE` em `bolsa`/`acessorio`/`ficha_tecnica`/`item_pedido`:** se um produto for excluído, não faz sentido manter órfã a linha do subtipo nem as linhas de ficha técnica que o detalham; o mesmo vale para os itens de um pedido excluído. Já `insumo`, `cliente` e `fornecedor` **não** têm cascade a partir deles — excluir um fornecedor não deveria apagar silenciosamente os insumos que ele fornece (é um erro operacional que o banco deve barrar, não propagar).
- **Decisões arquiteturais gerais:** o modelo ficou com 9 tabelas, o mesmo número de entidades do conceitual — nenhuma tabela associativa nova foi necessária porque `ficha_tecnica` e `item_pedido` já nasceram como entidades associativas desde a Entrega 1, e a especialização TD foi resolvida com tabela-por-subtipo (Seção 1.2) em vez de tabela única.

---

## 1.6 Proposta de Arquitetura Analítica para BI e IA

### Informações estratégicas extraíveis dos dados

- Faturamento por período, por canal implícito de pagamento e por categoria de produto.
- Composição de custo de cada peça (matéria-prima via `ficha_tecnica` × `insumo.preco_unitario`) versus preço praticado — margem real por produto.
- Consumo de insumos projetado a partir das vendas, para antecipar reposição de estoque junto aos fornecedores certos (via `insumo.fornecedor_id`).
- Concentração de receita por cliente (ranking de maiores compradores — ver consulta 8.4 do script).

### Indicadores e métricas gerenciais propostos (KPIs)

| KPI | Cálculo | Tabelas envolvidas |
|---|---|---|
| Faturamento mensal | `SUM(valor_total)` de pedidos faturados/expedidos, por mês | `pedido` |
| Ticket médio | `AVG(valor_total)` por pedido | `pedido` |
| Margem média por categoria | `AVG(preco_base - custo_materia_prima)` agrupado por `categoria` | `produto`, `ficha_tecnica`, `insumo` |
| Giro de estoque por produto | unidades vendidas no período ÷ `estoque_total` | `item_pedido`, `produto` |
| Dependência por fornecedor | % do custo de matéria-prima concentrado em cada `fornecedor_id` | `insumo`, `ficha_tecnica`, `fornecedor` |
| Taxa de cancelamento | pedidos com `status = 'Cancelado'` ÷ total de pedidos | `pedido` |

### Potencial dos dados para BI

A estrutura normalizada (fatos em `pedido`/`item_pedido`, dimensões em `cliente`/`produto`/`insumo`/`fornecedor`) já se parece com um esquema estrela simplificado — `item_pedido` funciona como tabela de fatos (uma linha por venda de um produto), e as demais como dimensões. Isso facilita alimentar diretamente uma ferramenta de BI (Power BI, Metabase, Looker Studio) sem grande transformação: as consultas gerenciais da Seção 8 do script já são, na prática, protótipos de dashboards (faturamento por mês, curva ABC, margem por produto, ranking de clientes).

### Aplicações analíticas e de IA

- **Previsão de demanda:** série histórica de `item_pedido.quantidade` por produto/mês alimentando um modelo simples de previsão (ex.: média móvel ou regressão), para antecipar compra de insumos sazonais (Dia das Mães, Natal — mencionado na Seção 1 do README como pico de pedidos).
- **Recomendação:** padrão de coocorrência de produtos no mesmo pedido (ex.: clientes que compram "Bolsa Tote" também compram "Porta-Cartões") para sugestão de combos.
- **Detecção de anomalia de preço:** a própria consulta de auditoria 9.5 do script (itens vendidos com preço muito distante do `preco_base` atual) é, na prática, uma regra de detecção de anomalia simples — poderia evoluir para um modelo estatístico (desvio padrão por categoria) em vez de um limiar fixo de 10%.
- **Classificação de risco de crédito:** se o atributo de perfil/crédito do cliente (presente no levantamento de requisitos original, Seção 3, mas fora do recorte de 9 entidades modelado) for incorporado em uma iteração futura, os dados de `pedido`/`item_pedido` já dão histórico suficiente para treinar um modelo simples de propensão a atraso.

---

## 6. Uso de Inteligência Artificial

| Item | Registro |
|---|---|
| **Ferramenta e etapa** | Claude (Claude Code / Sonnet 5, Anthropic) — usado na conversão do modelo conceitual (Entrega 1, já existente) para o modelo lógico completo desta Entrega 2: definição de tabelas/colunas/tipos, normalização (1FN/2FN/3FN), script SQL completo (DDL + massa de dados fictícia + consultas) e este relatório técnico. |
| **Motivação** | Acelerar a conversão sistemática de 9 entidades conceituais em tabelas relacionais consistentes com o DER e o dicionário já produzidos na Entrega 1, e gerar uma massa de dados fictícia coerente com a operação da Contrasti (couro, ferragens, zíperes, bolsas/acessórios) sem usar nenhum dado real de cliente. |
| **Prompt(s) utilizados** | "Me ajude com o esqueleto da entrega 2" (a partir do arquivo `00-d_Esqueleto_Entrega_2.md` anexado, usando como base o repositório já existente com o DER e o dicionário da Entrega 1). |
| **Resposta recebida** | O script SQL completo (`script.sql`), este relatório técnico (`RELATORIO_TECNICO.md`) e o documento de modelo lógico (`modelo_logico.md`), cobrindo as 9 seções pedidas no esqueleto oficial. |
| **Fontes consultadas e verificadas** | Nenhuma fonte externa. A conversão partiu exclusivamente do Dicionário de Dados e do DER já validados na Entrega 1 (`README.md`, `Dicionario_de_Dados.html`, `Diagrama/Diagrama.png`). O script SQL foi testado antes da entrega — ver nota de validação abaixo. |
| **Trechos rejeitados ou corrigidos** | Nenhum trecho foi rejeitado nesta primeira rodada — o grupo ainda precisa revisar este material (ver "Reflexão crítica"). Durante a própria geração, a IA testou o script rodando-o (com pequenas adaptações de dialeto) em um banco SQLite local, e usou esse teste para confirmar que a massa de dados é internamente consistente (margens batem com a ficha técnica, a checagem de especialização TD não aponta nenhuma inconsistência, os totais de pedido recalculados batem com a soma dos itens) antes de considerar o script pronto. |
| **Justificativa da escolha final** | O grupo manteve a conversão 1 tabela por entidade (sem tabelas associativas extras) porque `ficha_tecnica` e `item_pedido` já eram entidades associativas desde o conceitual; manteve `pedido.valor_total` como denormalização controlada (em vez de só uma VIEW) para não quebrar a continuidade com o dicionário da Entrega 1 — ver Seção 1.4 para a justificativa completa. |
| **Reflexão crítica** | Este material **ainda não foi validado com a organização real** (Osmar, Contrasti) nem revisado linha a linha pelo grupo — é um primeiro rascunho completo, não a versão final de entrega. Pontos que precisam de atenção humana antes de entregar: (1) a massa de dados é inteiramente fictícia e precisa ser comparada com o volume/tipo de pedido real da empresa (a Seção 1 do README menciona 50-70 pedidos/mês — o script tem só 15 pedidos de exemplo, suficiente para demonstrar a estrutura mas não para representar um mês real); (2) os valores de preço, CNPJ e demais dados fictícios não foram conferidos com o Osmar; (3) o grupo deve decidir se quer manter os domínios fechados como `CHECK` (decisão desta IA) ou criar tabelas de domínio separadas, dependendo do que foi ensinado em aula; (4) a proposta de BI/IA (Seção 1.6) é um ponto de partida conceitual, não uma arquitetura testada. |
