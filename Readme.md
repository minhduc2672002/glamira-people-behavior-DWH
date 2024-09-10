# Building a data warehouse for glamira website user behavior data
![image](https://github.com/user-attachments/assets/5049133c-58a1-479a-b3ad-e7a843db75be)

# Table of Contents

1. [Introduction](#1introduction)
2. [Installation](#2installation)
3. [Objective](#3objective)
4. [WorkFlow](#4workflow)
5. [Design Data Warehouse](#5design-data-warehouse)
6. [Report using Looker](#6report-using-looker)
   

## 1.Introduction
In this project, we'll use dbt (Data Build Tool) and SQL on Google BigQuery for data transformation. Our goal is to convert raw data into a more accessible format for extracting insights. dbt, an open-source tool, will help us effectively transform data in our warehouses. We'll use SQL for data management and Google BigQuery, a fully-managed, serverless data warehouse, for super-fast SQL queries.

## 
## 2.Installation
Set up dbt: https://geode-chair-2e1.notion.site/dbt-Set-up-7ed0cf05970f4588b498f0e7d5c98f5b?pvs=4
## 3.Objective

Data is information about users' actions from the time they visit your website until they add to cart and successfully checkout.
Data collected from 2020-04-01 → 2020-06-04 from 223 countries with about 41 million records.
The main information of the data includes ip address, access time, action type, current url, selected option type, product_id, price, amount,...

![image](https://github.com/user-attachments/assets/0a25845a-2b93-4151-ae2b-410b5ad4db1f)

## 4.Workflow
![image](https://github.com/user-attachments/assets/45b7913f-d79d-42bb-9f1f-0dc3a8369167)
### Explain:
- Data stored in Mongodb is extracted and loaded into DataLake (Google Cloud Storage).
- Use Cloud Functions to trigger data into BigQuery whenever data arrives in GCS.
- Use DBT to transform and model data into a data warehouse layer.
### Source Data
![image](https://github.com/user-attachments/assets/6bbe997b-9dc8-409e-b3d4-eab5874d4262)
### Destination Data
![image](https://github.com/user-attachments/assets/3a5e2e8c-443d-4290-bc5e-a3e939c2bb6e)


## 5.Design Data Warehouse
![image](https://github.com/user-attachments/assets/5b9ea6e9-83a8-4392-932f-2dc533413731)
## 6.Report using Looker
![image](https://github.com/user-attachments/assets/5daa6041-a861-437d-a878-c3a7ec2cd534)

