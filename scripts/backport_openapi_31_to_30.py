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

    # Use a queue to avoid recursion
    queue = [spec]

    while queue:
        current = queue.pop(0)
        if isinstance(current, dict):
            for key in list(current.keys()):
                if key == 'oneOf':
                    current[key] = [item for item in current[key] if 'type' in item]
                elif key == 'components':
                    components = current[key]
                    if 'schemas' in components:
                        for schema in components['schemas'].values():
                            queue.append(schema)
                    for comp_key in ['responses', 'requestBodies', 'headers', 'parameters', 'examples', 'links', 'callbacks', 'securitySchemes']:
                        components.pop(comp_key, None)
                elif key == 'paths':
                    for path_item in current[key].values():
                        queue.append(path_item)
                elif key == 'schema' and 'content' in current:
                    queue.append(current['content'].get('application/json', {}))
                elif isinstance(current[key], (dict, list)):
                    queue.append(current[key])

        elif isinstance(current, list):
            for item in current:
                if isinstance(item, (dict, list)):
                    queue.append(item)

    return spec

def save_backported_spec(spec, output_file):
    with open(output_file, 'w') as f:
        json.dump(spec, f, indent=2)

if __name__ == "__main__":
    url = "https://api.getport.io/json"
    spec = download_openapi_spec(url)
    backported_spec = backport_openapi_31_to_30(spec)
    validate_spec(backported_spec)
    save_backported_spec(backported_spec, 'openapi.json')
    print("openapi.json successfully created and validated.")
