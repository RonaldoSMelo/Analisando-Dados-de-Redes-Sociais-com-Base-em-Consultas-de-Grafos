# 📋 Instruções para Criar Relacionamentos no Neo4j Aura

Você já importou os dados e tem **90 nós `InstagramPost`**, mas ainda **não há relacionamentos**. Siga estes passos para criar a estrutura completa do grafo:

## 🎯 Opção 1: Usar Script Cypher (Mais Rápido - Recomendado)

### Passo 1: Acesse o Neo4j Browser
1. No Neo4j Aura, clique em **"Query"** no menu lateral
2. Você verá o editor de consultas Cypher

### Passo 2: Execute o Script de Criação de Relacionamentos

Abra o arquivo `criar_relacionamentos_aura_simples.cypher` e execute **cada seção separadamente**:

#### Seção 1: Criar Hashtags e Relacionamentos USED_IN
Copie e cole esta consulta:

```cypher
MATCH (p:InstagramPost)
WHERE p.hashtag IS NOT NULL AND p.hashtag <> ''
WITH p, p.hashtag AS hashtags_string
UNWIND split(hashtags_string, '#') AS hashtag_part
WITH p, trim(hashtag_part) AS hashtag_clean
WHERE hashtag_clean <> '' 
  AND NOT hashtag_clean CONTAINS '�'
  AND size(hashtag_clean) > 0
WITH p, lower(hashtag_clean) AS hashtag_lower
WHERE hashtag_lower <> ''
MERGE (h:Hashtag {name: hashtag_lower})
MERGE (h)-[:USED_IN]->(p)
RETURN count(DISTINCT h) AS hashtags_criadas, count(*) AS relacionamentos_criados;
```

**Clique em "Run"** e aguarde. Você verá quantas hashtags e relacionamentos foram criados.

#### Seção 2: Criar Relacionamentos RELATED_TO
Depois que a primeira consulta terminar, execute esta:

```cypher
MATCH (h1:Hashtag)-[:USED_IN]->(p:InstagramPost)<-[:USED_IN]-(h2:Hashtag)
WHERE h1.name < h2.name
MERGE (h1)-[r:RELATED_TO]-(h2)
ON CREATE SET r.weight = 1
ON MATCH SET r.weight = r.weight + 1
RETURN count(*) AS relacionamentos_hashtag_criados;
```

#### Seção 3: Verificar Estatísticas
Execute para ver o resultado final:

```cypher
MATCH (h:Hashtag)
WITH count(h) AS total_hashtags
MATCH ()-[r:USED_IN]->()
WITH total_hashtags, count(r) AS total_rel_posts
MATCH ()-[r2:RELATED_TO]-()
RETURN total_hashtags,
       total_rel_posts,
       count(r2) AS total_rel_hashtags;
```

## 🎯 Opção 2: Usar Script Python

Se preferir usar Python:

1. **Edite o arquivo `criar_relacionamentos.py`**:
   - Substitua `URI` pela URI do seu Neo4j Aura (formato: `neo4j+s://xxxxx.databases.neo4j.io`)
   - Substitua `USER` pelo seu usuário
   - Substitua `PASSWORD` pela sua senha

2. **Execute o script**:
```bash
python criar_relacionamentos.py
```

## ✅ Verificação

Após executar os scripts, verifique no Neo4j Browser:

1. **Database Information** deve mostrar:
   - Nodes: Mais de 90 (posts + hashtags)
   - Relationships: Mais de 0

2. **Execute esta consulta para ver o grafo**:
```cypher
MATCH (h:Hashtag)-[r:USED_IN]->(p:InstagramPost)
RETURN h, r, p
LIMIT 50
```

Mude para a aba **"Graph"** para ver a visualização gráfica!

## 🔍 Consultas Úteis Após Criar Relacionamentos

### Top 10 Hashtags Mais Utilizadas
```cypher
MATCH (h:Hashtag)-[:USED_IN]->(p:InstagramPost)
RETURN h.name AS hashtag, count(p) AS total_posts
ORDER BY total_posts DESC
LIMIT 10
```

### Posts com Mais Engajamento
```cypher
MATCH (p:InstagramPost)
RETURN p.id AS id_post,
       p.like AS likes,
       p.comment AS comments,
       p.share AS shares,
       (p.like + p.comment + p.share) AS engajamento_total
ORDER BY engajamento_total DESC
LIMIT 10
```

### Rede de Hashtags (Visualização)
```cypher
MATCH (h1:Hashtag)-[r:RELATED_TO]-(h2:Hashtag)
WHERE r.weight >= 3
RETURN h1, r, h2
```

## ⚠️ Problemas Comuns

### Se a consulta não funcionar:
1. Verifique se a propriedade se chama `hashtag` (singular) nos seus nós
2. Se for diferente, ajuste a consulta substituindo `p.hashtag` pelo nome correto
3. Verifique se há dados na propriedade executando:
```cypher
MATCH (p:InstagramPost)
RETURN p LIMIT 1
```

### Se aparecerem caracteres estranhos:
- O script já trata isso removendo caracteres inválidos
- Se persistir, pode ser necessário ajustar o filtro na consulta

## 📚 Próximos Passos

Após criar os relacionamentos, você pode:
- Explorar o grafo visualmente no Neo4j Browser
- Executar análises usando o arquivo `queries.py` (ajustando para `InstagramPost`)
- Usar as consultas do arquivo `consultas_cypher.txt`

