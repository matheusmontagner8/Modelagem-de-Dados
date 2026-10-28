-- =====================================================================
-- Contrasti Bolsas e Acessórios Ltda — Modelagem de Banco de Dados
-- Entrega 2 — Script SQL completo (Modelo Lógico + Massa de Dados)
--
-- Dialeto: MySQL 8.0+ / 8.4 LTS (AUTO_INCREMENT, CHECK constraints
-- aplicados, GENERATED COLUMN em item_pedido.vl_subtotal).
-- Testado do zero: rode este arquivo inteiro em um servidor vazio.
--
-- v2 (15/10/2026) — reescrito para o modelo de 17 entidades corrigido
-- na Entrega 1 em resposta à avaliação do professor (issue #1): colunas
-- renomeadas para o padrão de prefixos (id_/nm_/ds_/dt_/vl_/qt_/pc_/tp_/
-- nr_/un_), FORNECEDOR-INSUMO direto substituído por LOTE_INSUMO,
-- FICHA_TECNICA com chave própria, e 8 tabelas novas: lote_insumo,
-- ordem_producao, etapa_producao, artesao, execucao_etapa,
-- vendedor, contas_receber, contas_pagar.
--
-- Organização do arquivo (mesma ordem pedida no esqueleto da Entrega 2):
--   1. CREATE DATABASE
--   2. CREATE TABLE (17 tabelas, uma por entidade da Entrega 1)
--   3. Constraints (já embutidas nos CREATE TABLE: PK, FK, NOT NULL,
--      UNIQUE, CHECK)
--   4. INSERT INTO (massa de dados fictícia)
--   5. SELECT com JOIN
--   6. UPDATE
--   7. DELETE
--   8. Consultas gerenciais
--   9. Consultas de auditoria
-- =====================================================================


-- =====================================================================
-- 1) CREATE DATABASE
-- =====================================================================
DROP DATABASE IF EXISTS contrasti_bolsas;
CREATE DATABASE contrasti_bolsas CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE contrasti_bolsas;


-- =====================================================================
-- 2) CREATE TABLE  +  3) CONSTRAINTS
-- =====================================================================

-- FORNECEDOR ------------------------------------------------------------
CREATE TABLE fornecedor (
    id_fornecedor INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nm_fornecedor VARCHAR(150) NOT NULL,
    nr_cnpj       VARCHAR(18)  NOT NULL,
    nr_telefone   VARCHAR(20),
    ds_email      VARCHAR(160),
    ds_endereco   VARCHAR(200),
    dt_cadastro   DATE NOT NULL DEFAULT (CURRENT_DATE),
    tp_categoria  VARCHAR(30) NOT NULL,
    CONSTRAINT uq_fornecedor_cnpj      UNIQUE (nr_cnpj),
    CONSTRAINT ck_fornecedor_categoria CHECK (tp_categoria IN ('Couro','Ferragem','Ziper','Embalagem'))
);

-- INSUMO ------------------------------------------------------------------
-- Sem FK direta para fornecedor: a origem de cada recebimento agora é
-- registrada por LOTE_INSUMO (um insumo pode vir de fornecedores
-- diferentes ao longo do tempo — ver nota na Entrega 1, Critério 10).
CREATE TABLE insumo (
    id_insumo           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nm_insumo            VARCHAR(120)  NOT NULL,
    tp_insumo            VARCHAR(30)   NOT NULL,
    un_medida            VARCHAR(10)   NOT NULL,
    qt_estoque_minimo    DECIMAL(10,3) NOT NULL DEFAULT 0,
    qt_estoque_atual     DECIMAL(10,3) NOT NULL DEFAULT 0,
    vl_preco_referencia  DECIMAL(10,2) NOT NULL,
    CONSTRAINT ck_insumo_unidade     CHECK (un_medida IN ('DM2','M2','UN','M','KG','L')),
    CONSTRAINT ck_insumo_estoque     CHECK (qt_estoque_atual >= 0),
    CONSTRAINT ck_insumo_estoque_min CHECK (qt_estoque_minimo >= 0),
    CONSTRAINT ck_insumo_preco       CHECK (vl_preco_referencia > 0)
);

-- LOTE_INSUMO (nova) -------------------------------------------------------
-- Cada recebimento de insumo, por lote e fornecedor — resolve a
-- contradição apontada pelo professor (FORNECEDOR–INSUMO (1,1) não
-- permitia múltiplos fornecedores para o mesmo insumo ao longo do tempo).
CREATE TABLE lote_insumo (
    id_lote           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    insumo_id         INT UNSIGNED NOT NULL,
    fornecedor_id     INT UNSIGNED NOT NULL,
    nr_lote           VARCHAR(30) NOT NULL,
    dt_recebimento    DATE NOT NULL,
    qt_recebida       DECIMAL(10,3) NOT NULL,
    vl_preco_pago     DECIMAL(10,2) NOT NULL,
    ds_cor_tonalidade VARCHAR(60),
    CONSTRAINT fk_lote_insumo     FOREIGN KEY (insumo_id)     REFERENCES insumo(id_insumo),
    CONSTRAINT fk_lote_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id_fornecedor),
    CONSTRAINT ck_lote_qtd        CHECK (qt_recebida > 0),
    CONSTRAINT ck_lote_preco      CHECK (vl_preco_pago > 0)
);

-- PRODUTO (supertipo) -----------------------------------------------------
-- tp_produto é o discriminador da especialização TD (Total e Disjunta):
-- toda linha de produto tem que ter uma linha correspondente em BOLSA
-- OU em ACESSORIO (nunca nas duas) — ver auditoria 9.4.
CREATE TABLE produto (
    id_produto        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nm_produto        VARCHAR(120)  NOT NULL,
    ds_descricao      VARCHAR(255),
    vl_preco_base     DECIMAL(10,2) NOT NULL,
    tp_categoria      VARCHAR(50),
    qt_estoque_total  INT UNSIGNED NOT NULL DEFAULT 0,
    tp_produto        VARCHAR(10) NOT NULL,
    CONSTRAINT ck_produto_preco CHECK (vl_preco_base > 0),
    CONSTRAINT ck_produto_tipo  CHECK (tp_produto IN ('BOLSA','ACESSORIO'))
);

-- BOLSA (subtipo de PRODUTO) ------------------------------------------------
-- Estratégia "tabela por subtipo": id_produto é PK e também FK para
-- PRODUTO (relacionamento 1:1 que implementa a especialização).
CREATE TABLE bolsa (
    id_produto  INT UNSIGNED PRIMARY KEY,
    ds_material VARCHAR(60) NOT NULL,
    ds_cor      VARCHAR(40) NOT NULL,
    tp_tamanho  VARCHAR(20) NOT NULL,
    tp_alca     VARCHAR(30) NOT NULL,
    CONSTRAINT fk_bolsa_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE CASCADE
);

-- ACESSORIO (subtipo de PRODUTO) --------------------------------------------
CREATE TABLE acessorio (
    id_produto         INT UNSIGNED PRIMARY KEY,
    ds_material        VARCHAR(60) NOT NULL,
    ds_cor             VARCHAR(40) NOT NULL,
    tp_acessorio       VARCHAR(30) NOT NULL,
    ds_compatibilidade VARCHAR(120),
    CONSTRAINT fk_acessorio_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE CASCADE
);

-- FICHA_TECNICA (associativa, agora com CHAVE PRÓPRIA) ---------------------
-- A versão anterior usava produto_id+insumo_id como PK composta por FKs
-- ("FK como identificador", apontado como agravante pelo professor).
-- id_ficha resolve isso sem perder a regra "cada par aparece uma única
-- vez" (garantida pelo UNIQUE abaixo).
CREATE TABLE ficha_tecnica (
    id_ficha       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    produto_id     INT UNSIGNED NOT NULL,
    insumo_id      INT UNSIGNED NOT NULL,
    qt_necessaria  DECIMAL(10,3) NOT NULL,
    un_medida_item VARCHAR(10) NOT NULL,
    CONSTRAINT fk_ficha_produto        FOREIGN KEY (produto_id) REFERENCES produto(id_produto) ON DELETE CASCADE,
    CONSTRAINT fk_ficha_insumo         FOREIGN KEY (insumo_id)  REFERENCES insumo(id_insumo),
    CONSTRAINT uq_ficha_produto_insumo UNIQUE (produto_id, insumo_id),
    CONSTRAINT ck_ficha_qtd            CHECK (qt_necessaria > 0)
);

-- ORDEM_PRODUCAO (nova, essencial) -----------------------------------------
-- Apontada como ausência essencial pelo professor (Critério 10): sem ela
-- não havia onde registrar o processo de fabricação já descrito no README.
CREATE TABLE ordem_producao (
    id_op            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    produto_id       INT UNSIGNED NOT NULL,
    nr_op            VARCHAR(20) NOT NULL,
    dt_abertura      DATE NOT NULL,
    qt_produzir      INT UNSIGNED NOT NULL,
    tp_status_kanban VARCHAR(20) NOT NULL,
    CONSTRAINT fk_op_produto FOREIGN KEY (produto_id) REFERENCES produto(id_produto),
    CONSTRAINT uq_op_numero  UNIQUE (nr_op),
    CONSTRAINT ck_op_qtd     CHECK (qt_produzir > 0),
    CONSTRAINT ck_op_status  CHECK (tp_status_kanban IN ('aberta','em producao','concluida','cancelada'))
);

-- ETAPA_PRODUCAO (nova, tabela de domínio) ----------------------------------
-- Etapas padrão do processo produtivo (README, Seção 2, processo 5).
CREATE TABLE etapa_producao (
    id_etapa            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nm_etapa             VARCHAR(60) NOT NULL,
    nr_ordem_sequencial  SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT uq_etapa_ordem UNIQUE (nr_ordem_sequencial)
);

-- ARTESAO (nova) ------------------------------------------------------
CREATE TABLE artesao (
    id_artesao  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nm_artesao  VARCHAR(120) NOT NULL,
    tp_vinculo  VARCHAR(20) NOT NULL,
    nr_telefone VARCHAR(20),
    CONSTRAINT ck_artesao_vinculo CHECK (tp_vinculo IN ('interno','faccao terceirizada'))
);

-- EXECUCAO_ETAPA (nova, associativa de três vias) ----------------------------
-- Liga ORDEM_PRODUCAO a ETAPA_PRODUCAO executada por um ARTESAO.
-- pc_aproveitamento/pc_perda sustentam a regra de pagamento por etapa (RF15).
CREATE TABLE execucao_etapa (
    id_execucao        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    op_id              INT UNSIGNED NOT NULL,
    etapa_id           INT UNSIGNED NOT NULL,
    artesao_id         INT UNSIGNED NOT NULL,
    dt_inicio          DATETIME NOT NULL,
    dt_fim             DATETIME,
    pc_aproveitamento  DECIMAL(5,2),
    pc_perda           DECIMAL(5,2),
    CONSTRAINT fk_execucao_op       FOREIGN KEY (op_id)      REFERENCES ordem_producao(id_op) ON DELETE CASCADE,
    CONSTRAINT fk_execucao_etapa    FOREIGN KEY (etapa_id)   REFERENCES etapa_producao(id_etapa),
    CONSTRAINT fk_execucao_artesao  FOREIGN KEY (artesao_id) REFERENCES artesao(id_artesao),
    CONSTRAINT ck_execucao_aprov CHECK (pc_aproveitamento IS NULL OR pc_aproveitamento BETWEEN 0 AND 100),
    CONSTRAINT ck_execucao_perda CHECK (pc_perda IS NULL OR pc_perda BETWEEN 0 AND 100)
);

-- CLIENTE -------------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nm_cliente    VARCHAR(150) NOT NULL,
    nr_cpf        VARCHAR(14)  NOT NULL,
    nr_telefone   VARCHAR(20),
    ds_email      VARCHAR(160),
    ds_endereco   VARCHAR(200),
    dt_cadastro   DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT uq_cliente_cpf UNIQUE (nr_cpf)
);

-- VENDEDOR (nova) ------------------------------------------------------------
-- Sustenta a regra de comissão por canal (README, Seção 4).
CREATE TABLE vendedor (
    id_vendedor  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nm_vendedor  VARCHAR(120) NOT NULL,
    tp_vinculo   VARCHAR(25) NOT NULL,
    pc_comissao  DECIMAL(5,2) NOT NULL,
    CONSTRAINT ck_vendedor_vinculo CHECK (tp_vinculo IN ('interno','representante externo'))
);

-- PEDIDO ----------------------------------------------------------------
-- vl_total é mantido por recálculo explícito (ver Seção 6 — UPDATE) em
-- vez de GENERATED COLUMN, porque depende de uma soma em OUTRA tabela
-- (item_pedido) — denormalização deliberada, discutida em
-- RELATORIO_TECNICO.md §1.4.
CREATE TABLE pedido (
    id_pedido       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cliente_id      INT UNSIGNED NOT NULL,
    vendedor_id     INT UNSIGNED NOT NULL,
    dt_pedido       DATE NOT NULL DEFAULT (CURRENT_DATE),
    tp_status       VARCHAR(20) NOT NULL DEFAULT 'Aberto',
    vl_total        DECIMAL(10,2) NOT NULL DEFAULT 0,
    tp_pagamento    VARCHAR(10),
    tp_canal        VARCHAR(20) NOT NULL,
    ds_observacoes  VARCHAR(255),
    CONSTRAINT fk_pedido_cliente  FOREIGN KEY (cliente_id)  REFERENCES cliente(id_cliente),
    CONSTRAINT fk_pedido_vendedor FOREIGN KEY (vendedor_id) REFERENCES vendedor(id_vendedor),
    CONSTRAINT ck_pedido_status    CHECK (tp_status IN ('Aberto','Faturado','Expedido','Cancelado')),
    CONSTRAINT ck_pedido_pagamento CHECK (tp_pagamento IN ('PIX','Cartao','Boleto')),
    CONSTRAINT ck_pedido_canal     CHECK (tp_canal IN ('loja fisica','e-commerce','atacado'))
);

-- ITEM_PEDIDO (associativa, identificador próprio) -----------------
-- vl_subtotal é coluna gerada (depende só de colunas da própria linha).
CREATE TABLE item_pedido (
    id_item_pedido    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pedido_id         INT UNSIGNED NOT NULL,
    produto_id        INT UNSIGNED NOT NULL,
    qt_quantidade     INT UNSIGNED NOT NULL,
    vl_preco_unitario DECIMAL(10,2) NOT NULL,
    vl_desconto       DECIMAL(10,2) NOT NULL DEFAULT 0,
    vl_subtotal       DECIMAL(10,2) GENERATED ALWAYS AS (qt_quantidade * vl_preco_unitario - vl_desconto) STORED,
    CONSTRAINT fk_item_pedido_pedido  FOREIGN KEY (pedido_id)  REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_item_pedido_produto FOREIGN KEY (produto_id) REFERENCES produto(id_produto),
    CONSTRAINT ck_item_qtd      CHECK (qt_quantidade > 0),
    CONSTRAINT ck_item_preco    CHECK (vl_preco_unitario > 0),
    CONSTRAINT ck_item_desconto CHECK (vl_desconto >= 0)
);

-- CONTAS_RECEBER (nova) -------------------------------------------------------
-- Título gerado a partir de um pedido faturado/expedido (RF22).
CREATE TABLE contas_receber (
    id_titulo_receber INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pedido_id         INT UNSIGNED NOT NULL,
    vl_valor          DECIMAL(10,2) NOT NULL,
    dt_vencimento     DATE NOT NULL,
    dt_recebimento    DATE,
    tp_status         VARCHAR(15) NOT NULL,
    CONSTRAINT fk_receber_pedido FOREIGN KEY (pedido_id) REFERENCES pedido(id_pedido),
    CONSTRAINT ck_receber_valor  CHECK (vl_valor > 0),
    CONSTRAINT ck_receber_status CHECK (tp_status IN ('em aberto','pago','atrasado','cancelado'))
);

-- CONTAS_PAGAR (nova) ----------------------------------------------------------
-- Título gerado a partir de um lote de insumo recebido (RF22).
CREATE TABLE contas_pagar (
    id_titulo_pagar INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    lote_id         INT UNSIGNED NOT NULL,
    vl_valor        DECIMAL(10,2) NOT NULL,
    dt_vencimento   DATE NOT NULL,
    dt_pagamento    DATE,
    tp_status       VARCHAR(15) NOT NULL,
    CONSTRAINT fk_pagar_lote   FOREIGN KEY (lote_id) REFERENCES lote_insumo(id_lote),
    CONSTRAINT ck_pagar_valor  CHECK (vl_valor > 0),
    CONSTRAINT ck_pagar_status CHECK (tp_status IN ('em aberto','pago','atrasado','cancelado'))
);


-- =====================================================================
-- 4) INSERT INTO — massa de dados (fictícia, coerente com a operação
--    observada: couro/ferragens/zíperes/forro/embalagens, bolsas e
--    acessórios, produção por etapa, clientes variados, pedidos em
--    múltiplos canais/status, financeiro básico)
-- =====================================================================

-- FORNECEDOR (5) ------------------------------------------------------------
INSERT INTO fornecedor (id_fornecedor, nm_fornecedor, nr_cnpj, nr_telefone, ds_email, ds_endereco, dt_cadastro, tp_categoria) VALUES
(1, 'Curtume Vaqueta Ouro Ltda', '12.345.678/0001-90', '(11) 3344-1001', 'vendas@vaquetaouro.com.br', 'Rua dos Curtumes, 120 - Franca/SP', '2024-02-10', 'Couro'),
(2, 'Metalurgica Fivelas & Cia', '23.456.789/0001-01', '(11) 3344-1002', 'comercial@fivelascia.com.br', 'Av. Industrial, 850 - Diadema/SP', '2024-02-15', 'Ferragem'),
(3, 'Ziperes Uniao Comercial', '34.567.890/0001-12', '(11) 3344-1003', 'contato@zipuniao.com.br', 'Rua Capri, 45 - Sao Paulo/SP', '2024-03-01', 'Ziper'),
(4, 'Embalagens Protecao Total', '45.678.901/0001-23', '(11) 3344-1004', 'pedidos@protecaototal.com.br', 'Rua das Caixas, 300 - Guarulhos/SP', '2024-03-20', 'Embalagem'),
(5, 'Curtume Linhares Couros', '56.789.012/0001-34', '(11) 3344-1005', 'comercial@linharescouros.com.br', 'Rod. dos Curtumes, km 12 - Franca/SP', '2024-04-05', 'Couro');

-- INSUMO (10) -----------------------------------------------------------
-- insumo 10 (Caixa de Papelão Kraft) é deixado deliberadamente sem lote
-- e sem uso em ficha técnica — ver Seção 7.2 (DELETE) e Seção 9.3/9.6
-- (auditoria).
INSERT INTO insumo (id_insumo, nm_insumo, tp_insumo, un_medida, qt_estoque_minimo, qt_estoque_atual, vl_preco_referencia) VALUES
(1, 'Couro Bovino Caramelo', 'Couro', 'M2', 60.0, 320.0, 85.0),
(2, 'Couro Bovino Preto', 'Couro', 'M2', 60.0, 410.0, 82.0),
(3, 'Couro Sintetico Cafe', 'Couro', 'M2', 30.0, 150.0, 38.0),
(4, 'Fivela Metal Dourada', 'Ferragem', 'UN', 80.0, 540.0, 4.5),
(5, 'Fivela Metal Prata', 'Ferragem', 'UN', 80.0, 480.0, 4.2),
(6, 'Ziper Nylon 20cm', 'Ziper', 'UN', 100.0, 620.0, 2.8),
(7, 'Ziper Metalico 15cm', 'Ziper', 'UN', 60.0, 300.0, 3.9),
(8, 'Linha de Costura Encerada', 'Ferragem', 'M', 200.0, 1200.0, 0.35),
(9, 'Forro Sintetico Bege', 'Forro', 'M2', 40.0, 200.0, 18.0),
(10, 'Caixa de Papelao Kraft', 'Embalagem', 'UN', 0.0, 0.0, 3.2);

-- LOTE_INSUMO (10) -----------------------------------------------------
-- insumo 1 (couro caramelo) tem lotes de DOIS fornecedores diferentes
-- (1 e 5) — exatamente o cenário que a relação direta FORNECEDOR-INSUMO
-- (1,1) da versão anterior não conseguia representar.
INSERT INTO lote_insumo (id_lote, insumo_id, fornecedor_id, nr_lote, dt_recebimento, qt_recebida, vl_preco_pago, ds_cor_tonalidade) VALUES
(1, 1, 1, 'LT-2025-0310-A', '2025-03-10', 40.0, 84.5, 'Caramelo claro'),
(2, 1, 5, 'LT-2025-0620-C', '2025-06-20', 35.0, 86.9, 'Caramelo escuro'),
(3, 2, 1, 'LT-2025-0310-B', '2025-03-10', 45.0, 81.8, 'Preto fosco'),
(4, 3, 5, 'LT-2025-0315-A', '2025-03-15', 32.0, 37.5, 'Cafe'),
(5, 4, 2, 'LT-2025-0220-A', '2025-02-20', 60.0, 4.4, NULL),
(6, 5, 2, 'LT-2025-0220-B', '2025-02-20', 55.0, 4.15, NULL),
(7, 6, 3, 'LT-2025-0225-A', '2025-02-25', 70.0, 2.75, NULL),
(8, 7, 3, 'LT-2025-0225-B', '2025-02-25', 40.0, 3.85, NULL),
(9, 8, 2, 'LT-2025-0228-A', '2025-02-28', 250.0, 0.34, NULL),
(10, 9, 5, 'LT-2025-0318-A', '2025-03-18', 45.0, 17.6, 'Bege claro');

-- PRODUTO (8: 5 bolsas + 3 acessórios) --------------------------------------
INSERT INTO produto (id_produto, nm_produto, ds_descricao, vl_preco_base, tp_categoria, qt_estoque_total, tp_produto) VALUES
(1, 'Bolsa Tote Caramelo', 'Bolsa tote em couro legitimo, uso diario/executivo', 480.0, 'Linha Executiva', 18, 'BOLSA'),
(2, 'Bolsa Tote Preta', 'Bolsa tote em couro legitimo, uso diario/executivo', 480.0, 'Linha Executiva', 22, 'BOLSA'),
(3, 'Bolsa Tiracolo Mini Cafe', 'Bolsa pequena tiracolo, couro sintetico', 320.0, 'Linha Casual', 30, 'BOLSA'),
(4, 'Bolsa Transversal Urbana', 'Bolsa transversal compacta, uso casual', 295.0, 'Linha Casual', 25, 'BOLSA'),
(5, 'Bolsa Shopper Grande', 'Bolsa grande estruturada, uso executivo', 410.0, 'Linha Executiva', 15, 'BOLSA'),
(6, 'Cinto Couro Classico', 'Cinto em couro bovino, fivela metalica', 95.0, 'Acessorios', 40, 'ACESSORIO'),
(7, 'Porta-Cartoes Slim', 'Porta-cartoes compacto em couro sintetico', 65.0, 'Acessorios', 55, 'ACESSORIO'),
(8, 'Carteira Compacta', 'Carteira em couro bovino com fecho ziper', 120.0, 'Acessorios', 35, 'ACESSORIO');

-- BOLSA (subtipo) ---------------------------------------------------------
INSERT INTO bolsa (id_produto, ds_material, ds_cor, tp_tamanho, tp_alca) VALUES
(1, 'Couro Bovino', 'Caramelo', 'Medio', 'Tiracolo'),
(2, 'Couro Bovino', 'Preto', 'Medio', 'Tiracolo'),
(3, 'Couro Sintetico', 'Cafe', 'Pequeno', 'Transversal'),
(4, 'Couro Bovino', 'Preto', 'Pequeno', 'Transversal'),
(5, 'Couro Bovino', 'Caramelo', 'Grande', 'Mao');

-- ACESSORIO (subtipo) -------------------------------------------------------
INSERT INTO acessorio (id_produto, ds_material, ds_cor, tp_acessorio, ds_compatibilidade) VALUES
(6, 'Couro Bovino', 'Preto', 'Cinto', 'Combina com toda a linha executiva'),
(7, 'Couro Sintetico', 'Cafe', 'Porta-cartoes', NULL),
(8, 'Couro Bovino', 'Caramelo', 'Carteira', NULL);

-- FICHA_TECNICA (BOM, 23 linhas) -------------------------------------------
INSERT INTO ficha_tecnica (id_ficha, produto_id, insumo_id, qt_necessaria, un_medida_item) VALUES
(1, 1, 1, 1.8, 'M2'), (2, 1, 4, 2.0, 'UN'), (3, 1, 8, 12.0, 'M'), (4, 1, 9, 1.8, 'M2'),
(5, 2, 2, 1.8, 'M2'), (6, 2, 5, 2.0, 'UN'), (7, 2, 8, 12.0, 'M'), (8, 2, 9, 1.8, 'M2'),
(9, 3, 3, 0.9, 'M2'), (10, 3, 7, 1.0, 'UN'), (11, 3, 8, 6.0, 'M'),
(12, 4, 2, 1.0, 'M2'), (13, 4, 6, 1.0, 'UN'), (14, 4, 8, 7.0, 'M'),
(15, 5, 1, 2.4, 'M2'), (16, 5, 4, 2.0, 'UN'), (17, 5, 8, 15.0, 'M'), (18, 5, 9, 2.4, 'M2'),
(19, 6, 2, 0.3, 'M2'), (20, 6, 4, 1.0, 'UN'),
(21, 7, 3, 0.15, 'M2'),
(22, 8, 1, 0.4, 'M2'), (23, 8, 6, 1.0, 'UN');

-- ORDEM_PRODUCAO (8: uma por produto) ---------------------------------------
-- OP-2025-008 (Carteira Compacta) ainda "em producao" — único caso com
-- etapas finais em aberto (ver EXECUCAO_ETAPA abaixo).
INSERT INTO ordem_producao (id_op, produto_id, nr_op, dt_abertura, qt_produzir, tp_status_kanban) VALUES
(1, 1, 'OP-2025-001', '2025-03-20', 18, 'concluida'),
(2, 2, 'OP-2025-002', '2025-03-21', 22, 'concluida'),
(3, 3, 'OP-2025-003', '2025-03-24', 30, 'concluida'),
(4, 4, 'OP-2025-004', '2025-03-25', 25, 'concluida'),
(5, 5, 'OP-2025-005', '2025-03-27', 15, 'concluida'),
(6, 6, 'OP-2025-006', '2025-03-28', 40, 'concluida'),
(7, 7, 'OP-2025-007', '2025-03-28', 55, 'concluida'),
(8, 8, 'OP-2025-008', '2025-09-15', 35, 'em producao');

-- ETAPA_PRODUCAO (7, sequência fixa do chão de fábrica) ----------------------
INSERT INTO etapa_producao (id_etapa, nm_etapa, nr_ordem_sequencial) VALUES
(1, 'Modelagem', 1), (2, 'Corte', 2), (3, 'Preparacao/Colagem', 3),
(4, 'Costura', 4), (5, 'Montagem/Ferragens', 5),
(6, 'Acabamento/Revisao', 6), (7, 'Embalagem', 7);

-- ARTESAO (4: 2 internos, 2 facções terceirizadas) --------------------
INSERT INTO artesao (id_artesao, nm_artesao, tp_vinculo, nr_telefone) VALUES
(1, 'Everton Souza Lima', 'interno', '(11) 98777-1001'),
(2, 'Rosa Maria Aparecida', 'interno', '(11) 98777-1002'),
(3, 'Faccao Mao de Obra Franca', 'faccao terceirizada', '(16) 98777-1003'),
(4, 'Faccao Costura Fina Ltda', 'faccao terceirizada', '(16) 98777-1004');

-- EXECUCAO_ETAPA (56 = 8 OPs x 7 etapas) -------------------------------------
-- pc_aproveitamento/pc_perda só são preenchidos na etapa de Corte (id 2),
-- conforme RF15 ("percentual de aproveitamento/perda de couro na etapa
-- de Corte"). As 3 últimas etapas de OP-2025-008 ainda não começaram
-- (dt_fim NULL), coerente com seu status 'em producao'.
INSERT INTO execucao_etapa (id_execucao, op_id, etapa_id, artesao_id, dt_inicio, dt_fim, pc_aproveitamento, pc_perda) VALUES
(1, 1, 1, 3, '2025-03-20 08:00:00', '2025-03-21 17:00:00', NULL, NULL),
(2, 1, 2, 4, '2025-03-21 08:00:00', '2025-03-22 17:00:00', 89.5, 10.5),
(3, 1, 3, 1, '2025-03-22 08:00:00', '2025-03-23 17:00:00', NULL, NULL),
(4, 1, 4, 2, '2025-03-23 08:00:00', '2025-03-24 17:00:00', NULL, NULL),
(5, 1, 5, 3, '2025-03-24 08:00:00', '2025-03-25 17:00:00', NULL, NULL),
(6, 1, 6, 4, '2025-03-25 08:00:00', '2025-03-26 17:00:00', NULL, NULL),
(7, 1, 7, 1, '2025-03-26 08:00:00', '2025-03-27 17:00:00', NULL, NULL),
(8, 2, 1, 4, '2025-03-21 08:00:00', '2025-03-22 17:00:00', NULL, NULL),
(9, 2, 2, 1, '2025-03-22 08:00:00', '2025-03-23 17:00:00', 91.6, 8.4),
(10, 2, 3, 2, '2025-03-23 08:00:00', '2025-03-24 17:00:00', NULL, NULL),
(11, 2, 4, 3, '2025-03-24 08:00:00', '2025-03-25 17:00:00', NULL, NULL),
(12, 2, 5, 4, '2025-03-25 08:00:00', '2025-03-26 17:00:00', NULL, NULL),
(13, 2, 6, 1, '2025-03-26 08:00:00', '2025-03-27 17:00:00', NULL, NULL),
(14, 2, 7, 2, '2025-03-27 08:00:00', '2025-03-28 17:00:00', NULL, NULL),
(15, 3, 1, 1, '2025-03-24 08:00:00', '2025-03-25 17:00:00', NULL, NULL),
(16, 3, 2, 2, '2025-03-25 08:00:00', '2025-03-26 17:00:00', 86.7, 13.3),
(17, 3, 3, 3, '2025-03-26 08:00:00', '2025-03-27 17:00:00', NULL, NULL),
(18, 3, 4, 4, '2025-03-27 08:00:00', '2025-03-28 17:00:00', NULL, NULL),
(19, 3, 5, 1, '2025-03-28 08:00:00', '2025-03-29 17:00:00', NULL, NULL),
(20, 3, 6, 2, '2025-03-29 08:00:00', '2025-03-30 17:00:00', NULL, NULL),
(21, 3, 7, 3, '2025-03-30 08:00:00', '2025-03-31 17:00:00', NULL, NULL),
(22, 4, 1, 2, '2025-03-25 08:00:00', '2025-03-26 17:00:00', NULL, NULL),
(23, 4, 2, 3, '2025-03-26 08:00:00', '2025-03-27 17:00:00', 88.8, 11.2),
(24, 4, 3, 4, '2025-03-27 08:00:00', '2025-03-28 17:00:00', NULL, NULL),
(25, 4, 4, 1, '2025-03-28 08:00:00', '2025-03-29 17:00:00', NULL, NULL),
(26, 4, 5, 2, '2025-03-29 08:00:00', '2025-03-30 17:00:00', NULL, NULL),
(27, 4, 6, 3, '2025-03-30 08:00:00', '2025-03-31 17:00:00', NULL, NULL),
(28, 4, 7, 4, '2025-03-31 08:00:00', '2025-04-01 17:00:00', NULL, NULL),
(29, 5, 1, 3, '2025-03-27 08:00:00', '2025-03-28 17:00:00', NULL, NULL),
(30, 5, 2, 4, '2025-03-28 08:00:00', '2025-03-29 17:00:00', 90.9, 9.1),
(31, 5, 3, 1, '2025-03-29 08:00:00', '2025-03-30 17:00:00', NULL, NULL),
(32, 5, 4, 2, '2025-03-30 08:00:00', '2025-03-31 17:00:00', NULL, NULL),
(33, 5, 5, 3, '2025-03-31 08:00:00', '2025-04-01 17:00:00', NULL, NULL),
(34, 5, 6, 4, '2025-04-01 08:00:00', '2025-04-02 17:00:00', NULL, NULL),
(35, 5, 7, 1, '2025-04-02 08:00:00', '2025-04-03 17:00:00', NULL, NULL),
(36, 6, 1, 4, '2025-03-28 08:00:00', '2025-03-29 17:00:00', NULL, NULL),
(37, 6, 2, 1, '2025-03-29 08:00:00', '2025-03-30 17:00:00', 86.0, 14.0),
(38, 6, 3, 2, '2025-03-30 08:00:00', '2025-03-31 17:00:00', NULL, NULL),
(39, 6, 4, 3, '2025-03-31 08:00:00', '2025-04-01 17:00:00', NULL, NULL),
(40, 6, 5, 4, '2025-04-01 08:00:00', '2025-04-02 17:00:00', NULL, NULL),
(41, 6, 6, 1, '2025-04-02 08:00:00', '2025-04-03 17:00:00', NULL, NULL),
(42, 6, 7, 2, '2025-04-03 08:00:00', '2025-04-04 17:00:00', NULL, NULL),
(43, 7, 1, 1, '2025-03-28 08:00:00', '2025-03-29 17:00:00', NULL, NULL),
(44, 7, 2, 2, '2025-03-29 08:00:00', '2025-03-30 17:00:00', 88.1, 11.9),
(45, 7, 3, 3, '2025-03-30 08:00:00', '2025-03-31 17:00:00', NULL, NULL),
(46, 7, 4, 4, '2025-03-31 08:00:00', '2025-04-01 17:00:00', NULL, NULL),
(47, 7, 5, 1, '2025-04-01 08:00:00', '2025-04-02 17:00:00', NULL, NULL),
(48, 7, 6, 2, '2025-04-02 08:00:00', '2025-04-03 17:00:00', NULL, NULL),
(49, 7, 7, 3, '2025-04-03 08:00:00', '2025-04-04 17:00:00', NULL, NULL),
(50, 8, 1, 2, '2025-09-15 08:00:00', '2025-09-16 17:00:00', NULL, NULL),
(51, 8, 2, 3, '2025-09-16 08:00:00', '2025-09-17 17:00:00', 90.2, 9.8),
(52, 8, 3, 4, '2025-09-17 08:00:00', '2025-09-18 17:00:00', NULL, NULL),
(53, 8, 4, 1, '2025-09-18 08:00:00', '2025-09-19 17:00:00', NULL, NULL),
(54, 8, 5, 2, '2025-09-19 08:00:00', NULL, NULL, NULL),
(55, 8, 6, 3, '2025-09-20 08:00:00', NULL, NULL, NULL),
(56, 8, 7, 4, '2025-09-21 08:00:00', NULL, NULL, NULL);

-- CLIENTE (10) ---------------------------------------------------------
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, nr_telefone, ds_email, ds_endereco, dt_cadastro) VALUES
(1, 'Mariana Alves Ferreira', '111.111.111-01', '(11) 98888-0001', 'mariana.ferreira@email.com', 'Rua das Palmeiras, 220 - Sao Paulo/SP', '2025-01-10'),
(2, 'Joao Pedro Santos', '111.111.111-02', '(11) 98888-0002', 'joaopedro.santos@email.com', 'Av. Brasil, 1500 - Sao Paulo/SP', '2025-01-15'),
(3, 'Camila Rodrigues Lima', '111.111.111-03', '(11) 98888-0003', 'camila.lima@email.com', 'Rua Tupi, 88 - Sao Paulo/SP', '2025-01-22'),
(4, 'Studio Elegance Multimarcas Ltda', '111.111.111-04', '(11) 98888-0004', 'compras@studioelegance.com', 'Rua Augusta, 900 - Sao Paulo/SP', '2025-02-02'),
(5, 'Fernanda Costa Dias', '111.111.111-05', '(11) 98888-0005', 'fernanda.dias@email.com', 'Rua Vergueiro, 2100 - Sao Paulo/SP', '2025-02-10'),
(6, 'Lucas Martins Oliveira', '111.111.111-06', '(11) 98888-0006', 'lucas.oliveira@email.com', 'Av. Paulista, 1200 - Sao Paulo/SP', '2025-02-18'),
(7, 'Patricia Nunes Carvalho', '111.111.111-07', '(11) 98888-0007', 'patricia.carvalho@email.com', 'Rua Oscar Freire, 300 - Sao Paulo/SP', '2025-03-01'),
(8, 'Bazar da Moda Comercio de Bolsas Ltda', '111.111.111-08', '(11) 98888-0008', 'compras@bazardamoda.com', 'Rua 25 de Marco, 450 - Sao Paulo/SP', '2025-03-08'),
(9, 'Rafael Souza Pinto', '111.111.111-09', '(11) 98888-0009', 'rafael.pinto@email.com', 'Rua Haddock Lobo, 77 - Sao Paulo/SP', '2025-03-15'),
(10, 'Juliana Barbosa Rezende', '111.111.111-10', '(11) 98888-0010', 'juliana.rezende@email.com', 'Av. Reboucas, 650 - Sao Paulo/SP', '2025-03-22');

-- VENDEDOR (4: 2 internos a 3%, 2 representantes externos a 7%) -------------
INSERT INTO vendedor (id_vendedor, nm_vendedor, tp_vinculo, pc_comissao) VALUES
(1, 'Bruno Hideki Tanaka', 'interno', 3.0),
(2, 'Carla Fernanda Souza', 'interno', 3.0),
(3, 'Representante Paulo Henrique Miranda', 'representante externo', 7.0),
(4, 'Representante Silvia Gomes Castro', 'representante externo', 7.0);

-- PEDIDO (77) — vl_total inserido como 0 e recalculado na Seção 6 (UPDATE).
-- vendedor_id/tp_canal: clientes "Ltda" (atacado) atendidos por
-- representante externo (3/4); pessoas físicas por vendedor interno
-- (1/2), alternando loja física/e-commerce pela paridade do id_pedido.
INSERT INTO pedido (id_pedido, cliente_id, vendedor_id, dt_pedido, tp_status, vl_total, tp_pagamento, tp_canal, ds_observacoes) VALUES
(1, 1, 2, '2025-04-02', 'Expedido', 0, 'PIX', 'e-commerce', NULL),
(2, 2, 1, '2025-04-03', 'Expedido', 0, 'Cartao', 'loja fisica', NULL),
(3, 3, 2, '2025-04-05', 'Faturado', 0, 'Boleto', 'e-commerce', 'Entrega combinada para sexta-feira'),
(4, 4, 3, '2025-04-08', 'Expedido', 0, 'Boleto', 'atacado', 'Cliente atacado - pedido recorrente'),
(5, 5, 2, '2025-04-10', 'Aberto', 0, 'PIX', 'e-commerce', NULL),
(6, 6, 1, '2025-04-12', 'Expedido', 0, 'Cartao', 'loja fisica', NULL),
(7, 7, 2, '2025-04-15', 'Cancelado', 0, 'PIX', 'e-commerce', 'Cliente desistiu da compra'),
(8, 8, 3, '2025-04-18', 'Faturado', 0, 'Boleto', 'atacado', 'Reposicao de estoque para loja parceira'),
(9, 1, 2, '2025-04-20', 'Expedido', 0, 'Cartao', 'e-commerce', NULL),
(10, 9, 1, '2025-04-22', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(11, 10, 2, '2025-04-25', 'Aberto', 0, 'Cartao', 'e-commerce', NULL),
(12, 3, 1, '2025-04-27', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(13, 6, 2, '2025-05-02', 'Expedido', 0, 'Boleto', 'e-commerce', NULL),
(14, 4, 3, '2025-05-05', 'Faturado', 0, 'Boleto', 'atacado', 'Cliente atacado - pedido recorrente'),
(15, 2, 2, '2025-05-08', 'Aberto', 0, 'PIX', 'e-commerce', NULL),
(16, 7, 1, '2025-09-01', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(17, 6, 2, '2025-09-19', 'Faturado', 0, 'PIX', 'e-commerce', NULL),
(18, 1, 1, '2025-09-07', 'Aberto', 0, 'Cartao', 'loja fisica', NULL),
(19, 2, 2, '2025-09-14', 'Expedido', 0, 'Cartao', 'e-commerce', NULL),
(20, 8, 3, '2025-09-20', 'Expedido', 0, 'PIX', 'atacado', 'Pedido recorrente - cliente atacado'),
(21, 4, 4, '2025-09-07', 'Expedido', 0, 'PIX', 'atacado', NULL),
(22, 4, 3, '2025-09-12', 'Expedido', 0, 'PIX', 'atacado', NULL),
(23, 3, 2, '2025-09-30', 'Aberto', 0, 'PIX', 'e-commerce', NULL),
(24, 3, 1, '2025-09-19', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(25, 6, 2, '2025-09-09', 'Cancelado', 0, 'Cartao', 'e-commerce', NULL),
(26, 2, 1, '2025-09-22', 'Faturado', 0, 'Boleto', 'loja fisica', NULL),
(27, 6, 2, '2025-09-18', 'Expedido', 0, 'Boleto', 'e-commerce', NULL),
(28, 4, 3, '2025-09-24', 'Expedido', 0, 'Boleto', 'atacado', NULL),
(29, 8, 4, '2025-09-18', 'Aberto', 0, 'PIX', 'atacado', 'Pedido recorrente - cliente atacado'),
(30, 3, 1, '2025-09-19', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(31, 10, 2, '2025-09-06', 'Expedido', 0, 'Boleto', 'e-commerce', NULL),
(32, 4, 3, '2025-09-17', 'Faturado', 0, 'PIX', 'atacado', 'Pedido recorrente - cliente atacado'),
(33, 6, 2, '2025-09-01', 'Expedido', 0, 'Boleto', 'e-commerce', NULL),
(34, 4, 3, '2025-09-16', 'Expedido', 0, 'Boleto', 'atacado', 'Pedido recorrente - cliente atacado'),
(35, 3, 2, '2025-09-04', 'Faturado', 0, 'Cartao', 'e-commerce', NULL),
(36, 7, 1, '2025-09-02', 'Faturado', 0, 'Boleto', 'loja fisica', NULL),
(37, 6, 2, '2025-09-05', 'Faturado', 0, 'PIX', 'e-commerce', NULL),
(38, 9, 1, '2025-09-18', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(39, 9, 2, '2025-09-29', 'Expedido', 0, 'PIX', 'e-commerce', NULL),
(40, 8, 3, '2025-09-10', 'Faturado', 0, 'Boleto', 'atacado', 'Pedido recorrente - cliente atacado'),
(41, 5, 2, '2025-09-28', 'Aberto', 0, 'PIX', 'e-commerce', NULL),
(42, 9, 1, '2025-09-13', 'Expedido', 0, 'Boleto', 'loja fisica', NULL),
(43, 6, 2, '2025-09-11', 'Expedido', 0, 'PIX', 'e-commerce', NULL),
(44, 5, 1, '2025-09-30', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(45, 4, 4, '2025-09-03', 'Expedido', 0, 'Cartao', 'atacado', NULL),
(46, 10, 1, '2025-09-26', 'Aberto', 0, 'PIX', 'loja fisica', NULL),
(47, 9, 2, '2025-09-24', 'Aberto', 0, 'PIX', 'e-commerce', NULL),
(48, 8, 3, '2025-09-28', 'Expedido', 0, 'Boleto', 'atacado', NULL),
(49, 3, 2, '2025-09-24', 'Faturado', 0, 'Boleto', 'e-commerce', NULL),
(50, 6, 1, '2025-09-27', 'Expedido', 0, 'Boleto', 'loja fisica', NULL),
(51, 3, 2, '2025-09-08', 'Expedido', 0, 'Cartao', 'e-commerce', NULL),
(52, 10, 1, '2025-09-26', 'Expedido', 0, 'Cartao', 'loja fisica', NULL),
(53, 9, 2, '2025-09-26', 'Expedido', 0, 'Cartao', 'e-commerce', NULL),
(54, 9, 1, '2025-09-08', 'Expedido', 0, 'Cartao', 'loja fisica', NULL),
(55, 4, 4, '2025-09-28', 'Expedido', 0, 'Cartao', 'atacado', NULL),
(56, 1, 1, '2025-09-29', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(57, 4, 4, '2025-09-20', 'Aberto', 0, 'PIX', 'atacado', 'Pedido recorrente - cliente atacado'),
(58, 6, 1, '2025-09-26', 'Aberto', 0, 'Boleto', 'loja fisica', NULL),
(59, 7, 2, '2025-09-04', 'Expedido', 0, 'Boleto', 'e-commerce', NULL),
(60, 4, 3, '2025-09-05', 'Expedido', 0, 'Cartao', 'atacado', NULL),
(61, 8, 4, '2025-09-10', 'Expedido', 0, 'PIX', 'atacado', 'Pedido recorrente - cliente atacado'),
(62, 5, 1, '2025-09-26', 'Expedido', 0, 'Boleto', 'loja fisica', NULL),
(63, 8, 4, '2025-09-22', 'Expedido', 0, 'PIX', 'atacado', 'Pedido recorrente - cliente atacado'),
(64, 9, 1, '2025-09-19', 'Expedido', 0, 'Boleto', 'loja fisica', NULL),
(65, 8, 4, '2025-09-04', 'Faturado', 0, 'PIX', 'atacado', 'Pedido recorrente - cliente atacado'),
(66, 2, 1, '2025-09-05', 'Faturado', 0, 'Boleto', 'loja fisica', NULL),
(67, 4, 4, '2025-09-30', 'Aberto', 0, 'Cartao', 'atacado', NULL),
(68, 1, 1, '2025-09-10', 'Expedido', 0, 'Cartao', 'loja fisica', NULL),
(69, 4, 4, '2025-09-05', 'Expedido', 0, 'PIX', 'atacado', NULL),
(70, 4, 3, '2025-09-25', 'Cancelado', 0, 'Boleto', 'atacado', 'Pedido recorrente - cliente atacado'),
(71, 4, 4, '2025-09-29', 'Faturado', 0, 'Boleto', 'atacado', 'Pedido recorrente - cliente atacado'),
(72, 8, 3, '2025-09-13', 'Expedido', 0, 'Cartao', 'atacado', NULL),
(73, 3, 2, '2025-09-11', 'Expedido', 0, 'Cartao', 'e-commerce', NULL),
(74, 5, 1, '2025-09-24', 'Aberto', 0, 'PIX', 'loja fisica', NULL),
(75, 1, 2, '2025-09-05', 'Expedido', 0, 'PIX', 'e-commerce', NULL),
(76, 2, 1, '2025-09-20', 'Expedido', 0, 'PIX', 'loja fisica', NULL),
(77, 6, 2, '2025-09-27', 'Expedido', 0, 'PIX', 'e-commerce', NULL);

-- ITEM_PEDIDO (129) — a última linha (produto 1 no pedido 21, R$399,00) é
-- uma anomalia de preço deliberada para a auditoria 9.5.
INSERT INTO item_pedido (id_item_pedido, pedido_id, produto_id, qt_quantidade, vl_preco_unitario, vl_desconto) VALUES
(1, 1, 1, 1, 480.0, 0), (2, 1, 7, 2, 65.0, 0), (3, 2, 3, 1, 320.0, 0), (4, 3, 6, 3, 95.0, 0), (5, 3, 8, 1, 120.0, 0),
(6, 4, 2, 5, 470.0, 0), (7, 4, 5, 3, 400.0, 0), (8, 5, 4, 1, 295.0, 0), (9, 6, 1, 1, 480.0, 0), (10, 6, 6, 1, 95.0, 0),
(11, 7, 3, 1, 320.0, 0), (12, 8, 2, 4, 470.0, 0), (13, 8, 7, 6, 65.0, 0), (14, 9, 5, 1, 410.0, 0), (15, 9, 8, 2, 120.0, 0),
(16, 10, 4, 2, 295.0, 0), (17, 10, 7, 1, 65.0, 0), (18, 11, 1, 1, 480.0, 0), (19, 12, 3, 2, 320.0, 0), (20, 12, 6, 1, 95.0, 0),
(21, 13, 2, 1, 480.0, 0), (22, 14, 5, 6, 395.0, 0), (23, 14, 1, 4, 475.0, 0), (24, 15, 8, 1, 120.0, 0), (25, 15, 7, 3, 65.0, 0),
(26, 16, 2, 3, 480.0, 0), (27, 17, 4, 1, 295.0, 0), (28, 18, 5, 1, 410.0, 0), (29, 19, 6, 1, 90.62, 0), (30, 20, 2, 5, 480.0, 0),
(31, 20, 4, 7, 295.0, 0), (32, 21, 5, 3, 410.0, 0), (33, 21, 1, 6, 480.0, 0), (34, 22, 2, 7, 480.0, 0), (35, 22, 5, 4, 410.0, 0),
(36, 23, 1, 1, 480.0, 0), (37, 23, 2, 2, 480.0, 0), (38, 24, 7, 2, 65.0, 0), (39, 24, 6, 1, 95.0, 0), (40, 25, 7, 1, 65.0, 0),
(41, 25, 3, 1, 320.0, 0), (42, 25, 2, 1, 480.0, 0), (43, 26, 7, 3, 65.0, 0), (44, 27, 5, 3, 410.0, 0), (45, 27, 7, 2, 65.0, 0),
(46, 28, 2, 8, 480.0, 0), (47, 28, 7, 4, 65.0, 0), (48, 29, 8, 5, 120.0, 0), (49, 29, 1, 5, 480.0, 0), (50, 30, 2, 3, 480.0, 0),
(51, 30, 7, 1, 65.0, 0), (52, 31, 7, 3, 65.0, 0), (53, 31, 2, 3, 480.0, 0), (54, 31, 5, 3, 410.0, 0), (55, 32, 2, 7, 480.0, 0),
(56, 33, 4, 1, 295.0, 0), (57, 33, 1, 1, 480.0, 0), (58, 34, 8, 6, 120.0, 0), (59, 35, 8, 3, 117.14, 0), (60, 36, 2, 1, 480.0, 0),
(61, 37, 4, 1, 295.0, 0), (62, 38, 1, 1, 480.0, 0), (63, 38, 8, 2, 120.0, 0), (64, 39, 7, 2, 65.0, 0), (65, 40, 8, 3, 120.0, 0),
(66, 40, 2, 7, 462.02, 0), (67, 40, 7, 3, 65.0, 0), (68, 41, 2, 1, 457.3, 0), (69, 42, 1, 3, 468.62, 0), (70, 43, 6, 2, 95.0, 0),
(71, 43, 2, 3, 480.0, 0), (72, 44, 2, 3, 480.0, 0), (73, 44, 1, 2, 480.0, 0), (74, 45, 8, 8, 120.0, 0), (75, 46, 5, 1, 410.0, 0),
(76, 46, 6, 1, 95.0, 0), (77, 47, 4, 3, 295.0, 0), (78, 48, 1, 5, 462.4, 0), (79, 48, 8, 4, 120.0, 0), (80, 49, 1, 1, 480.0, 0),
(81, 49, 8, 3, 120.0, 0), (82, 50, 7, 1, 65.0, 0), (83, 50, 2, 1, 480.0, 0), (84, 51, 7, 3, 65.0, 0), (85, 51, 5, 1, 410.0, 0),
(86, 52, 6, 2, 95.0, 0), (87, 53, 2, 2, 480.0, 0), (88, 54, 4, 1, 282.53, 0), (89, 55, 7, 7, 65.0, 0), (90, 56, 5, 1, 410.0, 0),
(91, 56, 1, 2, 480.0, 0), (92, 57, 4, 8, 295.0, 0), (93, 58, 4, 2, 288.09, 0), (94, 58, 3, 2, 320.0, 0), (95, 59, 7, 2, 65.0, 0),
(96, 60, 7, 4, 65.0, 0), (97, 60, 6, 5, 95.0, 0), (98, 61, 6, 6, 95.0, 0), (99, 62, 6, 1, 95.0, 0), (100, 63, 3, 6, 320.0, 0),
(101, 63, 1, 3, 480.0, 0), (102, 64, 8, 1, 120.0, 0), (103, 64, 4, 3, 289.11, 0), (104, 65, 8, 4, 120.0, 0), (105, 66, 6, 2, 95.0, 0),
(106, 66, 7, 3, 65.0, 0), (107, 67, 8, 8, 120.0, 0), (108, 67, 4, 7, 295.0, 0), (109, 67, 3, 4, 320.0, 0), (110, 68, 2, 1, 480.0, 0),
(111, 69, 6, 6, 93.41, 0), (112, 70, 7, 5, 65.0, 0), (113, 71, 4, 6, 295.0, 0), (114, 71, 8, 6, 120.0, 0), (115, 72, 1, 3, 464.23, 0),
(116, 72, 4, 6, 295.0, 0), (117, 72, 5, 5, 410.0, 0), (118, 73, 7, 2, 65.0, 0), (119, 74, 6, 1, 95.0, 0), (120, 74, 2, 3, 456.6, 0),
(121, 74, 8, 1, 120.0, 0), (122, 75, 2, 1, 480.0, 0), (123, 75, 5, 2, 410.0, 0), (124, 76, 2, 2, 480.0, 0), (125, 76, 5, 2, 410.0, 0),
(126, 76, 1, 3, 480.0, 0), (127, 77, 5, 3, 410.0, 0), (128, 77, 7, 1, 65.0, 0), (129, 21, 1, 1, 399.0, 0);

-- CONTAS_RECEBER (61) — gerado para pedidos Faturado/Expedido. PIX/Cartao:
-- recebido no mesmo dia. Boleto: vencimento +30 dias; status determinístico.
INSERT INTO contas_receber (id_titulo_receber, pedido_id, vl_valor, dt_vencimento, dt_recebimento, tp_status) VALUES
(1, 1, 610.0, '2025-04-02', '2025-04-02', 'pago'), (2, 2, 320.0, '2025-04-03', '2025-04-03', 'pago'),
(3, 3, 405.0, '2025-05-05', NULL, 'em aberto'), (4, 4, 3550.0, '2025-05-08', '2025-05-08', 'pago'),
(5, 6, 575.0, '2025-04-12', '2025-04-12', 'pago'), (6, 8, 2270.0, '2025-05-18', '2025-05-18', 'pago'),
(7, 9, 650.0, '2025-04-20', '2025-04-20', 'pago'), (8, 10, 655.0, '2025-04-22', '2025-04-22', 'pago'),
(9, 12, 735.0, '2025-04-27', '2025-04-27', 'pago'), (10, 13, 480.0, '2025-06-01', '2025-06-01', 'pago'),
(11, 14, 4270.0, '2025-06-04', '2025-06-04', 'pago'), (12, 16, 1440.0, '2025-09-01', '2025-09-01', 'pago'),
(13, 17, 295.0, '2025-09-19', '2025-09-19', 'pago'), (14, 19, 90.62, '2025-09-14', '2025-09-14', 'pago'),
(15, 20, 4465.0, '2025-09-20', '2025-09-20', 'pago'), (16, 21, 4509.0, '2025-09-07', '2025-09-07', 'pago'),
(17, 22, 5000.0, '2025-09-12', '2025-09-12', 'pago'), (18, 24, 225.0, '2025-09-19', '2025-09-19', 'pago'),
(19, 26, 195.0, '2025-10-22', '2025-10-22', 'pago'), (20, 27, 1360.0, '2025-10-18', NULL, 'em aberto'),
(21, 28, 4100.0, '2025-10-24', '2025-10-24', 'pago'), (22, 30, 1505.0, '2025-09-19', '2025-09-19', 'pago'),
(23, 31, 2865.0, '2025-10-06', '2025-10-06', 'pago'), (24, 32, 3360.0, '2025-09-17', '2025-09-17', 'pago'),
(25, 33, 775.0, '2025-10-01', NULL, 'em aberto'), (26, 34, 720.0, '2025-10-16', '2025-10-16', 'pago'),
(27, 35, 351.42, '2025-09-04', '2025-09-04', 'pago'), (28, 36, 480.0, '2025-10-02', NULL, 'em aberto'),
(29, 37, 295.0, '2025-09-05', '2025-09-05', 'pago'), (30, 38, 720.0, '2025-09-18', '2025-09-18', 'pago'),
(31, 39, 130.0, '2025-09-29', '2025-09-29', 'pago'), (32, 40, 3789.14, '2025-10-10', '2025-10-10', 'pago'),
(33, 42, 1405.86, '2025-10-13', NULL, 'em aberto'), (34, 43, 1630.0, '2025-09-11', '2025-09-11', 'pago'),
(35, 44, 2400.0, '2025-09-30', '2025-09-30', 'pago'), (36, 45, 960.0, '2025-09-03', '2025-09-03', 'pago'),
(37, 48, 2792.0, '2025-10-28', NULL, 'em aberto'), (38, 49, 840.0, '2025-10-24', '2025-10-24', 'pago'),
(39, 50, 545.0, '2025-10-27', '2025-10-27', 'pago'), (40, 51, 605.0, '2025-09-08', '2025-09-08', 'pago'),
(41, 52, 190.0, '2025-09-26', '2025-09-26', 'pago'), (42, 53, 960.0, '2025-09-26', '2025-09-26', 'pago'),
(43, 54, 282.53, '2025-09-08', '2025-09-08', 'pago'), (44, 55, 455.0, '2025-09-28', '2025-09-28', 'pago'),
(45, 56, 1370.0, '2025-09-29', '2025-09-29', 'pago'), (46, 59, 130.0, '2025-10-04', '2025-10-04', 'pago'),
(47, 60, 735.0, '2025-09-05', '2025-09-05', 'pago'), (48, 61, 570.0, '2025-09-10', '2025-09-10', 'pago'),
(49, 62, 95.0, '2025-10-26', '2025-10-26', 'pago'), (50, 63, 3360.0, '2025-09-22', '2025-09-22', 'pago'),
(51, 64, 987.33, '2025-10-19', '2025-10-19', 'pago'), (52, 65, 480.0, '2025-09-04', '2025-09-04', 'pago'),
(53, 66, 385.0, '2025-10-05', NULL, 'em aberto'), (54, 68, 480.0, '2025-09-10', '2025-09-10', 'pago'),
(55, 69, 560.46, '2025-09-05', '2025-09-05', 'pago'), (56, 71, 2490.0, '2025-10-29', '2025-10-29', 'pago'),
(57, 72, 5212.69, '2025-09-13', '2025-09-13', 'pago'), (58, 73, 130.0, '2025-09-11', '2025-09-11', 'pago'),
(59, 75, 1300.0, '2025-09-05', '2025-09-05', 'pago'), (60, 76, 3220.0, '2025-09-20', '2025-09-20', 'pago'),
(61, 77, 1295.0, '2025-09-27', '2025-09-27', 'pago');

-- CONTAS_PAGAR (10) — um título por lote de insumo recebido.
INSERT INTO contas_pagar (id_titulo_pagar, lote_id, vl_valor, dt_vencimento, dt_pagamento, tp_status) VALUES
(1, 1, 3380.0, '2025-04-09', '2025-04-09', 'pago'), (2, 2, 3041.5, '2025-07-20', '2025-07-20', 'pago'),
(3, 3, 3681.0, '2025-04-09', NULL, 'em aberto'), (4, 4, 1200.0, '2025-04-14', '2025-04-14', 'pago'),
(5, 5, 264.0, '2025-03-22', '2025-03-22', 'pago'), (6, 6, 228.25, '2025-03-22', NULL, 'em aberto'),
(7, 7, 192.5, '2025-03-27', '2025-03-27', 'pago'), (8, 8, 154.0, '2025-03-27', '2025-03-27', 'pago'),
(9, 9, 85.0, '2025-03-30', NULL, 'em aberto'), (10, 10, 792.0, '2025-04-17', '2025-04-17', 'pago');


-- =====================================================================
-- 5) SELECT com JOIN
-- =====================================================================

-- 5.1 Pedidos com nome do cliente, vendedor e total do pedido
SELECT p.id_pedido, c.nm_cliente AS cliente, v.nm_vendedor AS vendedor, p.dt_pedido, p.tp_status, p.vl_total
FROM pedido p
JOIN cliente c  ON c.id_cliente  = p.cliente_id
JOIN vendedor v ON v.id_vendedor = p.vendedor_id
ORDER BY p.dt_pedido;

-- 5.2 Itens de um pedido específico, com o nome do produto
SELECT ip.id_item_pedido, pr.nm_produto AS produto, ip.qt_quantidade, ip.vl_preco_unitario, ip.vl_subtotal
FROM item_pedido ip
JOIN produto pr ON pr.id_produto = ip.produto_id
WHERE ip.pedido_id = 4;

-- 5.3 Ficha técnica "legível": produto, insumo e quantidade necessária
SELECT pr.nm_produto AS produto, i.nm_insumo AS insumo, ft.qt_necessaria, i.un_medida
FROM ficha_tecnica ft
JOIN produto pr ON pr.id_produto = ft.produto_id
JOIN insumo  i  ON i.id_insumo  = ft.insumo_id
ORDER BY pr.nm_produto, i.nm_insumo;

-- 5.4 Produtos com todos os fornecedores que já forneceram cada insumo
-- usado neles (join quádruplo via LOTE_INSUMO) — mostra que um mesmo
-- insumo pode vir de mais de um fornecedor (ex.: Bolsa Tote Caramelo)
SELECT DISTINCT pr.nm_produto AS produto, i.nm_insumo AS insumo, f.nm_fornecedor AS fornecedor
FROM ficha_tecnica ft
JOIN produto     pr ON pr.id_produto     = ft.produto_id
JOIN insumo      i  ON i.id_insumo       = ft.insumo_id
JOIN lote_insumo li ON li.insumo_id      = i.id_insumo
JOIN fornecedor  f  ON f.id_fornecedor   = li.fornecedor_id
ORDER BY pr.nm_produto, f.nm_fornecedor;

-- 5.5 Pedidos com detalhe de especialização do produto vendido
-- (LEFT JOIN em bolsa e acessorio, já que cada produto só aparece em um dos dois)
SELECT p.id_pedido, pr.nm_produto AS produto, pr.tp_produto,
       b.ds_cor AS cor_bolsa, a.ds_cor AS cor_acessorio
FROM item_pedido ip
JOIN pedido  p  ON p.id_pedido  = ip.pedido_id
JOIN produto pr ON pr.id_produto = ip.produto_id
LEFT JOIN bolsa     b ON b.id_produto = pr.id_produto
LEFT JOIN acessorio a ON a.id_produto = pr.id_produto
ORDER BY p.id_pedido;

-- 5.6 Rastreabilidade de uma Ordem de Produção: etapa, quem executou,
-- quando e o aproveitamento de couro (quando aplicável)
SELECT op.nr_op, pr.nm_produto AS produto, et.nm_etapa, af.nm_artesao,
       ee.dt_inicio, ee.dt_fim, ee.pc_aproveitamento, ee.pc_perda
FROM execucao_etapa ee
JOIN ordem_producao op ON op.id_op = ee.op_id
JOIN produto        pr ON pr.id_produto = op.produto_id
JOIN etapa_producao  et ON et.id_etapa = ee.etapa_id
JOIN artesao  af ON af.id_artesao = ee.artesao_id
WHERE op.nr_op = 'OP-2025-001'
ORDER BY et.nr_ordem_sequencial;

-- 5.7 Comissão por vendedor nos pedidos faturados/expedidos
SELECT v.nm_vendedor, v.pc_comissao, p.tp_canal,
       SUM(p.vl_total) AS total_vendido,
       ROUND(SUM(p.vl_total) * v.pc_comissao / 100, 2) AS comissao_devida
FROM pedido p
JOIN vendedor v ON v.id_vendedor = p.vendedor_id
WHERE p.tp_status IN ('Faturado', 'Expedido')
GROUP BY v.id_vendedor, v.nm_vendedor, v.pc_comissao, p.tp_canal
ORDER BY comissao_devida DESC;


-- =====================================================================
-- 6) UPDATE
-- =====================================================================

-- 6.1 Recalcula o vl_total de TODOS os pedidos a partir dos itens
-- (mantém a denormalização de pedido.vl_total consistente — rodar
-- sempre que item_pedido for alterado)
UPDATE pedido p
SET vl_total = (
    SELECT COALESCE(SUM(ip.vl_subtotal), 0)
    FROM item_pedido ip
    WHERE ip.pedido_id = p.id_pedido
);

-- 6.2 Reajuste de preço: aumenta em 5% o vl_preco_base de todos os
-- produtos da categoria "Linha Executiva" (não afeta pedidos já
-- registrados, porque item_pedido.vl_preco_unitario fica congelado)
UPDATE produto
SET vl_preco_base = ROUND(vl_preco_base * 1.05, 2)
WHERE tp_categoria = 'Linha Executiva';

-- 6.3 Entrada de compra: soma 50 M2 de couro caramelo ao estoque
-- (ajuste rápido de inventário; a entrada "formal" rastreável por lote
-- fica em LOTE_INSUMO, já carregada na Seção 4)
UPDATE insumo
SET qt_estoque_atual = qt_estoque_atual + 50.00
WHERE id_insumo = 1;

-- 6.4 Expedição: marca como "Expedido" os pedidos que estavam "Faturado"
-- e têm mais de 5 dias desde o registro (regra fictícia, só para
-- demonstrar UPDATE condicional em lote)
UPDATE pedido
SET tp_status = 'Expedido'
WHERE tp_status = 'Faturado'
  AND dt_pedido <= DATE_SUB('2025-05-15', INTERVAL 5 DAY);

-- 6.5 Baixa de título a receber: cliente quita o boleto do pedido 3,
-- ainda "em aberto" na massa de dados
UPDATE contas_receber
SET dt_recebimento = '2025-05-10', tp_status = 'pago'
WHERE pedido_id = 3;

-- 6.6 Conclui a Ordem de Produção 8 (ainda "em producao"): fecha as
-- etapas pendentes e atualiza o status da OP
UPDATE execucao_etapa
SET dt_fim = DATE_ADD(dt_inicio, INTERVAL 1 DAY)
WHERE op_id = 8 AND dt_fim IS NULL;

UPDATE ordem_producao
SET tp_status_kanban = 'concluida'
WHERE id_op = 8;


-- =====================================================================
-- 7) DELETE
-- =====================================================================

-- 7.1 Remove os itens e o pedido cancelado (ordem respeita a FK:
-- item_pedido tem ON DELETE CASCADE para pedido, então apagar o
-- pedido já apaga os itens — mas deixamos explícito por clareza)
DELETE FROM item_pedido WHERE pedido_id = 7;
DELETE FROM pedido WHERE id_pedido = 7 AND tp_status = 'Cancelado';

-- 7.2 Remove um insumo nunca recebido (sem lote) e nunca usado em
-- nenhuma ficha técnica — a caixa de papelão é embalagem de envio, não
-- insumo de produção, e nunca chegou a ser efetivamente comprada (ver
-- auditoria 9.3). Sem nenhuma FK apontando para ele, a remoção é segura.
DELETE FROM insumo
WHERE id_insumo = 10
  AND id_insumo NOT IN (SELECT insumo_id FROM ficha_tecnica)
  AND id_insumo NOT IN (SELECT insumo_id FROM lote_insumo);


-- =====================================================================
-- 8) CONSULTAS GERENCIAIS
-- =====================================================================

-- 8.1 Faturamento por mês (pedidos faturados ou expedidos)
SELECT DATE_FORMAT(dt_pedido, '%Y-%m') AS mes, SUM(vl_total) AS faturamento
FROM pedido
WHERE tp_status IN ('Faturado', 'Expedido')
GROUP BY DATE_FORMAT(dt_pedido, '%Y-%m')
ORDER BY mes;

-- 8.2 Curva ABC — produtos mais vendidos por quantidade
SELECT pr.nm_produto AS produto, SUM(ip.qt_quantidade) AS unidades_vendidas,
       SUM(ip.vl_subtotal) AS receita_total
FROM item_pedido ip
JOIN produto pr ON pr.id_produto = ip.produto_id
GROUP BY pr.id_produto, pr.nm_produto
ORDER BY unidades_vendidas DESC;

-- 8.3 Margem estimada por produto (preço base - custo de matéria-prima
-- calculado a partir da ficha técnica, pelo preço de referência do insumo)
SELECT pr.nm_produto AS produto,
       pr.vl_preco_base,
       ROUND(SUM(ft.qt_necessaria * i.vl_preco_referencia), 2) AS custo_materia_prima,
       ROUND(pr.vl_preco_base - SUM(ft.qt_necessaria * i.vl_preco_referencia), 2) AS margem_estimada
FROM produto pr
JOIN ficha_tecnica ft ON ft.produto_id = pr.id_produto
JOIN insumo i ON i.id_insumo = ft.insumo_id
GROUP BY pr.id_produto, pr.nm_produto, pr.vl_preco_base
ORDER BY margem_estimada DESC;

-- 8.4 Ranking de clientes por valor total comprado
SELECT c.nm_cliente AS cliente, COUNT(p.id_pedido) AS total_pedidos, SUM(p.vl_total) AS valor_acumulado
FROM cliente c
JOIN pedido p ON p.cliente_id = c.id_cliente
WHERE p.tp_status <> 'Cancelado'
GROUP BY c.id_cliente, c.nm_cliente
ORDER BY valor_acumulado DESC;

-- 8.5 Consumo total de cada insumo, projetado a partir das vendas
-- (quantidade vendida de cada produto × quantidade do insumo na ficha técnica)
SELECT i.nm_insumo, i.un_medida,
       ROUND(SUM(ip.qt_quantidade * ft.qt_necessaria), 3) AS consumo_projetado
FROM item_pedido ip
JOIN ficha_tecnica ft ON ft.produto_id = ip.produto_id
JOIN insumo i ON i.id_insumo = ft.insumo_id
GROUP BY i.id_insumo, i.nm_insumo, i.un_medida
ORDER BY consumo_projetado DESC;

-- 8.6 Aproveitamento médio de corte por artesão/facção (base da
-- remuneração por etapa — RF15)
SELECT af.nm_artesao, af.tp_vinculo,
       COUNT(*) AS cortes_executados,
       ROUND(AVG(ee.pc_aproveitamento), 1) AS aproveitamento_medio,
       ROUND(AVG(ee.pc_perda), 1) AS perda_media
FROM execucao_etapa ee
JOIN artesao af ON af.id_artesao = ee.artesao_id
JOIN etapa_producao  et ON et.id_etapa = ee.etapa_id
WHERE et.nm_etapa = 'Corte'
GROUP BY af.id_artesao, af.nm_artesao, af.tp_vinculo
ORDER BY aproveitamento_medio DESC;

-- 8.7 Aging de contas a receber e a pagar em aberto (dias até o
-- vencimento, referência fixa 2025-10-15 — mesma lógica de "hoje"
-- fictício usada na Seção 6.4)
SELECT 'receber' AS tipo, id_titulo_receber AS id_titulo, vl_valor, dt_vencimento,
       DATEDIFF('2025-10-15', dt_vencimento) AS dias_desde_vencimento
FROM contas_receber WHERE tp_status = 'em aberto'
UNION ALL
SELECT 'pagar' AS tipo, id_titulo_pagar AS id_titulo, vl_valor, dt_vencimento,
       DATEDIFF('2025-10-15', dt_vencimento) AS dias_desde_vencimento
FROM contas_pagar WHERE tp_status = 'em aberto'
ORDER BY dias_desde_vencimento DESC;


-- =====================================================================
-- 9) CONSULTAS DE AUDITORIA
-- =====================================================================

-- 9.1 Pedidos cujo vl_total NÃO bate com a soma real dos itens
-- (detecta inconsistência de denormalização — deveria vir vazio logo
-- após rodar o UPDATE 6.1)
SELECT p.id_pedido, p.vl_total AS valor_armazenado,
       COALESCE(SUM(ip.vl_subtotal), 0) AS valor_real
FROM pedido p
LEFT JOIN item_pedido ip ON ip.pedido_id = p.id_pedido
GROUP BY p.id_pedido, p.vl_total
HAVING valor_armazenado <> valor_real;

-- 9.2 Produtos sem nenhuma linha de ficha técnica (BOM incompleta)
SELECT pr.id_produto, pr.nm_produto
FROM produto pr
LEFT JOIN ficha_tecnica ft ON ft.produto_id = pr.id_produto
WHERE ft.produto_id IS NULL;

-- 9.3 Insumos nunca utilizados em nenhuma ficha técnica
-- (vem vazia neste script porque o único caso — a caixa de papelão,
-- insumo 10 — já foi removido na Seção 7.2; numa auditoria de rotina,
-- rode esta consulta ANTES de decidir qualquer DELETE)
SELECT i.id_insumo, i.nm_insumo
FROM insumo i
LEFT JOIN ficha_tecnica ft ON ft.insumo_id = i.id_insumo
WHERE ft.insumo_id IS NULL;

-- 9.4 Checagem da especialização TOTAL e DISJUNTA de PRODUTO:
-- todo produto deve existir em exatamente uma das tabelas BOLSA/ACESSORIO,
-- de acordo com o seu tp_produto. Esta consulta deveria vir vazia;
-- se trouxer linhas, a regra "Total e Disjunta" do DER foi violada.
SELECT pr.id_produto, pr.nm_produto, pr.tp_produto,
       (b.id_produto IS NOT NULL) AS tem_linha_bolsa,
       (a.id_produto IS NOT NULL) AS tem_linha_acessorio
FROM produto pr
LEFT JOIN bolsa     b ON b.id_produto = pr.id_produto
LEFT JOIN acessorio a ON a.id_produto = pr.id_produto
WHERE (pr.tp_produto = 'BOLSA'     AND (b.id_produto IS NULL OR a.id_produto IS NOT NULL))
   OR (pr.tp_produto = 'ACESSORIO' AND (a.id_produto IS NULL OR b.id_produto IS NOT NULL));

-- 9.5 Itens de pedido cujo preço praticado destoa muito do preço base
-- atual do produto (possível erro de digitação ou promoção não documentada)
SELECT ip.id_item_pedido, pr.nm_produto AS produto, ip.vl_preco_unitario, pr.vl_preco_base,
       ROUND(100 * (ip.vl_preco_unitario - pr.vl_preco_base) / pr.vl_preco_base, 1) AS variacao_percentual
FROM item_pedido ip
JOIN produto pr ON pr.id_produto = ip.produto_id
WHERE ABS(ip.vl_preco_unitario - pr.vl_preco_base) / pr.vl_preco_base > 0.10
ORDER BY ABS(variacao_percentual) DESC;

-- 9.6 Fornecedores sem nenhum lote de insumo recebido (cadastro
-- incompleto ou fornecedor nunca efetivamente acionado) — agora
-- verificado via LOTE_INSUMO, não mais por uma FK direta em INSUMO
SELECT f.id_fornecedor, f.nm_fornecedor
FROM fornecedor f
LEFT JOIN lote_insumo li ON li.fornecedor_id = f.id_fornecedor
WHERE li.id_lote IS NULL;

-- 9.7 Títulos (a pagar e a receber) vencidos e ainda em aberto —
-- mesma referência fixa de "hoje" usada na consulta gerencial 8.7
SELECT 'receber' AS tipo, id_titulo_receber AS id_titulo, vl_valor, dt_vencimento
FROM contas_receber
WHERE tp_status = 'em aberto' AND dt_vencimento < '2025-10-15'
UNION ALL
SELECT 'pagar' AS tipo, id_titulo_pagar AS id_titulo, vl_valor, dt_vencimento
FROM contas_pagar
WHERE tp_status = 'em aberto' AND dt_vencimento < '2025-10-15';
