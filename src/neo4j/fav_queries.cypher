// What is related, and how?
CALL db.schema()

// What does the view across the content estate look like?
MATCH (n) RETURN n LIMIT 100;

//Who is  associated with this content I'm interested in?
MATCH (a:Cid {contentID: 'f790dc71-386e-4440-9689-31f94e7ac64d'})-[r*1]-(b)
RETURN r, a, b;

//What is my Organisation called?
MATCH (a:Organisation)
RETURN a.name
ORDER BY a.name;

// What kind of nodes exist and how connected are they?
MATCH (n)
RETURN
DISTINCT labels(n),
count(*) AS SampleSize,
avg(size( (n)-[]-() ) ) as Avg_RelationshipCount,
min(size( (n)-[]-() ) ) as Min_RelationshipCount,
max(size( (n)-[]-() ) ) as Max_RelationshipCount;

//Number of Cids each Organisation is primary publisher of?
MATCH (n:Organisation)-[r:HAS_PRIMARY_PUBLISHING_ORGANISATION]-()
RETURN n.name, count(DISTINCT r) AS num
ORDER BY num DESC, n.name;

//What other content and organisations are near to this content?
MATCH (a:Cid {contentID: '5fa922bc-7631-11e4-a3cb-005056011aef'})-[r*1]-(b)
RETURN r, a, b;

// What content is tagged to the Transport or Education taxons?
MATCH (c:Cid)-[:IS_TAGGED_TO]->(t:Taxon)
WHERE t.name = 'Transport' OR t.name = 'Education'
RETURN c.name, c.contentID, c.title, c.description, c.documentType
;

// What content is of a given document type and is tagged to a given taxon?
MATCH (c:Cid{ documentType: "['step_by_step_nav']"})-[:IS_TAGGED_TO]->(:Taxon{name: 'Education, training and skills'})
RETURN c.name, c.contentID, c.title, c.description, c.documentType
;

MATCH (p:People{name: 'Chris Jones'})-[r:HAS_ROLE]-(role:Role) RETURN p, r, role
ORDER BY r.startDate LIMIT 10;
