import functions_framework
import json
import logging
import os
import traceback

from google.cloud import bigquery
from google.cloud import storage


with open('schema.json', 'r') as f:
        schema_json = json.load(f)
    

PROJECT_ID = "people-behavior-glamira.glamira"
BQ_DATASET = "glamira"
TABLE_NAME = "glamira_raw"
CS = storage.Client()
BQ = bigquery.Client()
job_config = bigquery.LoadJobConfig()

def streaming(data):
    bucketname = data['bucket'] 
    print("Bucket name",bucketname)
    
    filename = data['name']   
    print("File name",filename)

    timeCreated = data['timeCreated']
    print("Time Created",timeCreated) 

    try:
        tableSchema = schema_json
        _check_if_table_exists(TABLE_NAME,tableSchema)
        _load_table_from_uri(data['bucket'], data['name'], tableSchema, TABLE_NAME)
    except Exception:
        print('Error streaming file. Cause: %s' % (traceback.format_exc()))
def create_schema_from_json(schema_json):
    schema = []
    for column in schema_json:
        if column['type'] == 'RECORD':
            # Recursively handle nested schemas
            fields = create_schema_from_json(column['fields'])
            schema_field = bigquery.SchemaField(column['name'], column['type'], column['mode'], fields=fields)
        else:
            schema_field = bigquery.SchemaField(column['name'], column['type'], column['mode'])
        
        schema.append(schema_field)
    
    return schema

def _check_if_table_exists(tableName,tableSchema):

    table_id = BQ.dataset(BQ_DATASET).table(tableName)

    try:
        BQ.get_table(table_id)
    except Exception:
        logging.warn('Creating table: %s' % (tableName))
        schema = create_schema_from_json(tableSchema)
        table = bigquery.Table(table_id, schema=schema)
        table = BQ.create_table(table)
        print("Created table {}.{}.{}".format(table.project, table.dataset_id, table.table_id))

def _load_table_from_uri(bucket_name, file_name, tableSchema, tableName):

    uri = 'gs://%s/%s' % (bucket_name, file_name)
    table_id = BQ.dataset(BQ_DATASET).table(tableName)

    schema = create_schema_from_json(tableSchema) 
    print(schema)
    job_config.schema = schema

    job_config.source_format = bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
    job_config.write_disposition = 'WRITE_APPEND',

    load_job = BQ.load_table_from_uri(
    uri,
    table_id,
    job_config=job_config,
    ) 
        
    load_job.result()
    print("Job finished.")

# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def hello_gcs(cloud_event):
    data = cloud_event.data

    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    bucket = data["bucket"]
    name = data["name"]
    metageneration = data["metageneration"]
    timeCreated = data["timeCreated"]
    updated = data["updated"]

    print(f"Event ID: {event_id}")
    print(f"Event type: {event_type}")
    print(f"Bucket: {bucket}")
    print(f"File: {name}")
    print(f"Metageneration: {metageneration}")
    print(f"Created: {timeCreated}")
    print(f"Updated: {updated}")

    streaming(data)
