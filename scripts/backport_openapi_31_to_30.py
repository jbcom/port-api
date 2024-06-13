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

    # Recursively process paths and methods
    for path, methods in spec['paths'].items():
        for method, operation in methods.items():
            if 'requestBody' in operation:
                if 'content' in operation['requestBody']:
                    operation['requestBody'] = operation['requestBody']['content'].get('application/json', {})
            for param in operation.get('parameters', []):
                if 'schema' in param and 'type' not in param['schema']:
                    param['schema']['type'] = 'string'  # Default to 'string' if type is missing
            if 'responses' in operation:
                for response in operation['responses'].values():
                    if 'content' in response:
                        for content_type, content in response['content'].items():
                            if 'schema' in content and 'type' not in content['schema']:
                                content['schema']['type'] = 'object'  # Default to 'object' if type is missing

    # Remove unsupported keys
    unsupported_keys = ['discriminator', 'nullable', 'readOnly', 'writeOnly', 'xml', 'externalDocs', 'example']
    def remove_unsupported_keys(schema):
        if isinstance(schema, dict):
            for key in unsupported_keys:
                if key in schema:
                    del schema[key]
            for key, value in schema.items():
                if isinstance(value, dict) or isinstance(value, list):
                    remove_unsupported_keys(value)
        elif isinstance(schema, list):
            for item in schema:
                remove_unsupported_keys(item)

    for component in spec.get('components', {}).get('schemas', {}).values():
        remove_unsupported_keys(component)

    return spec

def save_backported_spec(spec, output_file):
    with open(output_file, 'w') as f:
        json.dump(spec, f, indent=2)
    print(f"Saved backported spec to {output_file}")

if __name__ == "__main__":
    url = "https://api.getport.io/json"
    spec = download_openapi_spec(url)
    print(f"Downloaded spec: {spec}")

    backported_spec = backport_openapi_31_to_30(spec)
    print(f"Backported spec: {backported_spec}")

    validate_spec(backported_spec)
    save_backported_spec(backported_spec, 'openapi.json')
    print("openapi.json successfully created and validated.")
