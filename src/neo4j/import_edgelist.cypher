// Tidy up if necessary
// Delete all nodes and relationships
// MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r
// A quick way to drop all indexes and constraints
// CALL apoc.schema.assert({},{},true) YIELD label, key
// RETURN *

CREATE CONSTRAINT ON (o:Organisation) ASSERT o.orgID IS UNIQUE;
CREATE CONSTRAINT ON (o:Organisation) ASSERT o.name IS UNIQUE;
CREATE CONSTRAINT ON (c:Cid) ASSERT c.contentID IS UNIQUE;

// Create Organisations
// from Content Store API
// USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Org.csv" AS line
//using variable organisation and label Organisation
CREATE (o:Organisation {name: line.title, orgID: line.orgid})

;

// Create Cids
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Cid.csv" AS line
FIELDTERMINATOR '\t'
//using variable organisation and label Organisation
// We don't include text for now.
CREATE (c:Cid {name: line.base_path, contentID: line.content_id, title: line.title, description: line.description, documentType: line.document_type})
;

// With nodes created and indexed we can create relationships more quickly
// Create HAS_CHILD relationship
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///org_has_child_org.csv" AS csvLine MATCH (org1:Organisation { name: toString(csvLine.src_title)}), (org2:Organisation { name: tostring(csvLine.target_title)}) CREATE (org1)-[:HAS_CHILD]->(org2)
;

// Create HAS_SUPERSEDED relationship
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///org_has_superseded_org.csv" AS csvLine MATCH (org1:Organisation { name: toString(csvLine.src_title)}), (org2:Organisation { name: tostring(csvLine.target_title)}) CREATE (org1)-[:HAS_SUPERSEDED]->(org2)
;

// Create HAS_ORGANISATIONS relationship
// from Content Store API
// EXPLAIN
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///cid_has_organisations_org.csv" AS csvLine
FIELDTERMINATOR '\t'
MATCH (cid:Cid { contentID: csvLine.content_id}), (org:Organisation { orgID: csvLine.orgid}) CREATE (cid)-[:HAS_ORGANISATIONS]->(org)
;

// Create HAS_ORIGINAL_PRIMARY_PUBLISHING_ORGANISATION relationship
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///cid_has_original_primary_publishing_organisation_org.csv" AS csvLine
FIELDTERMINATOR '\t'
MATCH (cid:Cid { contentID: csvLine.content_id}), (org:Organisation { orgID: csvLine.orgid}) CREATE (cid)-[:HAS_ORIGINAL_PRIMARY_PUBLISHING_ORGANISATION]->(org)
;

// Create HAS_PRIMARY_PUBLISHING_ORGANISATION relationship
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///cid_has_primary_publishing_organisation_org.csv" AS csvLine
FIELDTERMINATOR '\t'
MATCH (cid:Cid { contentID: csvLine.content_id}), (org:Organisation { orgID: csvLine.orgid}) CREATE (cid)-[:HAS_PRIMARY_PUBLISHING_ORGANISATION]->(org)
;

// Create HAS_SUPPORTING_ORGANISATIONS relationship
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///cid_has_supporting_organisations_org.csv" AS csvLine
FIELDTERMINATOR '\t'
MATCH (cid:Cid { contentID: csvLine.content_id}), (org:Organisation { orgID: csvLine.orgid}) CREATE (cid)-[:HAS_SUPPORTING_ORGANISATIONS]->(org)
;
