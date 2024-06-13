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

    # Properties to be removed
    properties_to_remove = ['discriminator', 'nullable', 'readOnly', 'writeOnly', 'externalDocs', 'xml', 'example', 'content']

    # Initialize the queue with the root spec
    queue = [spec]

    while queue:
        current = queue.pop(0)

        # If the current element is a dictionary, process its keys
        if isinstance(current, dict):
            keys = list(current.keys())
            for key in keys:
                # Remove specific properties
                if key in properties_to_remove:
                    current.pop(key)
                elif key == 'schema':
                    if 'type' not in current[key]:
                        current[key]['type'] = 'object'  # Default to 'object' if type is missing

                # Add nested dictionaries and lists to the queue
                if isinstance(current[key], (dict, list)):
                    queue.append(current[key])

        # If the current element is a list, process its items
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
    save_backported_spec(backported_spec, 'openapi.json')

    validate_spec(backported_spec)
    print("Validation successful")
    print("openapi.json successfully created and validated.")
