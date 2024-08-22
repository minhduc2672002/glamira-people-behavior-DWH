import json
from pymongo import MongoClient
import json
import os

client = MongoClient('mongodb://localhost:27017/')
db = client['countly']  # Thay 'myDatabase' bằng tên database của bạn
collection = db['summary']  # Thay 'myCollection' bằng tên collection của bạn


pipeline =[
  { "$group": { "_id": "$ip" } },
  { "$project": { "_id": 0, "ip": "$_id" } }
]
cursor = collection.aggregate(pipeline)
list_ip = []
for doc in cursor:
    list_ip.append(doc['ip'])


import pandas as pd

data = pd.DataFrame(list_ip,columns = ['ip'])