# Modelo Lógico Relacional — Contrasti Bolsas e Acessórios

> Documento separado exigido pela Seção 2 do esqueleto da Entrega 2. Implementado integralmente em `script.sql` (Seção 2 do script = `CREATE TABLE` de todas as tabelas abaixo). Para a justificativa de cada decisão de conversão, ver `RELATORIO_TECNICO.md`, Seções 1.2 a 1.5.

9 tabelas, uma por entidade do DER da Entrega 1 — nenhuma tabela associativa extra foi necessária (ver `RELATORIO_TECNICO.md`, Seção 1.2).

---

## fornecedor

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_fornecedor** | `INT` | **PK**, `AUTO_INCREMENT` |
| nome | `VARCHAR(150)` | `NOT NULL` |
| cnpj | `VARCHAR(18)` | `NOT NULL`, `UNIQUE` |
| telefone | `VARCHAR(20)` | |
| email | `VARCHAR(120)` | |
| endereco | `VARCHAR(200)` | |
| data_cadastro | `DATE` | `NOT NULL`, padrão data atual |
| categoria_fornecedor | `VARCHAR(30)` | `NOT NULL`, `CHECK IN ('Couro','Ferragens','Ziperes','Embalagens')` |

## insumo

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_insumo** | `INT` | **PK**, `AUTO_INCREMENT` |
| nome_insumo | `VARCHAR(120)` | `NOT NULL` |
| tipo_insumo | `VARCHAR(30)` | `NOT NULL` |
| unidade_medida | `VARCHAR(10)` | `NOT NULL`, `CHECK IN ('DM2','M2','UN','M','KG','L')` |
| estoque_atual | `DECIMAL(10,2)` | `NOT NULL`, padrão `0`, `CHECK >= 0` |
| preco_unitario | `DECIMAL(10,2)` | `NOT NULL`, `CHECK > 0` |
| *fornecedor_id* | `INT` | **FK** → `fornecedor.id_fornecedor`, `NOT NULL` |

## produto

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_produto** | `INT` | **PK**, `AUTO_INCREMENT` |
| nome | `VARCHAR(120)` | `NOT NULL` |
| descricao | `VARCHAR(255)` | |
| preco_base | `DECIMAL(10,2)` | `NOT NULL`, `CHECK > 0` |
| categoria | `VARCHAR(50)` | |
| estoque_total | `INT` | `NOT NULL`, padrão `0`, `CHECK >= 0` |
| tipo_produto | `VARCHAR(10)` | `NOT NULL`, `CHECK IN ('BOLSA','ACESSORIO')` — discriminador da especialização |

## bolsa *(subtipo de produto)*

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_produto** | `INT` | **PK** e **FK** → `produto.id_produto`, `ON DELETE CASCADE` |
| material | `VARCHAR(60)` | `NOT NULL` |
| cor | `VARCHAR(40)` | `NOT NULL` |
| tamanho | `VARCHAR(30)` | `NOT NULL` |
| tipo_alca | `VARCHAR(40)` | `NOT NULL` |

## acessorio *(subtipo de produto)*

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_produto** | `INT` | **PK** e **FK** → `produto.id_produto`, `ON DELETE CASCADE` |
| material | `VARCHAR(60)` | `NOT NULL` |
| cor | `VARCHAR(40)` | `NOT NULL` |
| tipo_acessorio | `VARCHAR(40)` | `NOT NULL` |
| compatibilidade | `VARCHAR(120)` | opcional |

## ficha_tecnica *(associativa, chave composta)*

| Coluna | Tipo | Restrições |
|---|---|---|
| **produto_id** | `INT` | **PK (composta)** e **FK** → `produto.id_produto`, `ON DELETE CASCADE` |
| **insumo_id** | `INT` | **PK (composta)** e **FK** → `insumo.id_insumo` |
| quantidade_necessaria | `DECIMAL(10,3)` | `NOT NULL`, `CHECK > 0` |

## cliente

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_cliente** | `INT` | **PK**, `AUTO_INCREMENT` |
| nome | `VARCHAR(150)` | `NOT NULL` |
| cpf | `VARCHAR(14)` | `NOT NULL`, `UNIQUE` |
| telefone | `VARCHAR(20)` | |
| email | `VARCHAR(120)` | |
| endereco | `VARCHAR(200)` | |
| data_cadastro | `DATE` | `NOT NULL`, padrão data atual |

## pedido

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_pedido** | `INT` | **PK**, `AUTO_INCREMENT` |
| *cliente_id* | `INT` | **FK** → `cliente.id_cliente`, `NOT NULL` |
| data_pedido | `DATE` | `NOT NULL`, padrão data atual |
| status | `VARCHAR(20)` | `NOT NULL`, padrão `'Aberto'`, `CHECK IN ('Aberto','Faturado','Expedido','Cancelado')` |
| valor_total | `DECIMAL(10,2)` | `NOT NULL`, padrão `0` — denormalização controlada (ver `RELATORIO_TECNICO.md` §1.4) |
| forma_pagamento | `VARCHAR(10)` | `CHECK IN ('PIX','Cartao','Boleto')` |
| observacoes | `VARCHAR(255)` | opcional |

## item_pedido *(associativa, identificador próprio)*

| Coluna | Tipo | Restrições |
|---|---|---|
| **id_item_pedido** | `INT` | **PK**, `AUTO_INCREMENT` |
| *pedido_id* | `INT` | **FK** → `pedido.id_pedido`, `NOT NULL`, `ON DELETE CASCADE` |
| *produto_id* | `INT` | **FK** → `produto.id_produto`, `NOT NULL` |
| quantidade | `INT` | `NOT NULL`, `CHECK > 0` |
| preco_unitario | `DECIMAL(10,2)` | `NOT NULL`, `CHECK > 0` |
| subtotal | `DECIMAL(10,2)` | `GENERATED ALWAYS AS (quantidade * preco_unitario) STORED` |

---

## Cardinalidades já convertidas

| FK | Tabela "N" | Tabela "1" | Obrigatoriedade |
|---|---|---|---|
| `insumo.fornecedor_id` | insumo | fornecedor | `NOT NULL` (todo insumo tem um fornecedor) |
| `ficha_tecnica.produto_id` | ficha_tecnica | produto | `NOT NULL`, parte da PK |
| `ficha_tecnica.insumo_id` | ficha_tecnica | insumo | `NOT NULL`, parte da PK |
| `bolsa.id_produto` | bolsa | produto | `NOT NULL`, relação 1:1 (PK compartilhada) |
| `acessorio.id_produto` | acessorio | produto | `NOT NULL`, relação 1:1 (PK compartilhada) |
| `item_pedido.produto_id` | item_pedido | produto | `NOT NULL` |
| `item_pedido.pedido_id` | item_pedido | pedido | `NOT NULL` |
| `pedido.cliente_id` | pedido | cliente | `NOT NULL` |

Nenhuma cardinalidade N:N restou no modelo lógico — todas já tinham sido resolvidas por entidades associativas desde o DER conceitual (ver `RELATORIO_TECNICO.md` §1.2).

## Restrições de integridade (resumo)

- **Chave**: toda PK listada acima; `ficha_tecnica` com PK composta impede duplicar o par produto/insumo.
- **Unicidade**: `fornecedor.cnpj`, `cliente.cpf`.
- **Domínio (`CHECK`)**: `categoria_fornecedor`, `unidade_medida`, `tipo_produto`, `status`, `forma_pagamento`, além de todos os `CHECK > 0` / `CHECK >= 0` em preços, estoques e quantidades.
- **Referencial (`FOREIGN KEY`)**: todas as FKs da tabela de cardinalidades acima; `ON DELETE CASCADE` em `bolsa`, `acessorio`, `ficha_tecnica` e `item_pedido` (ver justificativa em `RELATORIO_TECNICO.md` §1.5).
