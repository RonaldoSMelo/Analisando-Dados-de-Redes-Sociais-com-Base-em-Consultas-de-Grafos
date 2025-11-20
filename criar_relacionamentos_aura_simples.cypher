// ===============================================
// SCRIPT CYPHER SIMPLIFICADO PARA NEO4J AURA
// Execute cada seção separadamente no Neo4j Browser
// ===============================================

// PASSO 1: Criar nós de Hashtag e relacionamentos USED_IN
// Processa cada post e extrai hashtags da propriedade 'hashtag'

MATCH (p:InstagramPost)
WHERE p.hashtag IS NOT NULL AND p.hashtag <> ''
WITH p, p.hashtag AS hashtags_string
// Divide por '#' e processa cada parte
UNWIND split(hashtags_string, '#') AS hashtag_part
WITH p, trim(hashtag_part) AS hashtag_clean
WHERE hashtag_clean <> '' 
  AND NOT hashtag_clean CONTAINS '�'  // Remove caracteres inválidos
  AND size(hashtag_clean) > 0
WITH p, lower(hashtag_clean) AS hashtag_lower
WHERE hashtag_lower <> ''
MERGE (h:Hashtag {name: hashtag_lower})
MERGE (h)-[:USED_IN]->(p)
RETURN count(DISTINCT h) AS hashtags_criadas, count(*) AS relacionamentos_criados;

// ===============================================
// PASSO 2: Criar relacionamentos RELATED_TO entre hashtags
// (hashtags que aparecem juntas no mesmo post)

MATCH (h1:Hashtag)-[:USED_IN]->(p:InstagramPost)<-[:USED_IN]-(h2:Hashtag)
WHERE h1.name < h2.name  // Evita duplicatas e auto-relacionamentos
MERGE (h1)-[r:RELATED_TO]-(h2)
ON CREATE SET r.weight = 1
ON MATCH SET r.weight = r.weight + 1
RETURN count(*) AS relacionamentos_hashtag_criados;

// ===============================================
// PASSO 3: Verificar estatísticas finais

MATCH (h:Hashtag)
WITH count(h) AS total_hashtags
MATCH ()-[r:USED_IN]->()
WITH total_hashtags, count(r) AS total_rel_posts
MATCH ()-[r2:RELATED_TO]-()
RETURN total_hashtags,
       total_rel_posts,
       count(r2) AS total_rel_hashtags;

// ===============================================
// CONSULTAS DE TESTE (opcional)

// Ver algumas hashtags criadas
MATCH (h:Hashtag)
RETURN h.name AS hashtag
ORDER BY h.name
LIMIT 20;

// Ver relacionamentos criados
MATCH (h:Hashtag)-[r:USED_IN]->(p:InstagramPost)
RETURN h.name AS hashtag, count(p) AS num_posts
ORDER BY num_posts DESC
LIMIT 10;

