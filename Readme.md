# Building a data warehouse for glamira website user behavior data
![image](https://github.com/user-attachments/assets/5049133c-58a1-479a-b3ad-e7a843db75be)

# Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Objective](#objective)
4. [WorkFlow](#workflow)
5. [Design Data Warehouse](#design-data-warehouse)
   

## Introduction
In this project, we'll use dbt (Data Build Tool) and SQL on Google BigQuery for data transformation. Our goal is to convert raw data into a more accessible format for extracting insights. dbt, an open-source tool, will help us effectively transform data in our warehouses. We'll use SQL for data management and Google BigQuery, a fully-managed, serverless data warehouse, for super-fast SQL queries.

## Installation
Set up dbt: https://geode-chair-2e1.notion.site/dbt-Set-up-7ed0cf05970f4588b498f0e7d5c98f5b?pvs=4
## Objective

Data is information about users' actions from the time they visit your website until they add to cart and successfully checkout.
Data collected from 2020-04-01 → 2020-06-04 from 223 countries with a total of 41 million records.
The main information of the data includes ip address, access time, action type, current url, selected option type, product_id, price, amount,...
![image](https://github.com/user-attachments/assets/0a25845a-2b93-4151-ae2b-410b5ad4db1f)

## Workflow
![image](https://github.com/user-attachments/assets/45b7913f-d79d-42bb-9f1f-0dc3a8369167)
### Explain:
- Data stored in Mongodb is extracted and loaded into DataLake (Google Cloud Storage).
- Use Cloud Functions to trigger data into BigQuery whenever data arrives in GCS.
- Use DBT to transform and model data into a data warehouse layer.
## Design Data Warehouse
![image](https://github.com/user-attachments/assets/5b9ea6e9-83a8-4392-932f-2dc533413731)

