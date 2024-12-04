import json
import time
from datetime import datetime


def fix_timestamp_format(timestamp):
    if timestamp is None:
        return None
    try:
        dt = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
        return dt.strftime('%Y-%m-%d %H:%M:%S')
    except ValueError:
        return timestamp


def convert_field_types(document):
    if 'utm_source' in document and not isinstance(document['utm_source'], dict):
        document['utm_source'] = str(document['utm_source'])
    if 'utm_medium' in document and not isinstance(document['utm_medium'], dict):
        document['utm_medium'] = str(document['utm_medium'])
    if 'order_id' in document and not isinstance(document['order_id'], dict):
        try:
            document['order_id'] = int(document['order_id'])
        except (ValueError, TypeError):
            document['order_id'] = None
    if 'recommendation_product_position' in document and not isinstance(document['recommendation_product_position'],
                                                                        dict):
        try:
            document['recommendation_product_position'] = int(document['recommendation_product_position'])
        except (ValueError, TypeError):
            document['recommendation_product_position'] = None
    if 'local_time' in document:
        document['local_time'] = fix_timestamp_format(document['local_time'])

    if 'cart_products' in document and isinstance(document['cart_products'], list):
        for product in document['cart_products']:
            if 'option' in product and  isinstance(product['option'], list):
                product['option'] = []

    
    document['option'] = []
    return document


def remove_id_and_convert_types(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f, open(output_file, 'w', encoding='utf-8') as out_f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    document = json.loads(line)
                    if '_id' in document:
                        del document['_id']
                    document = convert_field_types(document)
                    out_f.write(json.dumps(document, ensure_ascii=False) + '\n')
                except json.JSONDecodeError:
                    continue


input_file = 'outputfile.json'
output_file = 'summary.json'

start_time = time.time()
remove_id_and_convert_types(input_file, output_file)
end_time = time.time()

elapsed_time = end_time - start_time
print(f"Elapsed time: {elapsed_time} seconds")
