# Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final

> ⚠️ **Pendência aberta (15/10/2026):** em resposta à avaliação do professor na [issue #1](https://github.com/matheusmontagner8/Modelagem-de-Dados/issues/1), o conceitual da Entrega 1 (`../Diagrama/Diagrama.png` e `../Dicionario_de_Dados.html`) foi reconstruído de 9 para **17 entidades** (acréscimo de LOTE_INSUMO, ORDEM_PRODUÇÃO, ETAPA_PRODUÇÃO, ARTESÃO_FACÇÃO, EXECUÇÃO_ETAPA, VENDEDOR, CONTAS_RECEBER, CONTAS_PAGAR). Os artefatos **desta pasta** (`modelo_logico.md`, `script.sql`, `apresentacao.pptx`) **ainda refletem o modelo antigo de 9 entidades** e não foram atualizados nesta rodada — a correção priorizou os dois critérios de maior peso reprovados (DER e Dicionário, ambos na Entrega 1). Fica como item pendente converter e testar o modelo lógico/SQL das 8 entidades novas antes de reapresentar a Entrega 2.

Artefatos desta etapa (continuação da Entrega 1, na raiz do repositório — DER e Dicionário de Dados, agora de 17 entidades):

| Arquivo | Conteúdo | Seção do esqueleto oficial |
|---|---|---|
| [`RELATORIO_TECNICO.md`](RELATORIO_TECNICO.md) | Revisão do conceitual, conversão para o lógico, PKs/FKs, normalização (1FN/2FN/3FN), justificativas técnicas, proposta de BI/IA, Uso de IA | Seções 1.1–1.6 e 6 |
| [`modelo_logico.md`](modelo_logico.md) | Tabelas, colunas, tipos, PK/FK, restrições e cardinalidades já convertidas — serve também como o **Dicionário de Dados atualizado** (nível lógico) pedido na Seção 5 do esqueleto; o `Dicionario_de_Dados.html` da raiz continua sendo a referência conceitual da Entrega 1 | Seção 2 |
| [`script.sql`](script.sql) | Script completo: `CREATE DATABASE`/`CREATE TABLE`/constraints, massa de dados fictícia, `SELECT` com `JOIN`, `UPDATE`, `DELETE`, consultas gerenciais e de auditoria | Seções 3 e 4 |
| [`apresentacao_outline.md`](apresentacao_outline.md) | Roteiro/conteúdo original dos slides (texto-base usado para montar o `.pptx` abaixo) | Seção 7 |
| [`apresentacao.pptx`](apresentacao.pptx) | Slides prontos (10), com o DER, fotos da visita, 2 gráficos nativos (faturamento por mês, margem por produto) e anotações do apresentador em cada slide | Seção 7 |

**`script.sql` testado em MySQL de verdade.** Um MySQL Community Server 8.4.10 LTS foi instalado localmente (`C:\Users\Matheus\mysql\mysql-8.4.10-winx64`) e o script completo rodou do início ao fim **sem nenhum erro ou warning**. As 4 consultas de auditoria estruturais (9.1 valor_total, 9.2 produto sem ficha técnica, 9.3 insumo sem uso, 9.4 violação da especialização TD) voltaram com **0 linhas**, confirmando que a massa de dados é consistente; a 9.5 (anomalia de preço) encontrou exatamente a 1 linha injetada de propósito. Contagem final: 5 fornecedores, 9 insumos, 8 produtos (5 bolsas + 3 acessórios), 23 linhas de ficha técnica, 10 clientes, 76 pedidos, 128 itens de pedido. Detalhes de como instalar/rodar em "Como rodar localmente", abaixo.

**Pendências do grupo antes de entregar**:
- Validar a massa de dados com a organização real (Osmar, Contrasti) — o volume mensal já foi ajustado para ~60-70 pedidos (setembro/2025, em `script.sql`), mas os valores em si continuam fictícios.
- Abrir `apresentacao.pptx` no PowerPoint e conferir o visual com atenção: esta sessão não tinha LibreOffice disponível para gerar a prévia das imagens dos slides (QA visual do próprio processo de geração), então o arquivo passou pela validação estrutural (`validate.py`, sem erros) e pela checagem de conteúdo (texto completo, sem placeholder esquecido), mas **não foi visto renderizado** antes de entrar no repositório.
- Ensaiar o tempo da apresentação (10 slides, ~8-10 min sugeridos no roteiro) e decidir quem fala em qual parte.
- Se quiserem apresentar com o banco rodando ao vivo (Seção 7.4/7.5 do roteiro), decidir se usam este MySQL local (ver abaixo) ou instalam em outra máquina/notebook que for usado na apresentação.

## Como rodar localmente

MySQL 8.4.10 LTS, instalado via ZIP "sem instalador" (não é um serviço do Windows — precisa ser iniciado manualmente a cada reinício):

```
cd "C:\Users\Matheus\mysql\mysql-8.4.10-winx64"
bin\mysqld.exe --defaults-file=my.ini --standalone --console
```

Em outro terminal, para rodar o script ou abrir um cliente:
```
cd "C:\Users\Matheus\mysql\mysql-8.4.10-winx64"
bin\mysql.exe -u root --port=3306 --protocol=TCP < "..\..\..\Rhema\Matheus\Modelagem-de-Dados\Entrega2\script.sql"
bin\mysql.exe -u root --port=3306 --protocol=TCP contrasti_bolsas
```

**Usuário `root` sem senha** (`--initialize-insecure`, para simplificar o uso local) — adequado para estudo na própria máquina, mas defina uma senha (`ALTER USER 'root'@'localhost' IDENTIFIED BY '...';`) antes de expor a porta 3306 a qualquer rede. Instalar como serviço do Windows (para iniciar sozinho e não precisar do terminal aberto) exige um PowerShell **como Administrador**:
```
cd "C:\Users\Matheus\mysql\mysql-8.4.10-winx64"
.\bin\mysqld.exe --install MySQL84 --defaults-file="C:\Users\Matheus\mysql\mysql-8.4.10-winx64\my.ini"
net start MySQL84
```
