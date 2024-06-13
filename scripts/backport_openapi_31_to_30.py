import json
import requests
import jsonref
from openapi_spec_validator import validate_spec
import sys


def download_openapi_spec(url):
    response = requests.get(url)
    response.raise_for_status()
    return jsonref.loads(response.text)


def backport_openapi_31_to_30(spec):
    # Update OpenAPI version
    spec['openapi'] = '3.0.3'

    # Use a queue to avoid recursion
    queue = []
    queue.append(spec)

    while queue:
        current = queue.pop(0)
        if isinstance(current, dict):
            for key in list(current.keys()):
                if key == 'oneOf':
                    current[key] = [item for item in current[key] if 'type' in item]
                if key in ['components', 'paths']:
                    for item in current[key].values():
                        queue.append(item)
                elif key == 'schema' and 'content' in current:
                    queue.append(current['content']['application/json'])
                elif isinstance(current[key], (dict, list)):
                    queue.append(current[key])
                if key in ['responses', 'requestBodies', 'headers', 'parameters', 'examples', 'links', 'callbacks', 'securitySchemes']:
                    current.pop(key, None)

    return spec


def save_backported_spec(spec, output_file):
    with open(output_file, 'w') as f:
        json.dump(spec, f, indent=2)


if __name__ == "__main__":
    url = "https://api.getport.io/json"
    spec = download_openapi_spec(url)
    backported_spec = backport_openapi_31_to_30(spec)

    try:
        validate_spec(backported_spec)
    except Exception as e:
        print(f"Validation error: {e}")
        sys.exit(1)
    else:
        save_backported_spec(backported_spec, 'openapi.json')
