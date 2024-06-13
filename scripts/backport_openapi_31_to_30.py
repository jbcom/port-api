import json
import requests
import jsonref
from openapi_spec_validator import validate_spec

def download_openapi_spec(url):
    response = requests.get(url)
    response.raise_for_status()
    return jsonref.loads(response.text)

def backport_openapi_31_to_30(spec):
    # Update OpenAPI version
    spec['openapi'] = '3.0.3'

    def process_schema(schema):
        queue = [schema]
        while queue:
            current = queue.pop(0)
            if isinstance(current, dict):
                if '$schema' in current:
                    del current['$schema']
                if 'discriminator' in current:
                    del current['discriminator']
                if 'nullable' in current:
                    del current['nullable']
                if 'readOnly' in current:
                    del current['readOnly']
                if 'writeOnly' in current:
                    del current['writeOnly']
                if 'externalDocs' in current:
                    del current['externalDocs']
                if 'xml' in current:
                    del current['xml']
                if 'example' in current:
                    del current['example']
                if 'content' in current:
                    del current['content']
                if 'title' not in current:
                    current['title'] = "InlineModel"
                for key, value in current.items():
                    if isinstance(value, (dict, list)):
                        queue.append(value)
            elif isinstance(current, list):
                for item in current:
                    queue.append(item)

    # Process components schemas
    if 'components' in spec and 'schemas' in spec['components']:
        for schema in spec['components']['schemas'].values():
            process_schema(schema)

    # Process paths
    for path_item in spec['paths'].values():
        for operation in path_item.values():
            if 'requestBody' in operation and 'content' in operation['requestBody']:
                operation['requestBody'] = operation['requestBody']['content'].get('application/json', {})
            for param in operation.get('parameters', []):
                if 'schema' in param and 'type' not in param['schema']:
                    param['schema']['type'] = 'string'
            for key in ['responses', 'callbacks', 'deprecated', 'servers']:
                operation.pop(key, None)

    return spec

def save_backported_spec(spec, output_file):
    with open(output_file, 'w') as f:
        json.dump(spec, f, indent=2)
    print(f"Saved backported spec to {output_file}")

if __name__ == "__main__":
    url = "https://api.getport.io/json"
    spec = download_openapi_spec(url)
    backported_spec = backport_openapi_31_to_30(spec)
    validate_spec(backported_spec)
    save_backported_spec(backported_spec, 'openapi.json')
    print("openapi.json successfully created and validated.")
    
