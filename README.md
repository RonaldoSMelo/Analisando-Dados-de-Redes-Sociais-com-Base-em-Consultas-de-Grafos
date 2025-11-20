# Desafio de Projeto - Analisando Dados de Redes Sociais com Neo4j Aura

Este projeto implementa uma solução para análise de dados de redes sociais usando consultas de grafos no **Neo4j Aura**. Os dados são extraídos de um CSV com informações do Instagram e modelados como um grafo para análise de relacionamentos entre posts e hashtags.

## 📋 Estrutura do Projeto

```
.
├── Instagram data.csv                    # Dados do Instagram (posts, hashtags, métricas)
├── criar_relacionamentos_aura_v2.cypher # Script Cypher para criar relacionamentos
├── criar_relacionamentos_aura_simples.cypher # Versão simplificada
├── queries.py                           # Script Python para análises
├── consultas_cypher.txt                 # Consultas Cypher prontas para uso
├── INSTRUCOES_AURA.md                   # Instruções detalhadas para Neo4j Aura
├── imagens/                             # Screenshots dos resultados das consultas
├── requirements.txt                     # Dependências Python
└── README.md                            # Este arquivo
```

## 🚀 Pré-requisitos

1. **Neo4j Aura**
   - Crie uma conta gratuita em: https://neo4j.com/cloud/aura/
   - Crie uma nova instância de banco de dados
   - Anote a URI de conexão (formato: `neo4j+s://xxxxx.databases.neo4j.io`)
   - Anote o usuário e senha

2. **Python 3.7+** (opcional, para scripts Python)
   - Verifique a versão: `python --version`

3. **Bibliotecas Python** (opcional)
   - Instale as dependências: `pip install -r requirements.txt`

## 📦 Configuração Inicial

### Passo 1: Importar Dados no Neo4j Aura

1. Acesse o Neo4j Aura Console: https://console.neo4j.io/
2. Abra sua instância de banco de dados
3. Vá em **"Import"** no menu lateral
4. Faça upload do arquivo `Instagram data.csv`
5. Configure o mapeamento para criar nós `InstagramPost`

### Passo 2: Criar Relacionamentos

Após importar os dados, você terá 90 nós `InstagramPost`, mas ainda **não haverá relacionamentos**.

Execute os scripts Cypher em `criar_relacionamentos_aura_v2.cypher` ou siga as instruções em `INSTRUCOES_AURA.md`:

1. **No Neo4j Browser (Query)**, execute a primeira consulta para criar hashtags e relacionamentos `USED_IN`
2. Execute a segunda consulta para criar relacionamentos `RELATED_TO` entre hashtags

## 📊 Modelo de Dados

### Nós

#### InstagramPost
- `impression`: Total de impressões
- `fromHome`: Impressões da página inicial
- `fromHashtag`: Impressões de hashtags
- `fromExplore`: Impressões da aba Explorar
- `fromOther`: Impressões de outras fontes
- `save`: Número de salvamentos
- `comment`: Número de comentários
- `share`: Número de compartilhamentos
- `like`: Número de curtidas
- `profileVisit`: Visitas ao perfil
- `follow`: Novos seguidores
- `caption`: Texto da legenda
- `hashtag`: String com todas as hashtags do post

#### Hashtag
- `name`: Nome da hashtag (em minúsculas)

### Relacionamentos

- `USED_IN`: Hashtag → InstagramPost (indica que uma hashtag foi usada em um post)
- `RELATED_TO`: Hashtag ↔ Hashtag (indica co-ocorrência, com propriedade `weight`)

## 🔍 Executando Análises

### Opção 1: Usando Neo4j Browser (Recomendado)

Acesse o Neo4j Browser através do console do Aura e execute as consultas do arquivo `consultas_cypher.txt`.

### Opção 2: Usando Script Python

1. Configure as credenciais do Neo4j Aura no arquivo `queries.py`:
```python
URI = "neo4j+s://seu-instance.databases.neo4j.io"  # Sua URI do Aura
USER = "neo4j"  # Seu usuário
PASSWORD = "sua_senha_aqui"  # Sua senha
```

2. Execute o script:
```bash
python queries.py
```

Este script executa várias análises:

1. **Estatísticas Gerais**: Resumo da rede
2. **Top Hashtags**: Hashtags mais utilizadas
3. **Posts Mais Populares**: Posts com maior engajamento
4. **Hashtags com Maior Engajamento**: Hashtags que geram mais interação
5. **Posts com Mais Impressões**: Posts que alcançaram mais pessoas
6. **Rede de Hashtags**: Relacionamentos entre hashtags
7. **Hashtags Relacionadas**: Hashtags que aparecem junto com uma específica

## 📝 Consultas Cypher e Resultados

Execute estas consultas diretamente no Neo4j Browser do Aura. Abaixo você encontrará exemplos de resultados visuais para cada consulta:

### 1. Visualizar Toda a Rede

Esta consulta mostra a estrutura completa do grafo, visualizando os relacionamentos entre hashtags e posts.

```cypher
MATCH (h:Hashtag)-[r:USED_IN]->(p:InstagramPost)
RETURN h, r, p
LIMIT 50
```

**Dica**: Mude para a aba "Graph" para visualização gráfica!

![Visualização da Rede](imagens/1.%20VISUALIZAR%20TODA%20A%20REDE%20(LIMITE%20DE%2050%20N%C3%93S).png)

---

### 2. Top 15 Hashtags Mais Utilizadas

Identifica quais hashtags aparecem com mais frequência nos posts.

```cypher
MATCH (h:Hashtag)-[:USED_IN]->(p:InstagramPost)
RETURN h.name AS hashtag, count(p) AS total_posts
ORDER BY total_posts DESC
LIMIT 15
```

![Top Hashtags](imagens/2.%20TOP%2015%20HASHTAGS%20MAIS%20UTILIZADAS.png)

---

### 3. Posts com Maior Engajamento

Ranking dos posts com maior soma de likes, comentários e compartilhamentos.

```cypher
MATCH (p:InstagramPost)
RETURN elementId(p) AS id_post,
       p.like AS likes,
       p.comment AS comments,
       p.share AS shares,
       (p.like + p.comment + p.share) AS engajamento_total,
       p.caption AS legenda
ORDER BY engajamento_total DESC
LIMIT 10
```

![Posts com Maior Engajamento](imagens/3.%20POSTS%20COM%20MAIOR%20ENGAJAMENTO%20(LIKES%20+%20COMMENTS%20+%20SHARES).png)

---

### 4. Hashtags Relacionadas a "datascience"

Identifica quais hashtags aparecem frequentemente junto com "datascience", mostrando padrões de co-ocorrência.

```cypher
MATCH (h1:Hashtag {name: 'datascience'})-[r:RELATED_TO]-(h2:Hashtag)
RETURN h2.name AS hashtag_relacionada, r.weight AS frequencia
ORDER BY r.weight DESC
LIMIT 10
```

![Hashtags Relacionadas](imagens/4.%20HASHTAGS%20RELACIONADAS%20A%20datascience%20(CO-OCORR%C3%8ANCIA).png)

---

### 5. Posts que Usam uma Hashtag Específica

Encontra todos os posts que utilizam uma hashtag específica (exemplo: "python").

```cypher
MATCH (h:Hashtag {name: 'python'})-[:USED_IN]->(p:InstagramPost)
RETURN elementId(p) AS id_post,
       p.like AS likes,
       p.comment AS comments,
       p.impression AS impressoes,
       p.caption AS legenda
ORDER BY p.like DESC
LIMIT 10
```

![Posts por Hashtag](imagens/5.%20POSTS%20QUE%20USAM%20UMA%20HASHTAG%20ESPEC%C3%8DFICA%20(ex%20python).png)

---

### 6. Rede de Hashtags (Visualização Gráfica)

Visualização gráfica da rede de relacionamentos entre hashtags, mostrando conexões baseadas em co-ocorrência.

```cypher
MATCH (h1:Hashtag)-[r:RELATED_TO]-(h2:Hashtag)
WHERE r.weight >= 3
RETURN h1, r, h2
```

**Dica**: Mude para a aba "Graph" para ver a rede visualmente!

![Rede de Hashtags](imagens/6.%20REDE%20DE%20HASHTAGS%20(VISUALIZA%C3%87%C3%83O%20GR%C3%81FICA).png)

---

### 7. Hashtags com Maior Engajamento Médio

Identifica hashtags que geram maior engajamento médio por post, considerando apenas hashtags usadas em múltiplos posts.

```cypher
MATCH (h:Hashtag)-[:USED_IN]->(p:InstagramPost)
WITH h.name AS hashtag,
     avg(p.like + p.comment + p.share) AS engajamento_medio,
     count(p) AS total_posts
WHERE total_posts >= 3
RETURN hashtag, engajamento_medio, total_posts
ORDER BY engajamento_medio DESC
LIMIT 10
```

![Hashtags com Maior Engajamento](imagens/7.%20HASHTAGS%20COM%20MAIOR%20ENGAJAMENTO%20M%C3%89DIO.png)

---

### 8. Posts com Mais Impressões

Ranking dos posts que alcançaram mais pessoas, incluindo detalhes sobre a origem das impressões.

```cypher
MATCH (p:InstagramPost)
RETURN elementId(p) AS id_post,
       p.impression AS total_impressoes,
       p.fromHome AS da_home,
       p.fromHashtag AS de_hashtags,
       p.fromExplore AS do_explore,
       p.caption AS legenda
ORDER BY p.impression DESC
LIMIT 10
```

![Posts com Mais Impressões](imagens/8.%20POSTS%20COM%20MAIS%20IMPRESS%C3%95ES.png)

---

### 9. Estatísticas Gerais da Rede

Visão geral completa da rede, incluindo totais e médias de todas as métricas importantes.

```cypher
MATCH (p:InstagramPost)
WITH count(p) AS total_posts,
     avg(p.like) AS media_likes,
     avg(p.comment) AS media_comments,
     avg(p.share) AS media_shares,
     avg(p.impression) AS media_impressoes
MATCH (h:Hashtag)
WITH total_posts, media_likes, media_comments, media_shares,
     media_impressoes, count(h) AS total_hashtags
MATCH ()-[r:USED_IN]->()
RETURN total_posts,
       total_hashtags,
       count(r) AS relacoes_post_hashtag,
       round(media_likes) AS media_likes,
       round(media_comments, 1) AS media_comments,
       round(media_shares, 1) AS media_shares,
       round(media_impressoes) AS media_impressoes
```

![Estatísticas Gerais](imagens/9.%20ESTAT%C3%8DSTICAS%20GERAIS%20DA%20REDE.png)

---

### 10. Hashtags que Aparecem Juntas Mais Frequentemente

Identifica pares de hashtags que aparecem juntas com maior frequência, revelando padrões de uso.

```cypher
MATCH (h1:Hashtag)-[r:RELATED_TO]-(h2:Hashtag)
WHERE r.weight >= 5
RETURN h1.name AS hashtag1,
       h2.name AS hashtag2,
       r.weight AS frequencia_coocorrencia
ORDER BY r.weight DESC
LIMIT 20
```

![Hashtags que Aparecem Juntas](imagens/10.%20HASHTAGS%20QUE%20APARECEM%20JUNTAS%20MAIS%20FREQUENTEMENTE.png)

---

## 🎯 Objetivos do Desafio

✅ **Criar uma base para conexões no grafo**
- Modelagem de dados como grafo
- Criação de nós (InstagramPost e Hashtags)
- Estabelecimento de relacionamentos

✅ **Analisar dados de redes sociais**
- Identificar hashtags mais populares
- Analisar engajamento dos posts
- Descobrir padrões de co-ocorrência de hashtags

✅ **Utilizar consultas de grafos**
- Consultas Cypher para análise de relacionamentos
- Exploração de padrões na rede social

## 🛠️ Personalização

Você pode modificar os scripts para:

- **Adicionar mais análises**: Crie novos métodos em `queries.py` ou novas consultas Cypher
- **Filtrar dados**: Adicione condições WHERE nas consultas
- **Visualizar grafos**: Use o Neo4j Browser para visualizar os relacionamentos graficamente
- **Exportar resultados**: Adicione código para salvar resultados em CSV/JSON

## 📚 Recursos Adicionais

- [Neo4j Aura Documentation](https://neo4j.com/docs/aura/)
- [Neo4j Browser Guide](https://neo4j.com/developer/neo4j-browser/)
- [Cypher Query Language](https://neo4j.com/developer/cypher/)
- [Neo4j Python Driver](https://neo4j.com/docs/python-manual/current/)

## ⚠️ Notas Importantes

- **Neo4j Aura**: Este projeto foi configurado especificamente para Neo4j Aura
- **Importação**: Use a ferramenta de Import do Aura Console para importar o CSV
- **Relacionamentos**: Após importar, execute os scripts Cypher para criar relacionamentos
- **Credenciais**: Mantenha suas credenciais do Aura seguras e não as compartilhe
- **Limites**: A versão gratuita do Aura tem limites de uso

## 🔐 Configuração de Segurança

Ao usar scripts Python, nunca commite suas credenciais no Git. Use variáveis de ambiente:

```python
import os
URI = os.getenv("NEO4J_URI")
USER = os.getenv("NEO4J_USER")
PASSWORD = os.getenv("NEO4J_PASSWORD")
```

## 👨‍💻 Autor

**Ronaldo Melo**

- GitHub: [@RonaldoSMelo](https://github.com/RonaldoSMelo)
- LinkedIn: [Ronaldo Melo](https://www.linkedin.com/in/ronaldo-melo-055732297/)

---

## 📄 Licença

Este projeto é parte de um desafio educacional.
