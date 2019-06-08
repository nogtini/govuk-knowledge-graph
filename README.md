govuk-knowledge-graph
==============================

Experiment with setting up an extended property graph of GOV.UK organisations and assassociated content.

Project Organization
------------

    ├── LICENSE
    ├── Makefile           <- Makefile with commands like `make data` or `make train`
    ├── README.md          <- The top-level README for developers using this project.
    ├── data               <- Output data from notebooks and scripts should write here; set as DATA_DIR. 
    │
    ├── docs               <- A default Sphinx project; see sphinx-doc.org for details
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
    │                         the creator's initials, and a short `-` delimited description, e.g.
    │                         `1.0-jqp-initial-data-exploration`.
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    │
    ├── src                <- Source code for use in this project.
    ├── __init__.py    <- Makes src a Python module
    │
    ├── data           <- Scripts to download or generate data
    │   └── make_dataset.py
    │
    ├── features       <- Scripts to turn raw data into features for modeling
    │   └── build_features.py
    │
    ├── models         <- Scripts to train models and then use trained models to make
    │   │                 predictions
    │   ├── predict_model.py
    │   └── train_model.py
    │
    └── visualization  <- Scripts to create exploratory and results oriented visualizations
        └── visualize.py

Workflow
------------
If you don't have the `org_edgelist_from_api.csv` file 
you will need to
 [set up the Content Store on a MongoDB instance](https://github.com/ukgovdatascience/govuk-mongodb-content) and run the
 `extract_from_content_store.ipynb`, `extract_from_organisation_api.ipynb`, `create_organisation_net_from_api.ipynb`
  notebooks found in the `notebooks/data_extract` dir.  
  
  You then need to reformat the data into csv files for the nodes and edge lists respectively. Do this by running `create_node_edge_list.pynb` from the `notebooks/neo4j` dir.
  
  This will create a couple of csv that Neo4j will read from. Set up your Neo4j instance using Docker (for a full guide see [here](https://github.com/ukgovdatascience/inno2)) or the desktop version. 
  Copy the node and edge lists csv (`Org.csv` (Node),`org_has_superseded_org.csv`, `org_has_child_org.csv`, `Cid.csv` (Node), `cid_*_org.csv` (5 cid to org edge list files)) into the [Neo4j import dir](https://neo4j.com/developer/desktop-csv-import/).
  
  Load your data into graph database by copying and pasting the Cypher code into the [cypher-shell](https://neo4j.com/docs/operations-manual/current/tools/cypher-shell/) from `src/neo4j/import_edgelist.cypher`. 
  For authentication (depending on whether you used the Docker (check the DockerFile) or desktop app route), the default username and password is typically 'neo4j'. 
  
  You can run Cypher queries directly in the Neo4j browser, through the cypher-shell or using a python driver. 
  We demonstrate this in `notebooks/neo4j/query_graph.ipynb` (the database needs to be created amd running before doing this).
  
  To add the GDS theme to the Neo4j browser extension, click on the star on the top left of the browser tool. 
  This opens a favourites side bar. At the bottom is a dashed square, where you can drag and drop the graph style sheet
   (GRASS) found in `src/neo4j/gds_style.grass`. You can also drop the `src/neo4j/fav_queries.cypher` script that contains
    some exemplar queries to help you get started. These have a plain english description, click on them once they appear 
    to run the query.  
  
  