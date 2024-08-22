# Copyright (C) 2005-2023 IP2Location.com
# All Rights Reserved
#
# This library is free software: you can redistribute it and/or
# modify it under the terms of the MIT license

import os
import IP2Location
from pymongo import MongoClient
import json
import pandas as pd
import time
import concurrent.futures

database = IP2Location.IP2Location(os.path.join("data", "IP2LOCATION-LITE-DB11.BIN"))


def get_location(index,row):
    ip = row['ip']
    rec = database.get_all(ip)
    result = [
        ip,
        rec.country_short,
        rec.country_long,
        rec.region,
        rec.city,
        rec.zipcode
    ]
    data_frame = pd.DataFrame([result])
    data_frame.to_csv('country.csv',header=False,index=False,mode='a',encoding='utf-8')
    del data_frame

def main():
    df = pd.read_csv('ip.csv')
    # count = 0
    # for index,row in df.iterrows():
    #     get_location(index,row)
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(get_location, index,row) for index,row in df.iterrows()]

if __name__ == "__main__":
    main()
