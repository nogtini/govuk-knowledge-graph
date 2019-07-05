// Tidy up if necessary
// Delete all nodes and relationships
// MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r
// A quick way to drop all indexes and constraints
// CALL apoc.schema.assert({},{},true) YIELD label, key
// RETURN *

CREATE CONSTRAINT ON (o:Organisation) ASSERT o.orgID IS UNIQUE;
CREATE CONSTRAINT ON (o:Organisation) ASSERT o.name IS UNIQUE;
CREATE CONSTRAINT ON (c:Cid) ASSERT c.contentID IS UNIQUE;
CREATE CONSTRAINT ON (t:Taxon) ASSERT t.name IS UNIQUE;
CREATE CONSTRAINT ON (t:Taxon) ASSERT t.taxonContentID IS UNIQUE;
CREATE CONSTRAINT ON (p:People) ASSERT p.contentID IS UNIQUE;
CREATE CONSTRAINT ON (role:Role) ASSERT role.name IS UNIQUE;
CREATE CONSTRAINT ON (s:Step) ASSERT s.name IS UNIQUE;

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

// Create Taxons
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Taxon.csv" AS line
FIELDTERMINATOR '\t'
// Unlike content and orgs, taxons don't have a canonical unique id; we use their name to index.
CREATE (t:Taxon {name: line.taxon_title, taxonContentID: line.taxon_content_id, taxonBasePath:line.taxon_base_path})
;

// Create People
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///People.csv" AS line
FIELDTERMINATOR '\t'
CREATE (p:People {name: line.title, contentID: line.content_id, basePath:line.base_path})
;

// Create Role
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Role.csv" AS line
FIELDTERMINATOR '\t'
CREATE (role:Role {name: line.appointment})
;

// Create Step
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///step_title_nodelist.csv" AS line
FIELDTERMINATOR ','
CREATE (step:Step{name: line.step_title, stepID: line.step_id, stepNumber: line.step_number})
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

// Create HAS_SUGGESTED_ORDERED_RELATED_ITEMS relationship
// from Related Links Machine Learning pipeline, node2vec output
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///cid_has_suggested_ordered_related_items_cid.csv" AS csvLine
FIELDTERMINATOR '\t'
MATCH (cid1:Cid { contentID: csvLine.source_content_id}), (cid2:Cid { contentID: csvLine.target_content_id}) CREATE (cid1)-[:HAS_SUGGESTED_ORDERED_RELATED_ITEMS{weight: csvLine.probability}]->(cid2)
;

// Create IS_TAGGED_TO relationship
// from Content Store API
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///content_taxon_edgelist.csv" AS csvLine
MATCH (cid:Cid { contentID: csvLine.content_id}), (t:Taxon { taxonContentID: csvLine.taxon_content_id}) CREATE (cid)-[:IS_TAGGED_TO]->(t)
;

// Create HAS_ROLE relationship
// from Content Store, from the pages
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///appointment_edgelist.csv" AS csvLine
MATCH (p:People { contentID: csvLine.content_id}), (role:Role { name: csvLine.appointment}) CREATE (p)-[:HAS_ROLE{startDate: datetime(csvLine.start_date), endDate: datetime(csvLine.end_date)}]->(role)
;

// Create HAS_TASK
// required some pre-processing of Content Store data
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///task_cid_is_part_of_step_title_edgelist.csv" AS csvLine
MATCH (s:Step { name: csvLine.step_title}), (cid:Cid { contentID: csvLine.task_cid})
CREATE (s)-[:HAS_TASK]->(cid)
;

// Create HAS_STEP
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///step_title_is_part_of_step_by_step_cid_edgelist.csv" AS csvLine
MATCH (cid:Cid { contentID: csvLine.content_id}), (step:Step { name: csvLine.step_title})
CREATE (cid)-[:HAS_STEP{stepNumber: csvLine.step_number}]->(step)
;
