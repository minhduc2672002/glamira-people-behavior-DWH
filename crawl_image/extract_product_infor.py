from bs4 import BeautifulSoup
import requests
import glob
import os
import concurrent.futures
import pandas as pd
import time
import argparse
import random
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

def load_xml_files(directory):
    xml_files = glob.glob(os.path.join(directory, '*.xml'))
    return xml_files


def extract_infor(url):
    result = []

    loc = url.find('loc').text if url.find('loc') else None
    try:
        respone = polite_request(loc)
        soup2 = BeautifulSoup(respone.content,'html.parser')
        product_id = int(soup2.find('div',class_="price-box main-price price-final_price").get('data-product-id'))
    except:
        product_id=-1
    
    images = url.find_all('image:image')
    try:
        image_caption = images[0].find('image:caption').text

        result.extend([product_id,image_caption,loc])

        for image in images:
            image_loc = image.find('image:loc').text if image.find('image:loc') else 'N/A'
            result.append(image_loc)
    except:
        result.extend([product_id,None,loc])

    return result

def read_extract_save_info(path):
    print(path)
    with open(path, 'r', encoding='utf-8') as file:
        xml_data = file.read()

    soup = BeautifulSoup(xml_data, 'xml')
    urls = soup.find_all('url')
    
    data = []
    count = 0
    max_columns = 0

    s = time.time()

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        futures = [executor.submit(extract_infor, url) for url in urls]
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            number_of_columns = len(result)
            if number_of_columns > max_columns:
                max_columns = number_of_columns
            elif number_of_columns < max_columns:
                result.extend([None] * (max_columns - number_of_columns))
            data.append(result)
            count += 1
            print(count)
    print(f"finish {time.time()-s}")

    new_path = ".".join(path.split(".")[:2]) +".csv"

    df = pd.DataFrame(data)
    df.to_csv(new_path,index=False)
    return new_path 
def process_data(path):
    df = pd.read_csv(path)
    columns_rename = {
        "0":'id',
        "1":'name',
        "2":'link',
        "3":'link_image'
    }
    df.rename(columns=columns_rename,inplace=True)
    columns_to_keep = df.columns[:4]
    df_reduced = df.drop(columns=[col for col in df.columns if col not in columns_to_keep])
    df_reduced =  df_reduced.dropna()
    df_reduced.sort_values(by='id')
    df_reduced.to_csv(path,index=False)
def main(file_path):
    # directory = "./product-image-provider/"
    # list_xml= load_xml_files(directory)
    # for file_path in list_xml:
    #     read_extract_save_info(path=file_path)

    new_path = read_extract_save_info(path=file_path)
    process_data(new_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Example script with optional parameters.")
    
    parser.add_argument('file_path', type=str, help='URL to scrape')

    args = parser.parse_args()

    main(args.file_path)