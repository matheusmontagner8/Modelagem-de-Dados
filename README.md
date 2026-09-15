## Metadados

Nome: Guilherme da Silva Ferreira Batista  RGM: 47302518
Nome: Guilherme Petrucelli Domingos  RGM: 47270161
Nome: Jaime Luiz de Oliveira Neto  RGM: 47336951
Nome: Matheus Montagner  RGM: 47209470
Nome: Vinicius Marques de Melo  RGM: 47213426

## 1. Caracterização da Organização


- **Nome e natureza da organização:**  🔴 PENDENTE. O questionário usado como base trata de uma "Indústria & Comércio de Bolsas de Couro" — uma empresa com fins lucrativos que fabrica e vende bolsas de couro (produção própria + venda direta e por canais diversos). Substituam pelo nome real da organização escolhida pelo grupo, mantendo a mesma natureza de negócio se for essa a organização visitada.
- **Contexto e porte:** com fins lucrativos; opera simultaneamente como indústria (fabricação artesanal/semi-artesanal, com etapas de corte, costura e montagem executadas por artesãos internos e facções terceirizadas) e comércio (venda em loja física, e-commerce, WhatsApp e representantes externos). O uso de facções terceirizadas e o controle de aproveitamento de couro por corte sugerem uma operação de pequeno a médio porte, com produção sob encomenda/lote (não em larga escala industrial). Confirmem esses números com a visita de campo: quantidade de artesãos/funcionários, volume médio de pedidos por mês e faturamento aproximado.
- **Problemas e necessidades identificados:** o levantamento de requisitos aponta processos hoje prováveis de estarem descentralizados/manuais: controle de estoque de insumos (couro, ferragens, zíperes) sem rastreabilidade de lote; ausência de regra formal de crédito para vendas a prazo; cálculo de custo/preço de venda não padronizado (ficha técnica); acompanhamento de produção sem visibilidade de status; e falta de integração entre vendas, estoque e financeiro (títulos a pagar/receber gerados manualmente). Confirmem com a organização real quais desses pontos realmente batem com a "crise operacional" observada.
- **Justificativa da escolha:** Uma empresa que a gente sabia que ia ter acesso fácil e que consideramos de porte médio, não deixando nem tão simples e nem tão complicado o nosso trabalho.
- **Evidências da organização:** 🔴 PENDENTE — anexem fotos da visita, link da organização no Google (Maps/Meu Negócio, site ou rede social), endereço completo e forma de contato (telefone/e-mail do responsável).

---

## 2. Processos de Negócio


**Principais processos mapeados** (extraídos do levantamento de requisitos, um por bloco do questionário):

1. **Cadastro e gestão de clientes** — cadastro com múltiplos endereços, perfil de preço (varejo/atacado) e aprovação de crédito.
2. **Cadastro e gestão de fornecedores** — dados do fornecedor, categoria de insumo e histórico de compras/avaliação.
3. **Ficha técnica e cadastro de produtos** — modelo → variação (SKU) → lista de materiais (BOM) com cálculo de custo.
4. **Gestão de estoque e compras** — entrada de insumo (XML de NF-e ou manual), controle por unidade de medida, estoque mínimo e baixa automática.
5. **Ordem de produção e chão de fábrica** — abertura de OP, execução por etapa (Modelagem → Corte → Preparação/Colagem → Costura → Montagem/Ferragens → Acabamento/Revisão → Embalagem), com Kanban e controle de aproveitamento de couro.
6. **Vendas, pedidos e faturamento** — pedido multicanal, forma de pagamento, comissão e emissão de NF-e/NFC-e.
7. **Expedição e pós-venda** — picking & packing, integração logística e garantia (RMA).
8. **Gestão financeira e relatórios gerenciais** — Contas a Pagar/Receber automáticos e indicadores (Curva ABC, DRE, fluxo de caixa).

- **Fluxogramas:** *(opcional — recomenda-se pelo menos o fluxo da Ordem de Produção, por ser o processo com mais etapas sequenciais)* 🔴 PENDENTE se o grupo optar por incluir.

---

## 3. Requisitos do Sistema

### 3.1 Requisitos Funcionais

| # | O sistema deve permitir... |
|---|---|
| RF01 | Cadastrar clientes com razão social/nome, CNPJ/CPF, inscrição estadual (quando lojista), e-mail para NF-e, telefone/WhatsApp e comprador responsável. |
| RF02 | Registrar múltiplos endereços por cliente (matriz, entrega, cobrança). |
| RF03 | Diferenciar clientes por perfil (Varejo Final × Atacado/Lojista) com regras de preço distintas. |
| RF04 | Consultar restrição de CPF/CNPJ e aplicar limite de crédito para boleto, exigindo aprovação financeira para novos lojistas. |
| RF05 | Cadastrar fornecedores com categoria de insumo, contato do vendedor e prazo médio de entrega. |
| RF06 | Registrar entrada de insumos por lote, vinculando fornecedor, cor/tonalidade e preço pago (rastreabilidade). |
| RF07 | Manter histórico de compras e avaliação por fornecedor (preço, variação, pontualidade de entrega). |
| RF08 | Cadastrar produtos por modelo e variação (SKU), combinando cor, tipo de couro e tipo de ferragem. |
| RF09 | Manter a Ficha Técnica (BOM) de cada SKU, com a quantidade de cada insumo necessária. |
| RF10 | Calcular automaticamente o custo total e sugerir preço de venda a partir da Ficha Técnica, mão de obra e markup. |
| RF11 | Registrar entrada de matéria-prima via XML de NF-e ou digitação manual. |
| RF12 | Controlar o estoque de insumos nas unidades apropriadas (dm²/m², unidade/metro, kg/L), com estoque mínimo e alerta automático. |
| RF13 | Baixar automaticamente o estoque de insumos na abertura da Ordem de Produção. |
| RF14 | Abrir Ordens de Produção vinculadas a um SKU e acompanhar o status em painel Kanban (Aguardando/Em Corte/Em Costura/Finalizado). |
| RF15 | Registrar, por etapa de produção, o artesão/facção responsável e o percentual de aproveitamento/perda de couro na etapa de Corte. |
| RF16 | Registrar pedidos de venda por canal (loja física, e-commerce, WhatsApp, representante), com forma de pagamento e parcelamento. |
| RF17 | Calcular comissão de vendedores/representantes sobre pedidos faturados, com percentuais diferenciados por canal. |
| RF18 | Emitir NF-e (venda mercantil) e NFC-e (cupom varejo), nativamente ou por integração. |
| RF19 | Controlar separação, conferência (código de barras) e embalagem (checklist + dust bag) antes do envio. |
| RF20 | Integrar com serviços de logística (Correios, Melhor Envio, transportadoras parceiras) para etiquetas e rastreio. |
| RF21 | Registrar trocas, devoluções e garantias (RMA) vinculadas ao item efetivamente entregue. |
| RF22 | Gerar lançamentos automáticos de Contas a Receber (vendas faturadas) e Contas a Pagar (compras). |
| RF23 | Gerar relatórios gerenciais: Curva ABC, margem de lucro por modelo, DRE gerencial, fluxo de caixa previsto × realizado, estoque parado. |
| RF24 | Restringir o acesso por perfil de usuário (Vendedor, Gerente de Produção, Financeiro, Administrador). |

### 3.2 Requisitos Não Funcionais

| # | Característica de qualidade |
|---|---|
| RNF01 | **Desempenho:** consultas de estoque e ficha técnica devem responder rápido o suficiente para não atrasar a abertura de uma Ordem de Produção. |
| RNF02 | **Segurança:** controle de acesso por perfil (RF24) e proteção de dados pessoais de clientes/fornecedores (LGPD). |
| RNF03 | **Disponibilidade:** o módulo de estoque/OP precisa estar disponível no horário de produção, já que a baixa de insumo é automática e bloqueante. |
| RNF04 | **Usabilidade:** o painel Kanban de produção deve ser operável pelos artesãos/facções sem treinamento extenso. |
| RNF05 | **Integridade transacional:** baixa de estoque, geração de título financeiro e emissão de nota fiscal devem ocorrer de forma atômica (tudo ou nada). |
| RNF06 | **Auditabilidade:** histórico de preços por fornecedor e de status de OP deve ser preservado para consultas gerenciais futuras. |

---

## 4. Regras de Negócio

- **Regras operacionais:**
  - Inscrição Estadual só é obrigatória quando o perfil do cliente é Atacado/Lojista.
  - Toda variação de produto (SKU) pertence a exatamente um modelo; um modelo pode ter uma ou várias variações.
  - A baixa de estoque de insumo ocorre automaticamente na abertura da Ordem de Produção (reserva de material necessário).
  - Todo insumo recebido é registrado com lote e fornecedor de origem, para garantir rastreabilidade de cor/textura entre peças da mesma coleção.
  - Comissão padrão de vendedor é de 5% sobre pedidos faturados, com percentual diferenciado entre canal de atacado e varejo.
  - Um chamado de garantia (RMA) está sempre associado a um item de pedido específico, nunca ao pedido inteiro.
  - Um pedido só é expedido depois de checklist de saída e conferência dos itens (leitura de código de barras).

- **Restrições organizacionais:**
  - Exigência legal de emissão de NF-e (venda mercantil) ou NFC-e (cupom fiscal varejo), conforme o canal de venda.
  - Dados pessoais de clientes e fornecedores (nome, CPF/CNPJ, contato) exigem tratamento conforme a LGPD.
  - O prazo médio de entrega de cada fornecedor impacta diretamente o planejamento da produção (lead time de insumo).
  - O pagamento de artesãos/facções terceirizadas depende do registro fiel de qual etapa cada um executou — sem esse registro não há como calcular a remuneração por produção.

---

## 5. Dicionário de Dados Conceitual (Preliminar)


> Formato oficial da disciplina: por entidade, `Atributo | Descrição | Regra de negócio associada`. As 21 entidades abaixo cobrem as 8 seções do levantamento de requisitos.

### CLIENTE
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_cliente | Identificador interno do cliente | Chave primária |
| razao_social_nome | Razão social (PJ) ou nome completo (PF) | Obrigatório |
| cnpj_cpf | Documento fiscal do cliente | Usado na consulta de restrição de crédito |
| inscricao_estadual | Registro estadual do cliente | Obrigatório apenas se perfil = Atacado/Lojista |
| email_nfe | E-mail para envio da nota fiscal eletrônica | — |
| telefone_whatsapp | Contato principal | — |
| nome_comprador_responsavel | Pessoa de contato para compras | — |
| perfil_cliente | Classificação comercial | Domínio: Varejo Final / Atacado-Lojista — define a régua de preço |
| limite_credito | Teto de faturamento via boleto | Referência observada: R$10.000,00 |
| status_aprovacao_financeira | Situação de aprovação de crédito | Domínio: Pendente / Aprovado / Reprovado — obrigatório para novo lojista |

### ENDERECO_CLIENTE *(entidade fraca — depende de CLIENTE)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_endereco | Identificador do endereço | Chave primária |
| cod_cliente | Cliente ao qual o endereço pertence | Chave estrangeira → CLIENTE |
| tipo_endereco | Finalidade do endereço | Domínio: Matriz / Entrega / Cobrança |
| logradouro | Rua/avenida e número | — |
| cidade | Cidade | — |
| uf | Unidade federativa | — |
| cep | Código postal | — |

### FORNECEDOR
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_fornecedor | Identificador do fornecedor | Chave primária |
| razao_social | Nome empresarial do fornecedor | — |
| cnpj | Documento fiscal | — |
| inscricao_estadual | Registro estadual | — |
| categoria_insumo | Tipo de insumo fornecido | Domínio: Curtume/Couro, Ferragens/Fivelas, Zíperes/Aviamentos, Embalagens/Caixas |
| contato_vendedor | Pessoa de contato comercial | — |
| prazo_medio_entrega_dias | Lead time médio de entrega | Usado no planejamento de produção |

### INSUMO
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_insumo | Identificador do insumo | Chave primária |
| descricao_insumo | Nome do insumo (ex.: Couro Bovino Caramelo) | — |
| categoria_insumo | Categoria do insumo | — |
| unidade_medida | Unidade de controle de estoque | Domínio: dm², m², unidade, metro, kg, litro |
| estoque_minimo | Saldo mínimo configurável | Dispara alerta automático de recompra |
| saldo_estoque_atual | Saldo atual em estoque | Atualizado a cada entrada/baixa |

### LOTE_INSUMO *(entidade fraca — depende de INSUMO, FORNECEDOR e COMPRA)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_lote | Identificador do lote | Chave primária |
| cod_insumo | Insumo recebido | Chave estrangeira → INSUMO |
| cod_fornecedor | Fornecedor de origem | Chave estrangeira → FORNECEDOR |
| cod_compra | Compra que originou o lote | Chave estrangeira → COMPRA |
| numero_lote | Identificação do lote (ex.: 2026-A) | Garante rastreabilidade de cor/textura |
| data_recebimento | Data de entrada no estoque | — |
| quantidade_recebida | Quantidade recebida | — |
| cor_tonalidade | Cor/tonalidade do insumo (couro) | — |
| preco_pago | Preço pago nesse recebimento | Alimenta o histórico de preço por fornecedor |

### COMPRA
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_compra | Identificador da compra | Chave primária |
| cod_fornecedor | Fornecedor da compra | Chave estrangeira → FORNECEDOR |
| numero_compra | Número/identificação da compra | — |
| data_compra | Data da compra | — |
| forma_entrada | Origem do lançamento | Domínio: XML de NF-e / Manual |
| valor_total | Valor total da compra | — |
| taxa_pontualidade_entrega | Percentual de pontualidade apurado | Alimenta a avaliação histórica do fornecedor |

### CONTAS_PAGAR
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_titulo_pagar | Identificador do título | Chave primária |
| cod_compra | Compra que gerou o título | Chave estrangeira → COMPRA |
| valor | Valor do título | — |
| data_vencimento | Data de vencimento | — |
| data_pagamento | Data em que foi pago | Nulo até a baixa |
| status_pagamento | Situação do título | Domínio: Aberto / Pago / Atrasado |

### MODELO_PRODUTO
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_modelo | Identificador do modelo | Chave primária |
| nome_modelo | Nome do modelo (ex.: Bolsa Tote) | — |
| descricao | Descrição do modelo | — |

### VARIACAO_PRODUTO *(SKU)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_sku | Identificador da variação | Chave primária |
| cod_modelo | Modelo ao qual pertence | Chave estrangeira → MODELO_PRODUTO |
| codigo_sku | Código comercial (ex.: SKU-BOLSA-TOTE-CAR-UNI) | — |
| cor | Cor da variação | — |
| tipo_couro | Tipo de couro utilizado | Ex.: Bovino Vaqueta, Mestiço |
| tipo_ferragem | Tipo de ferragem utilizada | Ex.: Dourada, Prata, Escovada |
| preco_venda_sugerido | Preço de venda calculado | (insumos + mão de obra + rateio) × markup |
| tempo_estimado_mao_obra_min | Tempo estimado de produção | — |

### ITEM_FICHA_TECNICA *(entidade associativa — BOM)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_sku | Variação de produto | Chave primária composta + FK → VARIACAO_PRODUTO |
| cod_insumo | Insumo utilizado | Chave primária composta + FK → INSUMO |
| quantidade_necessaria | Quantidade do insumo por unidade produzida | Ex.: dm² de couro, unidades de zíper, metros de linha |
| unidade_medida_item | Unidade da quantidade necessária | — |

### ARTESAO_FACCAO
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_artesao | Identificador do artesão/facção | Chave primária |
| nome | Nome do artesão ou razão social da facção | — |
| tipo_vinculo | Natureza do vínculo | Domínio: Artesão Interno / Facção Terceirizada |
| telefone | Contato | — |

### ETAPA_PRODUCAO *(catálogo)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_etapa | Identificador da etapa | Chave primária |
| nome_etapa | Nome da etapa | Modelagem, Corte, Preparação/Colagem, Costura, Montagem/Ferragens, Acabamento/Revisão, Embalagem |
| ordem_sequencial | Posição da etapa no fluxo produtivo | Define a sequência do Kanban |

### ORDEM_PRODUCAO
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_op | Identificador da ordem de produção | Chave primária |
| cod_sku | Variação de produto a ser produzida | Chave estrangeira → VARIACAO_PRODUTO |
| numero_op | Número da OP | — |
| data_abertura | Data de abertura | Dispara a reserva/baixa automática de insumos |
| quantidade_produzir | Quantidade a produzir | — |
| status_kanban | Status atual da OP | Domínio: Aguardando / Em Corte / Em Costura / Finalizado |

### EXECUCAO_ETAPA *(entidade associativa)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_execucao | Identificador da execução | Chave primária |
| cod_op | Ordem de produção | Chave estrangeira → ORDEM_PRODUCAO |
| cod_etapa | Etapa executada | Chave estrangeira → ETAPA_PRODUCAO |
| cod_artesao | Responsável pela execução | Chave estrangeira → ARTESAO_FACCAO — base do pagamento por produção |
| data_inicio | Início da execução | — |
| data_fim | Fim da execução | — |
| percentual_aproveitamento | % de aproveitamento do couro | Aplicável à etapa de Corte |
| percentual_perda | % de perda/retalho | Aplicável à etapa de Corte |

### USUARIO
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_usuario | Identificador do usuário | Chave primária |
| nome | Nome do usuário | — |
| login | Login de acesso | — |
| senha_hash | Senha (armazenada com hash) | — |
| perfil_acesso | Perfil de acesso ao sistema | Domínio: Vendedor / Gerente de Produção / Financeiro / Administrador |
| tipo_vendedor | Natureza do vínculo comercial | Domínio: Interno / Representante Externo (nulo se não for vendedor) |
| percentual_comissao | Percentual de comissão | Padrão 5%, diferenciado por atacado/varejo |

### PEDIDO_VENDA
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_pedido | Identificador do pedido | Chave primária |
| cod_cliente | Cliente do pedido | Chave estrangeira → CLIENTE |
| cod_usuario | Vendedor/representante responsável | Chave estrangeira → USUARIO |
| numero_pedido | Número do pedido | — |
| data_pedido | Data do pedido | — |
| canal_venda | Canal de venda | Domínio: Loja Física / E-commerce / WhatsApp / Representante |
| forma_pagamento | Forma de pagamento | Domínio: PIX / Cartão / Boleto |
| condicao_parcelamento | Condição de parcelamento | Ex.: 30/60/90 dias (boleto atacado) |
| status_pedido | Situação do pedido | — |

### ITEM_PEDIDO *(entidade associativa)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_item_pedido | Identificador do item | Chave primária |
| cod_pedido | Pedido ao qual pertence | Chave estrangeira → PEDIDO_VENDA |
| cod_sku | Produto vendido | Chave estrangeira → VARIACAO_PRODUTO |
| quantidade | Quantidade vendida | — |
| preco_unitario_praticado | Preço unitário praticado | — |
| desconto | Desconto aplicado | — |

### NOTA_FISCAL
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_nf | Identificador da nota | Chave primária |
| cod_pedido | Pedido faturado | Chave estrangeira → PEDIDO_VENDA |
| numero_nf | Número da nota | — |
| tipo_nf | Tipo de documento fiscal | Domínio: NF-e (mercantil) / NFC-e (cupom varejo) |
| data_emissao | Data de emissão | — |
| valor_total | Valor total da nota | — |

### CONTAS_RECEBER
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_titulo_receber | Identificador do título | Chave primária |
| cod_pedido | Pedido que gerou o título | Chave estrangeira → PEDIDO_VENDA |
| valor | Valor do título | — |
| data_vencimento | Data de vencimento | — |
| data_recebimento | Data em que foi recebido | — |
| status_recebimento | Situação do título | Domínio: Aberto / Recebido / Atrasado |

### EXPEDICAO *(1:1 com pedido)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_expedicao | Identificador da expedição | Chave primária |
| cod_pedido | Pedido expedido | Chave estrangeira → PEDIDO_VENDA |
| data_envio | Data de envio | — |
| transportadora | Transportadora utilizada | Ex.: Correios, Melhor Envio, parceira |
| codigo_rastreio | Código de rastreamento | — |
| checklist_conferencia | Conferência realizada | Via leitura de código de barras |
| dust_bag_incluso | Saquinho protetor incluído | — |

### RMA_GARANTIA
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| cod_rma | Identificador do chamado | Chave primária |
| cod_item_pedido | Item associado à garantia | Chave estrangeira → ITEM_PEDIDO (não ao pedido inteiro) |
| data_abertura | Data de abertura do chamado | — |
| motivo_defeito | Motivo relatado | — |
| status_rma | Situação do chamado | Domínio: Aberto / Em Reparo / Devolvido |
| data_devolucao | Data de devolução ao cliente | — |

---

## 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)


- **Entidades reconhecidas (21 no total):** as 21 entidades listadas na Seção 5, agrupadas nos 6 blocos de negócio identificados no levantamento — Clientes; Fornecedores/Insumos/Compras; Produtos/Ficha Técnica; Produção; Vendas/Faturamento; Expedição/Financeiro/Pós-venda. Duas são **entidades fracas** (ENDERECO_CLIENTE, LOTE_INSUMO — só existem em função de outra entidade) e três são **entidades associativas** que resolvem relacionamentos N:N com atributos próprios (ITEM_FICHA_TECNICA, EXECUCAO_ETAPA, ITEM_PEDIDO).
- **Atributos e classificações:** detalhados por entidade na Seção 5, com chave primária, chaves estrangeiras e domínios de valor explícitos (ex.: `perfil_cliente`, `status_kanban`, `tipo_nf`).
- **Relacionamentos pertinentes (22 no total):**

| # | Entidade A | Card. A | Verbo | Card. B | Entidade B |
|---|---|---|---|---|---|
| 01 | CLIENTE | (1,1) | possui | (0,N) | ENDERECO_CLIENTE |
| 02 | FORNECEDOR | (1,1) | fornece | (0,N) | LOTE_INSUMO |
| 03 | INSUMO | (1,1) | é recebido como | (0,N) | LOTE_INSUMO |
| 04 | COMPRA | (1,1) | gera | (0,N) | LOTE_INSUMO |
| 05 | FORNECEDOR | (1,1) | recebe pedido de | (0,N) | COMPRA |
| 06 | COMPRA | (1,1) | gera | (0,N) | CONTAS_PAGAR |
| 07 | MODELO_PRODUTO | (1,1) | possui | (1,N) | VARIACAO_PRODUTO |
| 08 | VARIACAO_PRODUTO | (1,1) | é detalhada em | (0,N) | ITEM_FICHA_TECNICA |
| 09 | INSUMO | (1,1) | compõe | (0,N) | ITEM_FICHA_TECNICA |
| 10 | VARIACAO_PRODUTO | (1,1) | é produzida em | (0,N) | ORDEM_PRODUCAO |
| 11 | ORDEM_PRODUCAO | (1,1) | se desdobra em | (0,N) | EXECUCAO_ETAPA |
| 12 | ETAPA_PRODUCAO | (1,1) | classifica | (0,N) | EXECUCAO_ETAPA |
| 13 | ARTESAO_FACCAO | (1,1) | realiza | (0,N) | EXECUCAO_ETAPA |
| 14 | LOTE_INSUMO | (0,N) | é consumido em | (0,N) | ORDEM_PRODUCAO |
| 15 | CLIENTE | (1,1) | realiza | (0,N) | PEDIDO_VENDA |
| 16 | USUARIO | (1,1) | atende | (0,N) | PEDIDO_VENDA |
| 17 | PEDIDO_VENDA | (1,1) | contém | (1,N) | ITEM_PEDIDO |
| 18 | VARIACAO_PRODUTO | (1,1) | é vendida em | (0,N) | ITEM_PEDIDO |
| 19 | PEDIDO_VENDA | (1,1) | gera | (0,N) | NOTA_FISCAL |
| 20 | PEDIDO_VENDA | (1,1) | gera | (0,N) | CONTAS_RECEBER |
| 21 | PEDIDO_VENDA | (1,1) | possui | (0,1) | EXPEDICAO |
| 22 | ITEM_PEDIDO | (1,1) | pode gerar | (0,N) | RMA_GARANTIA |

- **Restrições e políticas organizacionais aplicadas ao modelo:** o limite de crédito e a aprovação financeira (Seção 4) aparecem como atributos de CLIENTE que condicionam a cardinalidade opcional de PEDIDO_VENDA; a rastreabilidade de lote exigida pela organização motivou LOTE_INSUMO ser entidade própria (e não apenas um atributo de INSUMO); o pagamento por produção exigiu que EXECUCAO_ETAPA carregasse o artesão responsável em vez de um campo solto na Ordem de Produção.

---

## 7. Diagrama Entidade-Relacionamento (DER)

**Arquivos anexados:** `DER_Bolsas_Couro.png` (e `DER_Bolsas_Couro.svg`, versão vetorial da mesma imagem) — gerados a partir do modelo desta Seção 6.

O diagrama segue a notação de Chen usada pelo BrModeloWeb: entidades como **retângulos**, relacionamentos como **losangos** rotulados com o verbo, atributos como **elipses** presas à entidade (ou ao relacionamento, no único caso de atributo de relacionamento do modelo — `quantidade_consumida` em "consumido em"), com a **chave primária sublinhada**. Entidade fraca (ENDERECO_CLIENTE) e seu relacionamento identificador ("possui") aparecem com borda dupla. As cardinalidades (mín,máx) ficam junto de cada ponta da linha, exatamente como na tabela da Seção 6.

Uma diferença importante em relação ao dicionário da Seção 5: seguindo a notação conceitual pura, o diagrama **não mostra atributos de chave estrangeira** (ex.: `cod_cliente` dentro de ENDERECO_CLIENTE) — essa informação já está representada pela própria linha do relacionamento. As FKs voltam a aparecer no dicionário porque ali o objetivo é documentar a estrutura completa, inclusive o que se tornará chave estrangeira na Entrega 2.

O modelo já nasce pensando em escalabilidade: entidades como USUARIO e ETAPA_PRODUCAO são catálogos abertos (novos perfis/etapas não exigem redesenho), e o bloco financeiro (CONTAS_PAGAR/CONTAS_RECEBER) está desacoplado o suficiente para integrar com um módulo de BI na Entrega 2 sem alterar as entidades operacionais.

---

## 8. Justificativa Técnica

- **Por que 21 entidades e não menos:** cada entidade corresponde a um substantivo com identidade própria e ciclo de vida distinto no levantamento de requisitos (ex.: um LOTE_INSUMO não é apenas uma característica de INSUMO — ele tem data de recebimento, fornecedor e preço próprios, e precisa ser referenciado individualmente pela Ordem de Produção para rastreabilidade). Fundir entidades como CLIENTE e ENDERECO_CLIENTE em uma tabela só quebraria a regra explícita de múltiplos endereços por cliente (requisito 1.2 do levantamento).
- **Por que entidades fracas:** ENDERECO_CLIENTE e LOTE_INSUMO não têm existência independente — um endereço sem cliente ou um lote sem insumo/fornecedor não fazem sentido no domínio. Modelá-las como fracas (chave dependente) evita chaves substitutas artificiais e deixa a dependência explícita no diagrama.
- **Por que entidades associativas em vez de relacionamentos N:N "soltos":** ITEM_FICHA_TECNICA, EXECUCAO_ETAPA e ITEM_PEDIDO carregam atributos próprios (quantidade, percentual de aproveitamento, preço praticado) que não pertencem a nenhuma das duas entidades que conectam — a notação exige reificá-los como entidade para acomodar esses atributos e permitir que outras entidades (como RMA_GARANTIA) referenciem um item específico, e não o par inteiro.
- **Por que essas cardinalidades e não outras:** cada cardinalidade (0,N) reflete uma regra observada no levantamento (ex.: cliente pode ou não ter pedidos, então CLIENTE–PEDIDO_VENDA é (1,1)-(0,N)); já PEDIDO_VENDA–ITEM_PEDIDO é (1,N) do lado do item porque um pedido sem nenhum item não existe operacionalmente.
- **Alternativas descartadas:** cogitou-se tratar Endereço como atributo multivalorado simples de Cliente (sem entidade própria) — descartado porque endereço tem atributos compostos (logradouro/cidade/UF/CEP) e tipo (matriz/entrega/cobrança), o que exige estrutura própria. Cogitou-se também um único relacionamento genérico "Produto consome Insumo" sem reificação — descartado porque a quantidade necessária por insumo é informação de primeira classe para o cálculo de custo (RF10).

---

## 9. Uso de Inteligência Artificial
*(documentação obrigatória)*

| Item | Registro |
|---|---|
| **Ferramenta e etapa** | Claude (Claude Code / Sonnet 5, Anthropic) — usado em quatro momentos: (1) leitura do questionário de requisitos e construção do modelo conceitual (entidades, atributos, relacionamentos, cardinalidades) e do dicionário de dados; (2) geração de um primeiro diagrama ER (notação "pé-de-galinha"); (3) preenchimento deste README a partir do esqueleto oficial da Entrega 1; (4) reconstrução do diagrama na notação de Chen (retângulo/losango/elipse) usada pelo BrModeloWeb, a pedido explícito do professor. |
| **Motivação** | Acelerar a tradução do levantamento de requisitos (documento em prosa/tabela) para um modelo estruturado (entidades/atributos/cardinalidades) e para o formato de entrega exigido pela disciplina — inclusive a notação específica pedida pelo professor. |
| **Prompt(s) utilizados** | "Preciso montar um diagrama e o dicionário desse diagrama, como se fosse no modelo BrModeloWeb..."; "Consegue gerar um arquivo pdf com isso que me enviou? Contendo somente o diagrama e o dicionário"; "De acordo com o que montamos, responda essas perguntas do drive"; "Consegue ajustar o diagrama, para o modelo usado no BrModeloWeb? Professor falou que a preferência seria nesse modelo". |
| **Resposta recebida** | Um modelo com 21 entidades e 22 relacionamentos; um dicionário de dados completo; este README preenchido; e, por fim, o DER redesenhado em notação de Chen genuína (entidades/relacionamentos/atributos como retângulo/losango/elipse, PK sublinhada, cardinalidades nas pontas), a versão que está de fato anexada na Seção 7. |
| **Fontes consultadas e verificadas** | Nenhuma fonte externa — o modelo foi derivado exclusivamente do texto do questionário de requisitos fornecido pelo grupo. Nenhum dado foi inventado sobre a organização em si (nome, endereço, evidências seguem pendentes, ver Seção 1). |
| **Trechos rejeitados ou corrigidos** | A primeira versão do diagrama usava notação "pé-de-galinha" por preferência da IA (legibilidade); o professor pediu explicitamente a notação de Chen/BrModeloWeb, então o diagrama foi refeito do zero. Nessa reconstrução, a IA também corrigiu um erro de fidelidade conceitual da primeira versão: atributos de chave estrangeira (ex.: `cod_cliente` em ENDERECO_CLIENTE) tinham sido deixados como atributos visíveis, o que não é correto em um diagrama conceitual puro — eles foram removidos das entidades e passaram a ser representados apenas pela linha do relacionamento. Algumas decisões de granularidade (reificar Ficha Técnica, Execução de Etapa e Item de Pedido como entidades associativas, em vez de losangos com atributos) seguem sendo julgamento de modelagem da IA e devem ser validadas pelo grupo. |
| **Justificativa da escolha final** | O grupo manteve a estrutura de 21 entidades por ela cobrir, de forma rastreável, as 8 seções do questionário original sem inventar processos não mencionados. |
| **Reflexão crítica** | O modelo reflete fielmente o texto do questionário, mas não substitui a pesquisa de campo exigida pela atividade — regras de negócio reais da organização escolhida podem divergir do que está aqui (valores de limite de crédito, percentuais de comissão etc. foram tratados como exemplos/referências, não como regras fixas). O grupo deve validar cada regra de negócio da Seção 4 com a organização real antes de assumi-las como definitivas. |


---

## Critérios Atitudinais (20%)
Avaliados por 360º entre os integrantes do grupo — não preenchido neste README.

---

## Resumo dos Pesos

| Dimensão | Peso total |
|----------|-----------|
| Conceitual (contexto, requisitos/regras, modelagem, justificativa técnica) | 30% |
| Procedimental (requisitos, fluxogramas, dicionário de dados, DER) | 50% |
| Atitudinal (participação, comprometimento, colaboração, autonomia) | 20% |

**Entrega final:** README.md completo + DER + Dicionário de Dados em HTML (com exceção dos cursos GTI) anexado no repositório GitHub do grupo.

---

### Checklist do que ainda falta ao grupo (não gerável por IA)

- [ ] Nome real da organização, endereço, contato e evidências de visita (Seção 1)
- [ ] Fluxogramas (opcional, Seção 2)
