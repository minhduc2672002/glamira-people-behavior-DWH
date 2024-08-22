from bs4 import BeautifulSoup
import requests
import glob
import os
import concurrent.futures
import pandas as pd
import time
import argparse
import random
import  math

def polite_request(url,time_out = 60):
        time_count = 0
        user_agent = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 Edg/123.0.2420.81",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 OPR/109.0.0.0"
        ]
        while True:
            if time_count >= time_out:
                return None
            try:
                response = requests.get(url,headers={'User-Agent':random.choice(user_agent)})
                response.raise_for_status()
                return response
            except requests.exceptions.ConnectionError:
                print("Network Disconnect!!!")
                time_count += 5
                time.sleep(5)
            except requests.exceptions.RequestException:
                print(f"Request URLs {url} Error!!!")
                time_count += 5
                time.sleep(5)
def download_image(index,row):
    url = row['link_image']
    if not isinstance(url,str) :
         return {
              'index':index,
              'image_path':'None'
         }
    num_view = "-".join(url.split('/')[6:8])
    image_name = row['product_name'].replace(' ','-')
    image_path = f"{image_name}-{num_view}.jpg" 
    local_path = os.path.join(os.getcwd(),'product-image',image_path)
    response = polite_request(url)
    if response.status_code == 200:
        with open(local_path, 'wb') as file:
                file.write(response.content)
        return {'index':index,
                'image_path':image_path
                }
    return {
              'index':index,
              'image_path':'Not Found'
         } 
def crawl_image(data,gcs_path,root_folder_name):

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        futures = [executor.submit(download_image,index,row) for index,row in data.iterrows()]
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            index = result['index']
            image_path = os.path.join(gcs_path,root_folder_name,result['image_path'])
            data.loc[index,'image_path'] = image_path
    return data
def main(file_path):
    data = pd.read_csv(file_path,encoding='utf-8')
    gsc_path = 'gs://glamira_bucket/'
    root_folder_name = 'product-image'

    data['image_path']=pd.NA

    new_df = crawl_image(data,gsc_path,root_folder_name)
    new_df.to_csv('product_image_provider.csv',index=False,encoding='utf-8')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Example script with optional parameters.")
    
    parser.add_argument('file_path', type=str, help='URL to scrape')

    args = parser.parse_args()

    main(args.file_path)