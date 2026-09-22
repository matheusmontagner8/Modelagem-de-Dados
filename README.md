## Metadados

| Nome | RGM |
|---|---|
| Guilherme da Silva Ferreira Batista | 47302518 |
| Guilherme Petrucelli Domingos | 47270161 |
| Jaime Luiz de Oliveira Neto | 47336951 |
| Matheus Montagner | 47209470 |
| Vinicius Marques de Melo | 47213426 |

---

## 1. Caracterização da Organização


- **Nome e natureza da organização:**  Contrasti Bolsas e Acessórios Ltda - Fabricação de Bolsas. O questionário usado como base trata de uma "Indústria e Comércio de Bolsas de Couro" — uma empresa com fins lucrativos que fabrica e vende bolsas de couro (produção própria + venda direta e por canais diversos).
- **Contexto e porte:** com fins lucrativos; opera simultaneamente como indústria e comércio (venda em loja física, e-commerce, WhatsApp e representantes externos). O uso de facções terceirizadas e o controle de aproveitamento de couro por corte sugerem uma operação de pequeno a médio porte, com produção sob encomenda/lote (não em larga escala industrial). Volume médio de pedidos por mês entre 50 a 70, aumentando nas datas comemorativas (Dia das Mães e Natal).
- **Problemas e necessidades identificados:** o levantamento de requisitos aponta processos hoje prováveis de estarem descentralizados/manuais: controle de estoque de insumos (couro, ferragens, zíperes) sem rastreabilidade de lote; ausência de regra formal de crédito para vendas a prazo; cálculo de custo/preço de venda não padronizado (ficha técnica); acompanhamento de produção sem visibilidade de status; e falta de integração entre vendas, estoque e financeiro (títulos a pagar/receber gerados manualmente).
- **Justificativa da escolha:** Uma empresa que a gente sabia que ia ter acesso fácil e que consideramos de porte médio, não deixando nem tão simples e nem tão complicado o nosso trabalho.
- **Evidências da organização:** Endereço: Rua Alpiste, 116 - Jd. Eliane - São Paulo - SP. Contato na empresa: Osmar Lingiard, telefone para contato: 11 97334-4846, email: osmar@specia.com.br.

<p align="center">
  <img src="evidencias/01-bancada-producao.jpg" width="32%" />
  <img src="evidencias/02-responsavel-escritorio.jpg" width="32%" />
  <img src="evidencias/03-estoque-corredor-g.jpg" width="32%" />
</p>
<p align="center">
  <img src="evidencias/04-oficina-costura.jpg" width="32%" />
  <img src="evidencias/05-estoque-insumos.jpg" width="32%" />
  <img src="evidencias/06-fachada.jpg" width="32%" />
</p>

*Da esquerda para a direita, de cima para baixo: bancada de produção (corte/costura), Jaime no escritório, estoque de bolsas prontas (corredor G), oficina com as máquinas de costura, estoque de insumos/materiais, fachada na Rua Alpiste.

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



### FORNECEDOR
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_fornecedor | Identificador | Chave primária, gerada pelo sistema. É única e não pode ser reutilizada. |
| razao_social | Nome empresarial | Obrigatório. Nome utilizado em compras e no histórico de avaliação do fornecedor. |
| cnpj | CNPJ | Obrigatório e único. Não pode existir mais de um fornecedor com o mesmo CNPJ. Dado protegido pela LGPD. |
| inscricao_estadual | Registro estadual | Opcional. Deve ser preenchido quando o fornecedor possuir inscrição estadual. |
| email | E-mail comercial | Opcional. Canal de contato comercial com o fornecedor. |
| telefone | Telefone | Opcional. Contato direto com o fornecedor. |
| contato_vendedor | Vendedor de referência | Nome da pessoa responsável pelo atendimento comercial do fornecedor. |
| categoria_insumo | Tipo de insumo vendido | Obrigatório. Aceita: Curtume/Couro, Ferragens/Fivelas, Zíperes/Aviamentos ou Embalagens/Caixas. |
| prazo_medio_entrega_dias | Prazo de entrega em dias | Número inteiro maior que zero. Impacta o planejamento: quanto maior o prazo, mais cedo o insumo deve ser comprado. |

### INSUMO
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_insumo | Identificador | Chave primária, gerada pelo sistema. |
| nome_insumo | Nome do material | Obrigatório. Exemplos: couro bovino caramelo, zíper, fivela e forro. |
| categoria_insumo | Grupo do material | Usa o mesmo conjunto de categorias do fornecedor, permitindo identificar fornecedores aptos a vender o insumo. |
| unidade_medida | Unidade de controle | Obrigatória. Aceita: dm², m², unidade, metro, kg ou litro. Estoque e ficha técnica devem usar a mesma unidade. |
| estoque_minimo | Saldo mínimo | Quando estoque_atual for igual ou menor que este valor, o sistema deve gerar alerta de recompra. |
| estoque_atual | Saldo em estoque | Nunca pode ser negativo. Aumenta com compras recebidas e diminui com o consumo na produção. |
| custo_unitario | Custo por unidade de medida | Deve ser maior que zero. É o custo de referência usado para calcular a matéria-prima. |

### FICHA_TECNICA *(entidade associativa — identificada por PRODUTO + INSUMO)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| quantidade_necessaria | Quantidade por peça | Deve ser maior que zero e seguir a unidade_medida do insumo. Cada insumo aparece uma única vez na ficha de um produto. |
| percentual_perda | Perda técnica no corte | Informado como fração entre 0 e 1 (ex.: 10% = 0,10). Compõe o custo como quantidade × (1 + perda). |

### PRODUTO 
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_produto | Identificador | Chave primária, gerada pelo sistema. É a mesma chave usada por BOLSA e ACESSORIO. |
| nome_modelo | Nome do modelo | Obrigatório. Exemplo: Bolsa Tote. |
| custo_mao_obra | Mão de obra por peça | Valor informado, não calculado. Representa custos de corte e costura e é somado ao custo de matéria-prima. |
| markup | Multiplicador de margem | Valor informado e maior que 1. Exemplo: 2,5 representa preço equivalente a 2,5 vezes o custo. |
| custo_materia_prima *(derivado)* | Custo dos insumos | Não é digitado. Soma de quantidade_necessaria × (1 + percentual_perda) × custo_unitario para cada insumo da ficha. |
| preco_tabela *(derivado)* | Preço de venda sugerido | Não é digitado. Calculado por (custo_materia_prima + custo_mao_obra) × markup. Recalculado quando seus componentes mudarem. |

### BOLSA *(subtipo de PRODUTO)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| tamanho | Dimensão da bolsa | Obrigatório para produtos classificados como bolsa. Herda também os atributos de PRODUTO. |
| cor | Cor da bolsa | Obrigatória para bolsa. |
| tipo_alca | Tipo de alça | Obrigatório para bolsa. |
| pecas_composicao *(multivalorado)* | Peças que formam a bolsa | Deve conter pelo menos uma peça, como tampa, frente, costa, fundo ou orla. |

### ACESSORIO *(subtipo de PRODUTO)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| tipo_peca | Tipo do acessório | Obrigatório. Exemplos: cinto e porta-cartões. Um acessório não pode possuir atributos específicos de bolsa. |

### CLIENTE
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_cliente | Identificador | Chave primária, gerada pelo sistema. |
| nome | Razão social ou nome | Obrigatório. Razão social para pessoa jurídica e nome completo para pessoa física. |
| cpf_cnpj | CPF ou CNPJ | Obrigatório e único. Usado na consulta de crédito. Dado protegido pela LGPD. |
| inscricao_estadual | Registro estadual | Obrigatória quando perfil_cliente for Atacado/Lojista. Para Varejo Final, deve ficar vazia. |
| email | E-mail | Usado para comunicação e envio de NF-e ao cliente. |
| telefone | Telefone ou WhatsApp | Canal principal de contato. |
| nome_comprador_responsavel | Contato de compras | Pessoa que faz pedidos em nome do cliente, principalmente no atacado. |
| perfil_cliente | Tipo de cliente | Aceita: Varejo Final ou Atacado/Lojista. Define a regra de preço e a obrigatoriedade de inscrição estadual. |
| limite_credito | Teto de compra a prazo | Valor máximo permitido para vendas em boleto. O total do pedido não pode ultrapassar esse limite. |
| status_aprovacao_financeira | Situação do crédito | Aceita: Pendente, Aprovado ou Reprovado. Novo cliente lojista inicia como Pendente e só compra em boleto quando Aprovado. |

### PEDIDO
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| id_pedido | Identificador | Chave primária, gerada pelo sistema. |
| data_pedido | Data do pedido | Obrigatória. Preenchida no registro do pedido. |
| canal_venda | Canal de venda | Aceita: Loja Física, E-commerce, WhatsApp ou Representante. |
| forma_pagamento | Forma de pagamento | Aceita: PIX, Cartão ou Boleto. Boleto só é permitido quando o cliente estiver Aprovado e dentro do limite_credito. |
| condicao_parcelamento | Parcelas ou prazo | Depende da forma de pagamento: PIX à vista; Cartão com número de parcelas; Boleto com prazos em dias (ex.: 30/60/90). |
| status_pedido | Situação do pedido | Obrigatório. Evolui no processo comercial (ex.: aberto, faturado, expedido). |
| valor_total *(derivado)* | Total do pedido | Não é digitado. Soma de quantidade × preco_unitario_praticado − desconto de todos os itens. |

### ITEM_PEDIDO *(entidade associativa — identificada por PEDIDO + PRODUTO)*
| Atributo | Descrição | Regra de negócio associada |
|---|---|---|
| quantidade | Unidades vendidas | Número inteiro maior que zero. Um produto aparece uma vez por pedido; para vender mais, aumenta-se a quantidade. |
| preco_unitario_praticado | Preço aplicado na venda | Fica congelado no momento da venda. Alterações posteriores no preco_tabela não modificam pedidos antigos. |
| desconto | Desconto do item | Opcional. Não pode ser superior a quantidade × preco_unitario_praticado. |

---

## 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)


- **Entidades reconhecidas (9 no total):** FORNECEDOR, INSUMO, FICHA_TECNICA, PRODUTO, BOLSA, ACESSORIO, CLIENTE, PEDIDO e ITEM_PEDIDO — cobrindo o fluxo de custo de produção e venda (compra de insumo → ficha técnica → precificação do produto → pedido → cliente). Duas são **entidades associativas** com atributos próprios (FICHA_TECNICA, ITEM_PEDIDO), e PRODUTO é um **supertipo** especializado em BOLSA e ACESSORIO.
- **Atributos e classificações:** detalhados por entidade na Seção 5, com chave primária e domínios de valor explícitos (ex.: `perfil_cliente`, `categoria_insumo`, `forma_pagamento`). Atributos derivados (`custo_materia_prima`, `preco_tabela`, `valor_total`) estão marcados como tal — não são digitados, são calculados a partir de outros atributos.
- **Especialização PRODUTO → BOLSA / ACESSORIO:** total e disjunta (símbolo "TD" no diagrama) — todo produto é obrigatoriamente bolsa OU acessório, nunca os dois, e não existe produto que não seja nenhum dos dois. BOLSA e ACESSORIO herdam todos os atributos de PRODUTO.
- **Relacionamentos pertinentes (6 no total, mais a especialização):**

| # | Entidade A | Card. A | Verbo | Card. B | Entidade B | Observação |
|---|---|---|---|---|---|---|
| 01 | FORNECEDOR | (1,N) | abastece | (0,N) | INSUMO | N:N — um fornecedor fornece vários insumos e um insumo pode vir de vários fornecedores |
| 02 | INSUMO | (1,1) | constitui | (0,N) | FICHA_TECNICA | cada linha da ficha técnica usa exatamente um insumo |
| 03 | PRODUTO | (1,1) | detalha-se em | (0,N) | FICHA_TECNICA | 02+03 resolvem o N:N Produto×Insumo via FICHA_TECNICA |
| 04 | PRODUTO | (1,1) | integra | (0,N) | ITEM_PEDIDO | um produto pode integrar vários itens de pedido |
| 05 | PEDIDO | (1,1) | compreende | (1,N) | ITEM_PEDIDO | todo pedido tem ao menos um item |
| 06 | CLIENTE | (1,1) | efetua | (0,N) | PEDIDO | cliente pode ter zero ou vários pedidos |

- **Restrições e políticas organizacionais aplicadas ao modelo:** o limite de crédito e o status de aprovação financeira (Seção 4) ficam em CLIENTE e condicionam, na regra de negócio, se um PEDIDO pode usar boleto; a obrigatoriedade de inscrição estadual depende do `perfil_cliente`; o custo e o preço de venda de PRODUTO são sempre derivados da FICHA_TECNICA, nunca digitados diretamente, para manter a precificação rastreável até o insumo.

---

## 7. Diagrama Entidade-Relacionamento (DER)

**Arquivos anexados:** `Diagrama/DER_9_Entidades_com_titulo_legenda (2).png` (imagem) e `Dicionario_de_Dados.html` (dicionário completo, mesmo conteúdo da Seção 5).

O diagrama segue a notação de Chen usada pelo BrModeloWeb: entidades como **retângulos**, relacionamentos como **losangos** rotulados com o verbo, atributos como **elipses**, com a **chave primária identificada por contorno destacado**. A especialização PRODUTO → BOLSA/ACESSORIO usa o círculo "TD" (Total e Disjunta) padrão da notação de Chen. As cardinalidades (mín,máx) ficam junto de cada ponta da linha, exatamente como na tabela da Seção 6. Seguindo a notação conceitual pura, o diagrama não mostra atributos de chave estrangeira — essa informação já está representada pela própria linha do relacionamento.


---

## 8. Justificativa Técnica

- **Por que FICHA_TECNICA e ITEM_PEDIDO como entidades associativas:** ambas carregam atributos próprios (quantidade_necessaria/percentual_perda; quantidade/preco_unitario_praticado/desconto) que não pertencem a nenhuma das duas entidades que conectam — a notação exige reificá-los como entidade para acomodar esses atributos.
- **Por que PRODUTO como supertipo (BOLSA/ACESSORIO):** bolsa e acessório compartilham identificador, nome do modelo, mão de obra, markup e os atributos derivados de custo — mas cada um tem atributos exclusivos (tamanho/cor/alça para bolsa; tipo_peca para acessório). Generalização/especialização evita repetir os atributos comuns em duas entidades soltas e ainda documenta, no próprio diagrama, que um produto é sempre um dos dois (TD).
- **Por que essas cardinalidades e não outras:** FORNECEDOR–INSUMO é N:N porque, na prática, mais de um fornecedor vende o mesmo tipo de insumo (ex.: couro) e um fornecedor vende vários insumos; PEDIDO–ITEM_PEDIDO é (1,N) do lado do item porque um pedido sem nenhum item não existe operacionalmente.
- **Alternativas descartadas:** cogitou-se manter BOLSA e ACESSORIO como uma única entidade PRODUTO com campos opcionais (tamanho/cor/alça nulos para acessório) — descartado porque misturaria atributos obrigatórios de um subtipo com atributos irrelevantes do outro, violando a regra "um acessório não pode possuir atributos específicos de bolsa".

---

## 9. Uso de Inteligência Artificial

| Item | Registro |
|---|---|
| **Ferramenta e etapa** | Claude (Claude Code / Sonnet 5, Anthropic) — usado em cinco momentos: (1) leitura do questionário de requisitos e construção de um primeiro modelo conceitual (21 entidades) e dicionário de dados; (2) geração de um primeiro diagrama ER (notação "pé-de-galinha"); (3) preenchimento deste README a partir do esqueleto oficial da Entrega 1; (4) reconstrução desse primeiro diagrama na notação de Chen (retângulo/losango/elipse) usada pelo BrModeloWeb, a pedido explícito do professor; (5) depois que o grupo (Guilherme) remodelou o DER para um recorte mais enxuto de 9 entidades direto no BrModeloWeb, reorganização do dicionário de dados HTML já produzido pelo grupo para a raiz do repositório e reescrita das Seções 5–8 deste README para descrever esse modelo de 9 entidades, em vez do modelo de 21 que havia ficado desatualizado. |
| **Motivação** | Acelerar a tradução do levantamento de requisitos para um modelo estruturado e para o formato de entrega exigido pela disciplina; depois, manter o README consistente com o DER e o dicionário que o grupo efetivamente anexou, já que o grupo reduziu o escopo do modelo de forma independente entre uma sessão e outra. |
| **Prompt(s) utilizados** | "Preciso montar um diagrama e o dicionário desse diagrama, como se fosse no modelo BrModeloWeb..."; "Consegue gerar um arquivo pdf com esse arquivo que montou? Contendo somente o diagrama e o dicionário"; "Ajustar diagrama para o mesmo modelo de BrModeloWeb"; "adicione essas fotos no readme, na parte de evidências"; "De acordo com o dicionário e o diagrama que estão agora, crie o arquivo de dicionário de dados em html". |
| **Resposta recebida** | Um primeiro modelo (21 entidades) com diagrama e dicionário; este README preenchido; o DER redesenhado em notação de Chen; e, nesta última etapa, a constatação de que o dicionário HTML já existia (feito pelo grupo) e batia com o DER de 9 entidades atual — então ele foi movido para a raiz do repositório como `Dicionario_de_Dados.html` e as Seções 5 a 8 do README foram reescritas para descrever esse mesmo modelo de 9 entidades, mantendo as Seções 1 a 4 como o levantamento de requisitos mais amplo. |
| **Fontes consultadas e verificadas** | Nenhuma fonte externa. O primeiro modelo veio do questionário de requisitos fornecido pelo grupo; a reescrita das Seções 5–8 veio do dicionário HTML e do diagrama PNG que o próprio grupo já havia anexado ao repositório (não foi inventado nenhum dado novo). |
| **Trechos rejeitados ou corrigidos** | A primeira versão do diagrama (pé-de-galinha) foi descartada e refeita em Chen a pedido do professor; nessa reconstrução também foram removidos atributos de chave estrangeira das entidades (erro de fidelidade conceitual da primeira versão). Depois, o modelo de 21 entidades inteiro foi substituído pelas Seções 5–8 baseadas no modelo de 9 entidades que o grupo passou a usar — o texto anterior (21 entidades) não foi mantido por estar desatualizado em relação ao DER de fato anexado. |
| **Justificativa da escolha final** | As Seções 5–8 agora descrevem exatamente o que está anexado (`Diagrama/DER_9_Entidades_com_titulo_legenda (2).png` e `Dicionario_de_Dados.html`), em vez de um modelo mais amplo que não corresponde mais ao diagrama entregue. As Seções 1–4 (requisitos e regras de negócio) não foram reduzidas, pois continuam válidas como levantamento — só o recorte modelado no DER desta entrega ficou menor. |
| **Reflexão crítica** | O modelo reflete fielmente o texto do questionário, mas não substitui a pesquisa de campo exigida pela atividade — regras de negócio reais da organização escolhida podem divergir do que está aqui (valores de limite de crédito, percentuais de comissão etc. foram tratados como exemplos/referências, não como regras fixas). O grupo deve validar cada regra de negócio da Seção 4 com a organização real antes de assumi-las como definitivas. |


---




