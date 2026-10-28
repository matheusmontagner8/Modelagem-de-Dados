# Entrega 2 — Modelo Lógico, Modelo Físico e Apresentação Final


Artefatos desta etapa:

| Arquivo | Conteúdo | Seção do esqueleto oficial |
|---|---|---|
| [`RELATORIO_TECNICO.md`](RELATORIO_TECNICO.md) | Revisão do conceitual, conversão para o lógico, PKs/FKs, normalização (1FN/2FN/3FN), justificativas técnicas, proposta de BI/IA, Uso de IA | Seções 1.1–1.6 e 6 |
| [`modelo_logico.md`](modelo_logico.md) | 17 tabelas, colunas, tipos, PK/FK, restrições e cardinalidades já convertidas, com diagrama (abaixo) | Seção 2 |
| [`modelo_logico.png`](modelo_logico.png) | Diagrama do modelo lógico em notação de tabela/crow's foot (tipo, coluna, PK/FK dentro da caixa) — **diferente do DER conceitual da Entrega 1**, que segue notação de Chen por exigência da disciplina | Seção 2 |
| [`script.sql`](script.sql) | **Modelo Físico** — Script completo: `CREATE DATABASE`/17 `CREATE TABLE`/constraints, massa de dados fictícia, 7 `SELECT` com `JOIN`, 6 `UPDATE`, 2 `DELETE`, 7 consultas gerenciais e de auditoria | Seções 3 e 4 |
| [`apresentacao_outline.md`](apresentacao_outline.md) | Roteiro/conteúdo dos slides, atualizado para o modelo de 17 entidades (12 slides) | Seção 7 |
| [`apresentacao.pptx`](apresentacao.pptx) | Slides prontos (12), com o DER novo, o slide de "correção aplicada" (apontamento do professor × solução), 2 slides de PK/FK (núcleo + tabelas novas), fotos da visita, 2 gráficos nativos e anotações do apresentador | Seção 7 |

**`script.sql` testado em MySQL de verdade (v2, modelo de 17 tabelas).** O mesmo MySQL Community Server 8.4.10 LTS local (`C:\Users\Matheus\mysql\mysql-8.4.10-winx64`, agora rodando como serviço `MySQL84`) executou o script reescrito do início ao fim **sem nenhum erro ou warning**. As 4 auditorias estruturais (9.1 vl_total, 9.2 produto sem ficha técnica, 9.3 insumo sem uso, 9.4 violação da especialização TD) voltaram com **0 linhas**; a 9.5 (anomalia de preço) e a 9.6 (fornecedor sem lote) encontraram exatamente as linhas injetadas de propósito. A consulta 5.4 confirma a correção do Critério 10 na prática: "Bolsa Tote Caramelo" usa couro recebido de **dois fornecedores diferentes** (antes, a FK direta `insumo.fornecedor_id` tornava isso impossível de representar). Contagem final: 5 fornecedores, 9 insumos, 10 lotes de insumo, 8 produtos (5 bolsas + 3 acessórios), 23 linhas de ficha técnica, 8 ordens de produção, 7 etapas, 4 artesãos/facções, 56 execuções de etapa, 10 clientes, 4 vendedores, 76 pedidos, 128 itens de pedido, 61 títulos a receber, 10 títulos a pagar. Detalhes de como instalar/rodar em "Como rodar localmente", abaixo.

**Pendências do grupo antes de entregar**:
- **Abrir `apresentacao.pptx` no PowerPoint e conferir o visual com atenção** — esta sessão não tinha LibreOffice disponível para gerar a prévia das imagens dos slides; o arquivo passou pela validação estrutural (`validate.py`, sem erros) e pela checagem de conteúdo (`markitdown`, texto completo, sem placeholder esquecido), mas **não foi visto renderizado**.
- Validar a massa de dados com a organização real (Osmar, Contrasti) — volumes, comissões (3%/7%) e lead time de pagamento (30 dias) usados em `lote_insumo`/`contas_pagar`/`vendedor` são inteiramente fictícios.
- Decidir se `insumo.qt_estoque_atual` passa a ser recalculado automaticamente a partir de `lote_insumo` (trigger ou view) em vez de mantido manualmente — discutido em `RELATORIO_TECNICO.md` §1.4.
- Ensaiar o tempo da apresentação (cresceu para ~10-12 min com os 2 slides novos) e decidir quem fala em qual parte.
- Se quiserem apresentar com o banco rodando ao vivo, usar este MySQL local (ver abaixo) ou instalar em outra máquina/notebook que for usado na apresentação.

## Como rodar localmente

MySQL 8.4.10 LTS, já instalado como serviço do Windows (`MySQL84`) — inicia sozinho com o computador. **Não rode `mysqld.exe --standalone` manualmente** (dá erro de conflito com o serviço já em execução). Os comandos abaixo usam sintaxe do **PowerShell** (terminal padrão do Windows) — se usar `cmd.exe` clássico, pode trocar o `Get-Content ... | bin\mysql.exe` pelo redirecionamento `bin\mysql.exe ... < arquivo.sql`, que só funciona no `cmd`, não no PowerShell. Para conectar e rodar o script:


```

cd "C:\Users\Matheus\mysql\mysql-8.4.10-winx64"
Get-Content "C:\Rhema\Matheus\Modelagem-de-Dados\Entrega2\script.sql" | bin\mysql.exe -u root --port=3306 --protocol=TCP
bin\mysql.exe -u root --port=3306 --protocol=TCP contrasti_bolsas

```

**Usuário `root` sem senha** (`--initialize-insecure`, para simplificar o uso local) — adequado para estudo na própria máquina, mas defina uma senha (`ALTER USER 'root'@'localhost' IDENTIFIED BY '...';`) antes de expor a porta 3306 a qualquer rede.

**Se for instalar em outra máquina/notebook para a apresentação** (sem o serviço já configurado), o passo de instalação como serviço do Windows exige um PowerShell **como Administrador**:

```

cd "C:\Users\Matheus\mysql\mysql-8.4.10-winx64"
.\bin\mysqld.exe --install MySQL84 --defaults-file="C:\Users\Matheus\mysql\mysql-8.4.10-winx64\my.ini"
net start MySQL84

```
