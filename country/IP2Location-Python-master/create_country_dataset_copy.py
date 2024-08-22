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

rec = database.get_all("1.121.117.181")
result = [
        rec.country_short,
        rec.country_long,
        rec.region,
        rec.city,
        rec.zipcode
    ]
for i in result:
    print(i)
data = pd.DataFrame([result])

data.to_csv('test.csv')