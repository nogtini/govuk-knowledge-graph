import os
import yaml
import numpy as np
import pandas as pd
import pymongo
import warnings
from bs4 import BeautifulSoup
import datetime
from lxml import etree
from itertools import chain
from lxml import html
from src.utils.metadata_utils import *
from src.utils.text_utils import *

warnings.filterwarnings('ignore', category=UserWarning, module='bs4')





def get_excluded_document_types():
    with open(blacklist_path, 'r') as f:
        return yaml.safe_load(f)['document_types']


def init_mongodb(address):
    mongo_client = pymongo.MongoClient(address)
    content_store_db = mongo_client["content_store"]
    content_store_collection = content_store_db["content_items"]

    return content_store_collection


def get_page_data(mongodb_collection):
    """
    Queries a MongoDB collection, get specific fields from details using TEXT_PROJECTION, converts this cursor to a DataFrame, with all details fields in one list column
    :param mongodb_collection:
    :return: pandas DataFrame with: _id (base_path), content_id, and all_details list column
    """
    content_items = mongodb_collection.find(FILTER, FIELDS)
    row_list = []

    for i, item in enumerate(content_items):

        if 'step_by_step_nav' in item['details'].keys():
            item['sbs_details'] = item['details']['step_by_step_nav']
            item['details'].pop('step_by_step_nav')

        item['text'] = extract_text_from_content_details(item['details'])
        item['description'] = item['description']['value'] \
            if 'description' in item.keys() else ""

        if 'expanded_links' in item.keys():
            item['orgs_id'] = extract_org_id(item['expanded_links'])
            item['orgs_title'] = extract_org_title(item['expanded_links'])

            if 'taxons' in item['expanded_links']:
                taxon_list = []
                for taxon in item['expanded_links']['taxons']:
                    taxon_list.append(get_top_parent(taxon))
                item['taxons'] = taxon_list

            if 'pages_part_of_step_nav' in item['expanded_links']:
                item['pages_part_of_step_nav'] = item['expanded_links'] \
                    ['pages_part_of_step_nav']

            del item['expanded_links']

        row_list.append(item)

        if i % 20000 == 0:
            print(datetime.datetime.now().strftime("%H:%M:%S"), ":", i)

    return row_list


def df_wrapper(mongodb_collection):
    data_list = get_page_data(mongodb_collection)
    df = pd.DataFrame(data_list)
    df.rename(columns={'_id': 'base_path'}, inplace=True)
    return df[['base_path', 'content_id', 'title', 'description',
               'document_type', 'details', 'orgs_id', 'orgs_title',
               'sbs_details',
               'pages_part_of_step_nav',
               'text', 'taxons', 'locale']]


if __name__ == "__main__":
    DATA_DIR = os.getenv("DATA_DIR")
    CONFIG = os.getenv("CONFIG")
    blacklist_path = os.path.join(CONFIG, 'document_types_excluded_from_the_topic_taxonomy.yml')

    init_mongodb("mongodb://localhost:27017/")
