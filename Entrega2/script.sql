-- =====================================================================
-- Contrasti Bolsas e Acessórios Ltda — Modelagem de Banco de Dados
-- Entrega 2 — Script SQL completo (Modelo Lógico + Massa de Dados)
--
-- Dialeto: MySQL 8.0+ / MariaDB 10.5+ (AUTO_INCREMENT, CHECK constraints
-- aplicados, GENERATED COLUMN em item_pedido.subtotal).
-- Testado do zero: rode este arquivo inteiro em um servidor vazio.
--
-- Organização do arquivo (mesma ordem pedida no esqueleto da Entrega 2):
--   1. CREATE DATABASE
--   2. CREATE TABLE (9 tabelas, uma por entidade da Entrega 1)
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
CREATE DATABASE contrasti_bolsas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE contrasti_bolsas;


-- =====================================================================
-- 2) CREATE TABLE  +  3) CONSTRAINTS
-- =====================================================================

-- FORNECEDOR ------------------------------------------------------------
CREATE TABLE fornecedor (
    id_fornecedor        INT AUTO_INCREMENT PRIMARY KEY,
    nome                 VARCHAR(150) NOT NULL,
    cnpj                 VARCHAR(18)  NOT NULL,
    telefone             VARCHAR(20),
    email                VARCHAR(120),
    endereco             VARCHAR(200),
    data_cadastro        DATE NOT NULL DEFAULT (CURRENT_DATE),
    categoria_fornecedor VARCHAR(30) NOT NULL,
    CONSTRAINT uq_fornecedor_cnpj     UNIQUE (cnpj),
    CONSTRAINT ck_fornecedor_categoria CHECK (categoria_fornecedor IN ('Couro','Ferragens','Ziperes','Embalagens'))
);

-- INSUMO ------------------------------------------------------------------
-- FK para FORNECEDOR: relacionamento "fornece" (FORNECEDOR 1,1 — INSUMO 0,N)
-- migra como fornecedor_id obrigatório aqui, do lado N.
CREATE TABLE insumo (
    id_insumo       INT AUTO_INCREMENT PRIMARY KEY,
    nome_insumo     VARCHAR(120)  NOT NULL,
    tipo_insumo     VARCHAR(30)   NOT NULL,
    unidade_medida  VARCHAR(10)   NOT NULL,
    estoque_atual   DECIMAL(10,2) NOT NULL DEFAULT 0,
    preco_unitario  DECIMAL(10,2) NOT NULL,
    fornecedor_id   INT NOT NULL,
    CONSTRAINT fk_insumo_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id_fornecedor),
    CONSTRAINT ck_insumo_unidade CHECK (unidade_medida IN ('DM2','M2','UN','M','KG','L')),
    CONSTRAINT ck_insumo_estoque CHECK (estoque_atual >= 0),
    CONSTRAINT ck_insumo_preco   CHECK (preco_unitario > 0)
);

-- PRODUTO (supertipo) -----------------------------------------------------
-- tipo_produto é o discriminador da especialização TD (Total e Disjunta):
-- toda linha de produto tem que ter uma linha correspondente em BOLSA
-- OU em ACESSORIO (nunca nas duas) — ver Seção 1.4/1.5 do Relatório
-- Técnico para a discussão de como isso é garantido/verificado.
CREATE TABLE produto (
    id_produto     INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(120)  NOT NULL,
    descricao      VARCHAR(255),
    preco_base     DECIMAL(10,2) NOT NULL,
    categoria      VARCHAR(50),
    estoque_total  INT NOT NULL DEFAULT 0,
    tipo_produto   VARCHAR(10) NOT NULL,
    CONSTRAINT ck_produto_preco   CHECK (preco_base > 0),
    CONSTRAINT ck_produto_estoque CHECK (estoque_total >= 0),
    CONSTRAINT ck_produto_tipo    CHECK (tipo_produto IN ('BOLSA','ACESSORIO'))
);

-- BOLSA (subtipo de PRODUTO) ------------------------------------------------
-- Estratégia "tabela por subtipo": id_produto é PK e também FK para
-- PRODUTO (relacionamento 1:1 que implementa a especialização).
CREATE TABLE bolsa (
    id_produto  INT PRIMARY KEY,
    material    VARCHAR(60) NOT NULL,
    cor         VARCHAR(40) NOT NULL,
    tamanho     VARCHAR(30) NOT NULL,
    tipo_alca   VARCHAR(40) NOT NULL,
    CONSTRAINT fk_bolsa_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE CASCADE
);

-- ACESSORIO (subtipo de PRODUTO) --------------------------------------------
CREATE TABLE acessorio (
    id_produto       INT PRIMARY KEY,
    material         VARCHAR(60) NOT NULL,
    cor              VARCHAR(40) NOT NULL,
    tipo_acessorio   VARCHAR(40) NOT NULL,
    compatibilidade  VARCHAR(120),
    CONSTRAINT fk_acessorio_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE CASCADE
);

-- FICHA_TECNICA (entidade associativa, chave composta) ----------------------
CREATE TABLE ficha_tecnica (
    produto_id             INT NOT NULL,
    insumo_id              INT NOT NULL,
    quantidade_necessaria  DECIMAL(10,3) NOT NULL,
    PRIMARY KEY (produto_id, insumo_id),
    CONSTRAINT fk_ficha_produto FOREIGN KEY (produto_id) REFERENCES produto(id_produto) ON DELETE CASCADE,
    CONSTRAINT fk_ficha_insumo  FOREIGN KEY (insumo_id)  REFERENCES insumo(id_insumo),
    CONSTRAINT ck_ficha_qtd CHECK (quantidade_necessaria > 0)
);

-- CLIENTE -------------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente     INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(150) NOT NULL,
    cpf            VARCHAR(14)  NOT NULL,
    telefone       VARCHAR(20),
    email          VARCHAR(120),
    endereco       VARCHAR(200),
    data_cadastro  DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT uq_cliente_cpf UNIQUE (cpf)
);

-- PEDIDO ----------------------------------------------------------------
-- valor_total é mantido por recálculo explícito (ver Seção 6 — UPDATE)
-- em vez de GENERATED COLUMN, porque depende de uma soma em OUTRA
-- tabela (item_pedido), o que SQL não permite em coluna gerada.
-- É uma denormalização deliberada — discutida na Seção 1.4 do
-- Relatório Técnico (3FN).
CREATE TABLE pedido (
    id_pedido       INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id      INT NOT NULL,
    data_pedido     DATE NOT NULL DEFAULT (CURRENT_DATE),
    status          VARCHAR(20) NOT NULL DEFAULT 'Aberto',
    valor_total     DECIMAL(10,2) NOT NULL DEFAULT 0,
    forma_pagamento VARCHAR(10),
    observacoes     VARCHAR(255),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id_cliente),
    CONSTRAINT ck_pedido_status    CHECK (status IN ('Aberto','Faturado','Expedido','Cancelado')),
    CONSTRAINT ck_pedido_pagamento CHECK (forma_pagamento IN ('PIX','Cartao','Boleto'))
);

-- ITEM_PEDIDO (entidade associativa, identificador próprio) -----------------
-- subtotal É coluna gerada (depende só de colunas da própria linha).
CREATE TABLE item_pedido (
    id_item_pedido   INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id        INT NOT NULL,
    produto_id       INT NOT NULL,
    quantidade       INT NOT NULL,
    preco_unitario   DECIMAL(10,2) NOT NULL,
    subtotal         DECIMAL(10,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,
    CONSTRAINT fk_item_pedido_pedido  FOREIGN KEY (pedido_id)  REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_item_pedido_produto FOREIGN KEY (produto_id) REFERENCES produto(id_produto),
    CONSTRAINT ck_item_qtd   CHECK (quantidade > 0),
    CONSTRAINT ck_item_preco CHECK (preco_unitario > 0)
);


-- =====================================================================
-- 4) INSERT INTO — massa de dados (fictícia, coerente com a operação
--    observada: couro/ferragens/zíperes/embalagens, bolsas e acessórios,
--    clientes variados, pedidos em múltiplos canais/status)
-- =====================================================================

-- FORNECEDOR (5) ------------------------------------------------------------
INSERT INTO fornecedor (nome, cnpj, telefone, email, endereco, data_cadastro, categoria_fornecedor) VALUES
('Curtume Vaqueta Ouro Ltda',      '12.345.678/0001-90', '(11) 3344-1001', 'vendas@vaquetaouro.com.br',    'Rua dos Curtumes, 120 - Franca/SP',      '2024-02-10', 'Couro'),
('Metalúrgica Fivelas & Cia',      '23.456.789/0001-01', '(11) 3344-1002', 'comercial@fivelascia.com.br',  'Av. Industrial, 850 - Diadema/SP',       '2024-02-15', 'Ferragens'),
('Zíperes União Comercial',        '34.567.890/0001-12', '(11) 3344-1003', 'contato@zipuniao.com.br',      'Rua Capri, 45 - São Paulo/SP',           '2024-03-01', 'Ziperes'),
('Embalagens Proteção Total',      '45.678.901/0001-23', '(11) 3344-1004', 'pedidos@protecaototal.com.br', 'Rua das Caixas, 300 - Guarulhos/SP',     '2024-03-20', 'Embalagens'),
('Curtume Linhares Couros',        '56.789.012/0001-34', '(11) 3344-1005', 'comercial@linharescouros.com.br','Rod. dos Curtumes, km 12 - Franca/SP', '2024-04-05', 'Couro');

-- INSUMO (10) -----------------------------------------------------------
INSERT INTO insumo (nome_insumo, tipo_insumo, unidade_medida, estoque_atual, preco_unitario, fornecedor_id) VALUES
('Couro Bovino Caramelo',    'Couro',    'M2', 320.00, 85.00, 1),
('Couro Bovino Preto',       'Couro',    'M2', 410.00, 82.00, 1),
('Couro Sintético Café',     'Couro',    'M2', 150.00, 38.00, 5),
('Fivela Metal Dourada',     'Ferragem', 'UN', 540.00,  4.50, 2),
('Fivela Metal Prata',       'Ferragem', 'UN', 480.00,  4.20, 2),
('Zíper Nylon 20cm',         'Ziper',    'UN', 620.00,  2.80, 3),
('Zíper Metálico 15cm',      'Ziper',    'UN', 300.00,  3.90, 3),
('Linha de Costura Encerada','Ferragem', 'M',  1200.00, 0.35, 2),
('Forro Sintético Bege',     'Couro',    'M2', 200.00, 18.00, 5),
('Caixa de Papelão Kraft',   'Embalagem','UN', 800.00,  3.20, 4);

-- PRODUTO (8: 5 bolsas + 3 acessórios) --------------------------------------
INSERT INTO produto (nome, descricao, preco_base, categoria, estoque_total, tipo_produto) VALUES
('Bolsa Tote Caramelo',      'Bolsa tote em couro legítimo, uso diário/executivo',        480.00, 'Linha Executiva', 18, 'BOLSA'),
('Bolsa Tote Preta',         'Bolsa tote em couro legítimo, uso diário/executivo',        480.00, 'Linha Executiva', 22, 'BOLSA'),
('Bolsa Tiracolo Mini Café', 'Bolsa pequena tiracolo, couro sintético',                   320.00, 'Linha Casual',    30, 'BOLSA'),
('Bolsa Transversal Urbana', 'Bolsa transversal compacta, uso casual',                    295.00, 'Linha Casual',    25, 'BOLSA'),
('Bolsa Shopper Grande',     'Bolsa grande estruturada, uso executivo',                   410.00, 'Linha Executiva', 15, 'BOLSA'),
('Cinto Couro Clássico',     'Cinto em couro bovino, fivela metálica',                     95.00, 'Acessórios',      40, 'ACESSORIO'),
('Porta-Cartões Slim',       'Porta-cartões compacto em couro sintético',                  65.00, 'Acessórios',      55, 'ACESSORIO'),
('Carteira Compacta',        'Carteira em couro bovino com fecho zíper',                  120.00, 'Acessórios',      35, 'ACESSORIO');

-- BOLSA (subtipo) ---------------------------------------------------------
INSERT INTO bolsa (id_produto, material, cor, tamanho, tipo_alca) VALUES
(1, 'Couro Bovino', 'Caramelo', 'Médio',   'Tiracolo'),
(2, 'Couro Bovino', 'Preto',    'Médio',   'Tiracolo'),
(3, 'Couro Sintético', 'Café',  'Pequeno', 'Transversal'),
(4, 'Couro Bovino', 'Preto',    'Pequeno', 'Transversal'),
(5, 'Couro Bovino', 'Caramelo', 'Grande',  'Mão');

-- ACESSORIO (subtipo) -------------------------------------------------------
INSERT INTO acessorio (id_produto, material, cor, tipo_acessorio, compatibilidade) VALUES
(6, 'Couro Bovino',    'Preto',    'Cinto',         'Combina com toda a linha executiva'),
(7, 'Couro Sintético', 'Café',     'Porta-cartões', NULL),
(8, 'Couro Bovino',    'Caramelo', 'Carteira',      NULL);

-- FICHA_TECNICA (BOM) -------------------------------------------------------
INSERT INTO ficha_tecnica (produto_id, insumo_id, quantidade_necessaria) VALUES
(1, 1, 1.800), (1, 4, 2.000), (1, 8, 12.000), (1, 9, 1.800),
(2, 2, 1.800), (2, 5, 2.000), (2, 8, 12.000), (2, 9, 1.800),
(3, 3, 0.900), (3, 7, 1.000), (3, 8, 6.000),
(4, 2, 1.000), (4, 6, 1.000), (4, 8, 7.000),
(5, 1, 2.400), (5, 4, 2.000), (5, 8, 15.000), (5, 9, 2.400),
(6, 2, 0.300), (6, 4, 1.000),
(7, 3, 0.150),
(8, 1, 0.400), (8, 6, 1.000);

-- CLIENTE (10) ---------------------------------------------------------
INSERT INTO cliente (nome, cpf, telefone, email, endereco, data_cadastro) VALUES
('Mariana Alves Ferreira',               '111.111.111-01', '(11) 98888-0001', 'mariana.ferreira@email.com', 'Rua das Palmeiras, 220 - São Paulo/SP',  '2025-01-10'),
('João Pedro Santos',                    '111.111.111-02', '(11) 98888-0002', 'joaopedro.santos@email.com', 'Av. Brasil, 1500 - São Paulo/SP',        '2025-01-15'),
('Camila Rodrigues Lima',                '111.111.111-03', '(11) 98888-0003', 'camila.lima@email.com',      'Rua Tupi, 88 - São Paulo/SP',            '2025-01-22'),
('Studio Elegance Multimarcas Ltda',     '111.111.111-04', '(11) 98888-0004', 'compras@studioelegance.com', 'Rua Augusta, 900 - São Paulo/SP',        '2025-02-02'),
('Fernanda Costa Dias',                  '111.111.111-05', '(11) 98888-0005', 'fernanda.dias@email.com',    'Rua Vergueiro, 2100 - São Paulo/SP',     '2025-02-10'),
('Lucas Martins Oliveira',               '111.111.111-06', '(11) 98888-0006', 'lucas.oliveira@email.com',   'Av. Paulista, 1200 - São Paulo/SP',      '2025-02-18'),
('Patrícia Nunes Carvalho',              '111.111.111-07', '(11) 98888-0007', 'patricia.carvalho@email.com','Rua Oscar Freire, 300 - São Paulo/SP',   '2025-03-01'),
('Bazar da Moda Comércio de Bolsas Ltda','111.111.111-08', '(11) 98888-0008', 'compras@bazardamoda.com',    'Rua 25 de Março, 450 - São Paulo/SP',    '2025-03-08'),
('Rafael Souza Pinto',                   '111.111.111-09', '(11) 98888-0009', 'rafael.pinto@email.com',     'Rua Haddock Lobo, 77 - São Paulo/SP',    '2025-03-15'),
('Juliana Barbosa Rezende',              '111.111.111-10', '(11) 98888-0010', 'juliana.rezende@email.com',  'Av. Rebouças, 650 - São Paulo/SP',       '2025-03-22');

-- PEDIDO (15) — valor_total inserido como 0 e recalculado na Seção 6 (UPDATE)
INSERT INTO pedido (cliente_id, data_pedido, status, valor_total, forma_pagamento, observacoes) VALUES
(1,  '2025-04-02', 'Expedido', 0, 'PIX',    NULL),
(2,  '2025-04-03', 'Expedido', 0, 'Cartao', NULL),
(3,  '2025-04-05', 'Faturado', 0, 'Boleto', 'Entrega combinada para sexta-feira'),
(4,  '2025-04-08', 'Expedido', 0, 'Boleto', 'Cliente atacado - pedido recorrente'),
(5,  '2025-04-10', 'Aberto',   0, 'PIX',    NULL),
(6,  '2025-04-12', 'Expedido', 0, 'Cartao', NULL),
(7,  '2025-04-15', 'Cancelado',0, 'PIX',    'Cliente desistiu da compra'),
(8,  '2025-04-18', 'Faturado', 0, 'Boleto', 'Reposição de estoque para loja parceira'),
(1,  '2025-04-20', 'Expedido', 0, 'Cartao', NULL),
(9,  '2025-04-22', 'Expedido', 0, 'PIX',    NULL),
(10, '2025-04-25', 'Aberto',   0, 'Cartao', NULL),
(3,  '2025-04-27', 'Expedido', 0, 'PIX',    NULL),
(6,  '2025-05-02', 'Expedido', 0, 'Boleto', NULL),
(4,  '2025-05-05', 'Faturado', 0, 'Boleto', 'Cliente atacado - pedido recorrente'),
(2,  '2025-05-08', 'Aberto',   0, 'PIX',    NULL);

-- ITEM_PEDIDO (~25) — preco_unitario replica o preco_base vigente do
-- produto no momento da venda (congelado, por regra de negócio).
INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 480.00),
(1, 7, 2,  65.00),
(2, 3, 1, 320.00),
(3, 6, 3,  95.00),
(3, 8, 1, 120.00),
(4, 2, 5, 470.00),
(4, 5, 3, 400.00),
(5, 4, 1, 295.00),
(6, 1, 1, 480.00),
(6, 6, 1,  95.00),
(7, 3, 1, 320.00),
(8, 2, 4, 470.00),
(8, 7, 6,  65.00),
(9, 5, 1, 410.00),
(9, 8, 2, 120.00),
(10,4, 2, 295.00),
(10,7, 1,  65.00),
(11,1, 1, 480.00),
(12,3, 2, 320.00),
(12,6, 1,  95.00),
(13,2, 1, 480.00),
(14,5, 6, 395.00),
(14,1, 4, 475.00),
(15,8, 1, 120.00),
(15,7, 3,  65.00);

-- Volume adicional (setembro/2025) — os 15 pedidos acima (abril/maio)
-- bastam para demonstrar a estrutura; o bloco abaixo aproxima o volume
-- mensal real observado na organização (50-70 pedidos/mês, Seção 1 do
-- README) em um único mês, para que as consultas gerenciais da Seção 8
-- (faturamento por mês, curva ABC, ranking de clientes) tenham massa
-- suficiente para fazer sentido. Gerado programaticamente (seed fixa,
-- reprodutível) e revisado antes de entrar no script — ver Seção 6
-- (Uso de IA) do RELATORIO_TECNICO.md.
-- PEDIDO (62 adicionais, setembro/2025)
INSERT INTO pedido (id_pedido, cliente_id, data_pedido, status, valor_total, forma_pagamento, observacoes) VALUES
(16, 7, '2025-09-01', 'Expedido', 0, 'PIX', NULL),
(17, 6, '2025-09-19', 'Faturado', 0, 'PIX', NULL),
(18, 1, '2025-09-07', 'Aberto', 0, 'Cartao', NULL),
(19, 2, '2025-09-14', 'Expedido', 0, 'Cartao', NULL),
(20, 8, '2025-09-20', 'Expedido', 0, 'PIX', 'Pedido recorrente - cliente atacado'),
(21, 4, '2025-09-07', 'Expedido', 0, 'PIX', NULL),
(22, 4, '2025-09-12', 'Expedido', 0, 'PIX', NULL),
(23, 3, '2025-09-30', 'Aberto', 0, 'PIX', NULL),
(24, 3, '2025-09-19', 'Expedido', 0, 'PIX', NULL),
(25, 6, '2025-09-09', 'Cancelado', 0, 'Cartao', NULL),
(26, 2, '2025-09-22', 'Faturado', 0, 'Boleto', NULL),
(27, 6, '2025-09-18', 'Expedido', 0, 'Boleto', NULL),
(28, 4, '2025-09-24', 'Expedido', 0, 'Boleto', NULL),
(29, 8, '2025-09-18', 'Aberto', 0, 'PIX', 'Pedido recorrente - cliente atacado'),
(30, 3, '2025-09-19', 'Expedido', 0, 'PIX', NULL),
(31, 10, '2025-09-06', 'Expedido', 0, 'Boleto', NULL),
(32, 4, '2025-09-17', 'Faturado', 0, 'PIX', 'Pedido recorrente - cliente atacado'),
(33, 6, '2025-09-01', 'Expedido', 0, 'Boleto', NULL),
(34, 4, '2025-09-16', 'Expedido', 0, 'Boleto', 'Pedido recorrente - cliente atacado'),
(35, 3, '2025-09-04', 'Faturado', 0, 'Cartao', NULL),
(36, 7, '2025-09-02', 'Faturado', 0, 'Boleto', NULL),
(37, 6, '2025-09-05', 'Faturado', 0, 'PIX', NULL),
(38, 9, '2025-09-18', 'Expedido', 0, 'PIX', NULL),
(39, 9, '2025-09-29', 'Expedido', 0, 'PIX', NULL),
(40, 8, '2025-09-10', 'Faturado', 0, 'Boleto', 'Pedido recorrente - cliente atacado'),
(41, 5, '2025-09-28', 'Aberto', 0, 'PIX', NULL),
(42, 9, '2025-09-13', 'Expedido', 0, 'Boleto', NULL),
(43, 6, '2025-09-11', 'Expedido', 0, 'PIX', NULL),
(44, 5, '2025-09-30', 'Expedido', 0, 'PIX', NULL),
(45, 4, '2025-09-03', 'Expedido', 0, 'Cartao', NULL),
(46, 10, '2025-09-26', 'Aberto', 0, 'PIX', NULL),
(47, 9, '2025-09-24', 'Aberto', 0, 'PIX', NULL),
(48, 8, '2025-09-28', 'Expedido', 0, 'Boleto', NULL),
(49, 3, '2025-09-24', 'Faturado', 0, 'Boleto', NULL),
(50, 6, '2025-09-27', 'Expedido', 0, 'Boleto', NULL),
(51, 3, '2025-09-08', 'Expedido', 0, 'Cartao', NULL),
(52, 10, '2025-09-26', 'Expedido', 0, 'Cartao', NULL),
(53, 9, '2025-09-26', 'Expedido', 0, 'Cartao', NULL),
(54, 9, '2025-09-08', 'Expedido', 0, 'Cartao', NULL),
(55, 4, '2025-09-28', 'Expedido', 0, 'Cartao', NULL),
(56, 1, '2025-09-29', 'Expedido', 0, 'PIX', NULL),
(57, 4, '2025-09-20', 'Aberto', 0, 'PIX', 'Pedido recorrente - cliente atacado'),
(58, 6, '2025-09-26', 'Aberto', 0, 'Boleto', NULL),
(59, 7, '2025-09-04', 'Expedido', 0, 'Boleto', NULL),
(60, 4, '2025-09-05', 'Expedido', 0, 'Cartao', NULL),
(61, 8, '2025-09-10', 'Expedido', 0, 'PIX', 'Pedido recorrente - cliente atacado'),
(62, 5, '2025-09-26', 'Expedido', 0, 'Boleto', NULL),
(63, 8, '2025-09-22', 'Expedido', 0, 'PIX', 'Pedido recorrente - cliente atacado'),
(64, 9, '2025-09-19', 'Expedido', 0, 'Boleto', NULL),
(65, 8, '2025-09-04', 'Faturado', 0, 'PIX', 'Pedido recorrente - cliente atacado'),
(66, 2, '2025-09-05', 'Faturado', 0, 'Boleto', NULL),
(67, 4, '2025-09-30', 'Aberto', 0, 'Cartao', NULL),
(68, 1, '2025-09-10', 'Expedido', 0, 'Cartao', NULL),
(69, 4, '2025-09-05', 'Expedido', 0, 'PIX', NULL),
(70, 4, '2025-09-25', 'Cancelado', 0, 'Boleto', 'Pedido recorrente - cliente atacado'),
(71, 4, '2025-09-29', 'Faturado', 0, 'Boleto', 'Pedido recorrente - cliente atacado'),
(72, 8, '2025-09-13', 'Expedido', 0, 'Cartao', NULL),
(73, 3, '2025-09-11', 'Expedido', 0, 'Cartao', NULL),
(74, 5, '2025-09-24', 'Aberto', 0, 'PIX', NULL),
(75, 1, '2025-09-05', 'Expedido', 0, 'PIX', NULL),
(76, 2, '2025-09-20', 'Expedido', 0, 'PIX', NULL),
(77, 6, '2025-09-27', 'Expedido', 0, 'PIX', NULL);

-- ITEM_PEDIDO (104 adicionais) — a última linha (produto 1 no pedido 21,
-- R$399,00) é uma anomalia de preço deliberada para a consulta de
-- auditoria 9.5 ter algo concreto para encontrar na demonstração.
INSERT INTO item_pedido (id_item_pedido, pedido_id, produto_id, quantidade, preco_unitario) VALUES
(26, 16, 2, 3, 480.00),
(27, 17, 4, 1, 295.00),
(28, 18, 5, 1, 410.00),
(29, 19, 6, 1, 90.62),
(30, 20, 2, 5, 480.00),
(31, 20, 4, 7, 295.00),
(32, 21, 5, 3, 410.00),
(33, 21, 1, 6, 480.00),
(34, 22, 2, 7, 480.00),
(35, 22, 5, 4, 410.00),
(36, 23, 1, 1, 480.00),
(37, 23, 2, 2, 480.00),
(38, 24, 7, 2, 65.00),
(39, 24, 6, 1, 95.00),
(40, 25, 7, 1, 65.00),
(41, 25, 3, 1, 320.00),
(42, 25, 2, 1, 480.00),
(43, 26, 7, 3, 65.00),
(44, 27, 5, 3, 410.00),
(45, 27, 7, 2, 65.00),
(46, 28, 2, 8, 480.00),
(47, 28, 7, 4, 65.00),
(48, 29, 8, 5, 120.00),
(49, 29, 1, 5, 480.00),
(50, 30, 2, 3, 480.00),
(51, 30, 7, 1, 65.00),
(52, 31, 7, 3, 65.00),
(53, 31, 2, 3, 480.00),
(54, 31, 5, 3, 410.00),
(55, 32, 2, 7, 480.00),
(56, 33, 4, 1, 295.00),
(57, 33, 1, 1, 480.00),
(58, 34, 8, 6, 120.00),
(59, 35, 8, 3, 117.14),
(60, 36, 2, 1, 480.00),
(61, 37, 4, 1, 295.00),
(62, 38, 1, 1, 480.00),
(63, 38, 8, 2, 120.00),
(64, 39, 7, 2, 65.00),
(65, 40, 8, 3, 120.00),
(66, 40, 2, 7, 462.02),
(67, 40, 7, 3, 65.00),
(68, 41, 2, 1, 457.30),
(69, 42, 1, 3, 468.62),
(70, 43, 6, 2, 95.00),
(71, 43, 2, 3, 480.00),
(72, 44, 2, 3, 480.00),
(73, 44, 1, 2, 480.00),
(74, 45, 8, 8, 120.00),
(75, 46, 5, 1, 410.00),
(76, 46, 6, 1, 95.00),
(77, 47, 4, 3, 295.00),
(78, 48, 1, 5, 462.40),
(79, 48, 8, 4, 120.00),
(80, 49, 1, 1, 480.00),
(81, 49, 8, 3, 120.00),
(82, 50, 7, 1, 65.00),
(83, 50, 2, 1, 480.00),
(84, 51, 7, 3, 65.00),
(85, 51, 5, 1, 410.00),
(86, 52, 6, 2, 95.00),
(87, 53, 2, 2, 480.00),
(88, 54, 4, 1, 282.53),
(89, 55, 7, 7, 65.00),
(90, 56, 5, 1, 410.00),
(91, 56, 1, 2, 480.00),
(92, 57, 4, 8, 295.00),
(93, 58, 4, 2, 288.09),
(94, 58, 3, 2, 320.00),
(95, 59, 7, 2, 65.00),
(96, 60, 7, 4, 65.00),
(97, 60, 6, 5, 95.00),
(98, 61, 6, 6, 95.00),
(99, 62, 6, 1, 95.00),
(100, 63, 3, 6, 320.00),
(101, 63, 1, 3, 480.00),
(102, 64, 8, 1, 120.00),
(103, 64, 4, 3, 289.11),
(104, 65, 8, 4, 120.00),
(105, 66, 6, 2, 95.00),
(106, 66, 7, 3, 65.00),
(107, 67, 8, 8, 120.00),
(108, 67, 4, 7, 295.00),
(109, 67, 3, 4, 320.00),
(110, 68, 2, 1, 480.00),
(111, 69, 6, 6, 93.41),
(112, 70, 7, 5, 65.00),
(113, 71, 4, 6, 295.00),
(114, 71, 8, 6, 120.00),
(115, 72, 1, 3, 464.23),
(116, 72, 4, 6, 295.00),
(117, 72, 5, 5, 410.00),
(118, 73, 7, 2, 65.00),
(119, 74, 6, 1, 95.00),
(120, 74, 2, 3, 456.60),
(121, 74, 8, 1, 120.00),
(122, 75, 2, 1, 480.00),
(123, 75, 5, 2, 410.00),
(124, 76, 2, 2, 480.00),
(125, 76, 5, 2, 410.00),
(126, 76, 1, 3, 480.00),
(127, 77, 5, 3, 410.00),
(128, 77, 7, 1, 65.00),
(129, 21, 1, 1, 399.00);


-- =====================================================================
-- 5) SELECT com JOIN
-- =====================================================================

-- 5.1 Pedidos com nome do cliente e total do pedido
SELECT p.id_pedido, c.nome AS cliente, p.data_pedido, p.status, p.valor_total
FROM pedido p
JOIN cliente c ON c.id_cliente = p.cliente_id
ORDER BY p.data_pedido;

-- 5.2 Itens de um pedido específico, com o nome do produto
SELECT ip.id_item_pedido, pr.nome AS produto, ip.quantidade, ip.preco_unitario, ip.subtotal
FROM item_pedido ip
JOIN produto pr ON pr.id_produto = ip.produto_id
WHERE ip.pedido_id = 4;

-- 5.3 Ficha técnica "legível": produto, insumo e quantidade necessária
SELECT pr.nome AS produto, i.nome_insumo AS insumo, ft.quantidade_necessaria, i.unidade_medida
FROM ficha_tecnica ft
JOIN produto pr ON pr.id_produto = ft.produto_id
JOIN insumo  i  ON i.id_insumo  = ft.insumo_id
ORDER BY pr.nome, i.nome_insumo;

-- 5.4 Produtos com o fornecedor de cada insumo usado neles (join triplo)
SELECT DISTINCT pr.nome AS produto, f.nome AS fornecedor, f.categoria_fornecedor
FROM ficha_tecnica ft
JOIN produto    pr ON pr.id_produto = ft.produto_id
JOIN insumo     i  ON i.id_insumo  = ft.insumo_id
JOIN fornecedor f  ON f.id_fornecedor = i.fornecedor_id
ORDER BY pr.nome;

-- 5.5 Pedidos com detalhe de especialização do produto vendido
-- (LEFT JOIN em bolsa e acessorio, já que cada produto só aparece em um dos dois)
SELECT p.id_pedido, pr.nome AS produto, pr.tipo_produto,
       b.cor AS cor_bolsa, a.cor AS cor_acessorio
FROM item_pedido ip
JOIN pedido  p  ON p.id_pedido  = ip.pedido_id
JOIN produto pr ON pr.id_produto = ip.produto_id
LEFT JOIN bolsa     b ON b.id_produto = pr.id_produto
LEFT JOIN acessorio a ON a.id_produto = pr.id_produto
ORDER BY p.id_pedido;


-- =====================================================================
-- 6) UPDATE
-- =====================================================================

-- 6.1 Recalcula o valor_total de TODOS os pedidos a partir dos itens
-- (mantém a denormalização de pedido.valor_total consistente — rodar
-- sempre que item_pedido for alterado)
UPDATE pedido p
SET valor_total = (
    SELECT COALESCE(SUM(ip.subtotal), 0)
    FROM item_pedido ip
    WHERE ip.pedido_id = p.id_pedido
);

-- 6.2 Reajuste de preço: aumenta em 5% o preco_base de todos os produtos
-- da categoria "Linha Executiva" (não afeta pedidos já registrados,
-- porque item_pedido.preco_unitario fica congelado)
UPDATE produto
SET preco_base = ROUND(preco_base * 1.05, 2)
WHERE categoria = 'Linha Executiva';

-- 6.3 Entrada de compra: soma 50 M2 de couro caramelo ao estoque
UPDATE insumo
SET estoque_atual = estoque_atual + 50.00
WHERE id_insumo = 1;

-- 6.4 Expedição: marca como "Expedido" os pedidos que estavam "Faturado"
-- e têm mais de 5 dias desde o registro (regra fictícia, só para
-- demonstrar UPDATE condicional em lote)
UPDATE pedido
SET status = 'Expedido'
WHERE status = 'Faturado'
  AND data_pedido <= DATE_SUB('2025-05-15', INTERVAL 5 DAY);


-- =====================================================================
-- 7) DELETE
-- =====================================================================

-- 7.1 Remove os itens e o pedido cancelado (ordem respeita a FK:
-- item_pedido tem ON DELETE CASCADE para pedido, então apagar o
-- pedido já apaga os itens — mas deixamos explícito por clareza)
DELETE FROM item_pedido WHERE pedido_id = 7;
DELETE FROM pedido WHERE id_pedido = 7 AND status = 'Cancelado';

-- 7.2 Remove um insumo que nunca foi usado em nenhuma ficha técnica
-- (a caixa de papelão é embalagem de envio, não insumo de produção —
-- ver Seção 9, consulta de auditoria 9.3, que identifica esse caso)
DELETE FROM insumo
WHERE id_insumo = 10
  AND id_insumo NOT IN (SELECT insumo_id FROM ficha_tecnica);


-- =====================================================================
-- 8) CONSULTAS GERENCIAIS
-- =====================================================================

-- 8.1 Faturamento por mês (pedidos faturados ou expedidos)
SELECT DATE_FORMAT(data_pedido, '%Y-%m') AS mes, SUM(valor_total) AS faturamento
FROM pedido
WHERE status IN ('Faturado', 'Expedido')
GROUP BY DATE_FORMAT(data_pedido, '%Y-%m')
ORDER BY mes;

-- 8.2 Curva ABC — produtos mais vendidos por quantidade
SELECT pr.nome AS produto, SUM(ip.quantidade) AS unidades_vendidas,
       SUM(ip.subtotal) AS receita_total
FROM item_pedido ip
JOIN produto pr ON pr.id_produto = ip.produto_id
GROUP BY pr.id_produto, pr.nome
ORDER BY unidades_vendidas DESC;

-- 8.3 Margem estimada por produto (preço base - custo de matéria-prima
-- calculado a partir da ficha técnica)
SELECT pr.nome AS produto,
       pr.preco_base,
       ROUND(SUM(ft.quantidade_necessaria * i.preco_unitario), 2) AS custo_materia_prima,
       ROUND(pr.preco_base - SUM(ft.quantidade_necessaria * i.preco_unitario), 2) AS margem_estimada
FROM produto pr
JOIN ficha_tecnica ft ON ft.produto_id = pr.id_produto
JOIN insumo i ON i.id_insumo = ft.insumo_id
GROUP BY pr.id_produto, pr.nome, pr.preco_base
ORDER BY margem_estimada DESC;

-- 8.4 Ranking de clientes por valor total comprado
SELECT c.nome AS cliente, COUNT(p.id_pedido) AS total_pedidos, SUM(p.valor_total) AS valor_acumulado
FROM cliente c
JOIN pedido p ON p.cliente_id = c.id_cliente
WHERE p.status <> 'Cancelado'
GROUP BY c.id_cliente, c.nome
ORDER BY valor_acumulado DESC;

-- 8.5 Consumo total de cada insumo, projetado a partir das vendas
-- (quantidade vendida de cada produto × quantidade do insumo na ficha técnica)
SELECT i.nome_insumo, i.unidade_medida,
       ROUND(SUM(ip.quantidade * ft.quantidade_necessaria), 3) AS consumo_projetado
FROM item_pedido ip
JOIN ficha_tecnica ft ON ft.produto_id = ip.produto_id
JOIN insumo i ON i.id_insumo = ft.insumo_id
GROUP BY i.id_insumo, i.nome_insumo, i.unidade_medida
ORDER BY consumo_projetado DESC;


-- =====================================================================
-- 9) CONSULTAS DE AUDITORIA
-- =====================================================================

-- 9.1 Pedidos cujo valor_total NÃO bate com a soma real dos itens
-- (detecta inconsistência de denormalização — deveria vir vazio logo
-- após rodar o UPDATE 6.1)
SELECT p.id_pedido, p.valor_total AS valor_armazenado,
       COALESCE(SUM(ip.subtotal), 0) AS valor_real
FROM pedido p
LEFT JOIN item_pedido ip ON ip.pedido_id = p.id_pedido
GROUP BY p.id_pedido, p.valor_total
HAVING valor_armazenado <> valor_real;

-- 9.2 Produtos sem nenhuma linha de ficha técnica (BOM incompleta)
SELECT pr.id_produto, pr.nome
FROM produto pr
LEFT JOIN ficha_tecnica ft ON ft.produto_id = pr.id_produto
WHERE ft.produto_id IS NULL;

-- 9.3 Insumos nunca utilizados em nenhuma ficha técnica
-- (vem vazia neste script porque o único caso — a caixa de papelão,
-- insumo 10 — já foi removido na Seção 7.2, justamente a partir deste
-- tipo de verificação; numa auditoria de rotina, rode esta consulta
-- ANTES de decidir qualquer DELETE)
SELECT i.id_insumo, i.nome_insumo
FROM insumo i
LEFT JOIN ficha_tecnica ft ON ft.insumo_id = i.id_insumo
WHERE ft.insumo_id IS NULL;

-- 9.4 Checagem da especialização TOTAL e DISJUNTA de PRODUTO:
-- todo produto deve existir em exatamente uma das tabelas BOLSA/ACESSORIO,
-- de acordo com o seu tipo_produto. Esta consulta deveria vir vazia;
-- se trouxer linhas, a regra "Total e Disjunta" do DER foi violada.
SELECT pr.id_produto, pr.nome, pr.tipo_produto,
       (b.id_produto IS NOT NULL) AS tem_linha_bolsa,
       (a.id_produto IS NOT NULL) AS tem_linha_acessorio
FROM produto pr
LEFT JOIN bolsa     b ON b.id_produto = pr.id_produto
LEFT JOIN acessorio a ON a.id_produto = pr.id_produto
WHERE (pr.tipo_produto = 'BOLSA'     AND (b.id_produto IS NULL OR a.id_produto IS NOT NULL))
   OR (pr.tipo_produto = 'ACESSORIO' AND (a.id_produto IS NULL OR b.id_produto IS NOT NULL));

-- 9.5 Itens de pedido cujo preço praticado destoa muito do preço base
-- atual do produto (possível erro de digitação ou promoção não documentada)
SELECT ip.id_item_pedido, pr.nome AS produto, ip.preco_unitario, pr.preco_base,
       ROUND(100 * (ip.preco_unitario - pr.preco_base) / pr.preco_base, 1) AS variacao_percentual
FROM item_pedido ip
JOIN produto pr ON pr.id_produto = ip.produto_id
WHERE ABS(ip.preco_unitario - pr.preco_base) / pr.preco_base > 0.10
ORDER BY ABS(variacao_percentual) DESC;

-- 9.6 Fornecedores sem nenhum insumo cadastrado (cadastro incompleto)
-- (traz "Embalagens Proteção Total" neste script, como efeito colateral
-- esperado da Seção 7.2 — o único insumo desse fornecedor era a caixa
-- de papelão removida; indica que o fornecedor precisa de um novo
-- insumo cadastrado ou ser reavaliado)
SELECT f.id_fornecedor, f.nome
FROM fornecedor f
LEFT JOIN insumo i ON i.fornecedor_id = f.id_fornecedor
WHERE i.id_insumo IS NULL;
