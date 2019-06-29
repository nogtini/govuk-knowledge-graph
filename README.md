govuk-knowledge-graph
==============================

Experiment with setting up an extended property graph of GOV.UK organisations and assassociated content.

> Knowledge is power

# Setup

## Python version
You will need the python interpreter version [Python 3.7.0](https://www.python.org/downloads/release/python-370/).  

## Virtual environment
Create a new python 3.7.0 virtual environment using your favourite virtual environment 
manager (you may need `pyenv` to specify python version; which you can get using `pip install pyenv`). 

If new to python, an easy way to do this is using the PyCharm community edition and opening this repo as a project. 
You can then specify what python interpreter to use (as 
explained [here](https://stackoverflow.com/questions/41129504/pycharm-with-pyenv)).  

## Setting Environment variables
Either source the environment variables from the .envrc file either using direnv (`direnv allow`) or `source .envrc` in the command line or add this EnvFile to the pycharm project run configurations, as described here: 
https://stackoverflow.com/questions/42708389/how-to-set-environment-variables-in-pycharm

You can check they're loaded using `echo $NAME_OF_ENVIRONMENT_VARIABLE` or `printenv`.  

For example:

* __DATA_DIR__ which will point to your local data dir in this project.  
  
## Using pip to install necessary packages
Then install required python packages:  

`pip install -r requirements.txt`  

We provide you with more than the minimal number of packages you need to run this knowledge graph generation pipeline. We provide some 
convenience packages for reviewing notebooks etc.  

Alternatively, you can review the packages that are imported and manually install those that you think are necessary 
using `pip install` if you want more control over the process (and are a confident user). 

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

# Shortcut - quick graph db setup

The quickest way to get this up and running is by contacting someone who has already done it and getting their copy of the 
graph database which can be found in their relevant neo4j dir, look for the `data/databases/graph.db` dir. Copy 
the contents of their `graph.db` to your dir. When you start up neo4j you should 
see the property graph available for use.  

# Full workflow

If you don't have the `org_edgelist_from_api.csv` file 
you will need to
 [set up the Content Store on a MongoDB instance](https://github.com/ukgovdatascience/govuk-mongodb-content) and run the
 `extract_from_content_store.ipynb`, `extract_from_organisation_api.ipynb`, `create_organisation_net_from_api.ipynb`
  notebooks found in the `notebooks/data_extract` dir.  
  
  You then need to reformat the data into csv files for the nodes and edge lists respectively. Do this by running `create_node_edge_list.pynb` from the `notebooks/neo4j` dir.
  
  This will create a few of csv that Neo4j will read from. The follow the general form of being capitalised if they 
  are `Nodes.csv`. Edges are of the form `node_has_relationship_node.csv` (or they have edgelist suffix). There's one code chunk that takes some time 
  to run (it rolls up the data, due to a one to many mapping between `content_id` and `base_path`).
  
## Create the graph database

### Neo4j  
  
  Having set up your Neo4j instance using Docker (for a full guide see [here](https://github.com/ukgovdatascience/inno2)) or the desktop version. 
  Copy the node and edge lists csv (`Org.csv` (Node),`org_has_superseded_org.csv`, `org_has_child_org.csv`, `Cid.csv` (Node), `cid_*_org.csv` (5 cid to org edge list files)) into the [Neo4j import dir](https://neo4j.com/developer/desktop-csv-import/). 
  The `cid_suggested_ordered_related_items_cid.csv` is derived from the related links machine learning pipeline and should be added (it only contains the related links for the top 100 pages).  
  
  There's a whole bunch of others which we won't continue to update here (People and Roles are derived from a current appointments list only, we ignore historical characters for now).
  
  Load your data into graph database by copying and pasting the Cypher code into the [cypher-shell](https://neo4j.com/docs/operations-manual/current/tools/cypher-shell/) from `src/neo4j/import_edgelist.cypher`. 
  For authentication (depending on whether you used the Docker (check the DockerFile) or desktop app route), the default username and password is typically 'neo4j'. 
  
  You can run Cypher queries directly in the Neo4j browser, through the cypher-shell or using a python driver. 
  We demonstrate this in `notebooks/neo4j/query_graph.ipynb` (the database needs to be created amd running before doing this).

### Theme
  To add the GDS theme to the Neo4j browser extension, click on the star on the top left of the browser tool. 
  This opens a favourites side bar. At the bottom is a dashed square, where you can drag and drop the graph style sheet
   (GRASS) found in `src/neo4j/gds_style.grass`. You can also drop the `src/neo4j/fav_queries.cypher` script that contains
    some exemplar queries to help you get started. These have a plain english description, click on them once they appear 
    to run the query.  
    
### Favourite queries
The `fav_queries.cypher` contains a bunch of Cypher queries to get you started.
  
  