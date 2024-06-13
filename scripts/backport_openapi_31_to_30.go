package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/getkin/kin-openapi/openapi3"
)

// DownloadOpenAPISpec downloads the OpenAPI spec from the given URL
func DownloadOpenAPISpec(url string) (*openapi3.T, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	loader := openapi3.NewLoader()
	doc, err := loader.LoadFromData(body)
	if err != nil {
		return nil, err
	}

	return doc, nil
}

// BackportOpenAPI31To30 converts OpenAPI 3.1 spec to 3.0
func BackportOpenAPI31To30(doc *openapi3.T) *openapi3.T {
	doc.OpenAPI = "3.0.3"

	// Use a queue to avoid recursion
	queue := []interface{}{doc.Paths}

	for len(queue) > 0 {
		current := queue[0]
		queue = queue[1:]

		switch current := current.(type) {
		case openapi3.Paths:
			for _, pathItem := range current {
				queue = append(queue, pathItem)
			}
		case *openapi3.PathItem:
			if current != nil {
				for _, op := range []*openapi3.Operation{current.Get, current.Put, current.Post, current.Delete, current.Options, current.Head, current.Patch, current.Trace} {
					if op != nil {
						queue = append(queue, op)
					}
				}
			}
		case *openapi3.Operation:
			if current.RequestBody != nil && current.RequestBody.Value != nil {
				queue = append(queue, current.RequestBody.Value.Content)
			}
			if current.Responses != nil {
				for _, response := range *current.Responses {
					if response.Value != nil {
						queue = append(queue, response.Value.Content)
					}
				}
			}
		case openapi3.Content:
			for _, mediaType := range current {
				queue = append(queue, mediaType.Schema)
			}
		case *openapi3.SchemaRef:
			if current != nil && current.Value != nil {
				schema := current.Value
				if schema.OneOf != nil {
					newOneOf := []*openapi3.SchemaRef{}
					for _, item := range schema.OneOf {
						if item.Value != nil && item.Value.Type != "" {
							newOneOf = append(newOneOf, item)
						}
					}
					schema.OneOf = newOneOf
				}
				if schema.AdditionalProperties != nil {
					if additionalProperties, ok := schema.AdditionalProperties.(*openapi3.SchemaOrBool); ok {
						if additionalProperties.Schema != nil {
							queue = append(queue, additionalProperties.Schema)
						}
					}
				}
				queue = append(queue, schema.Properties)
				if schema.Items != nil {
					queue = append(queue, schema.Items)
				}
			}
		case map[string]*openapi3.SchemaRef:
			for _, schema := range current {
				queue = append(queue, schema)
			}
		}
	}

	return doc
}

// SaveBackportedSpec saves the modified spec to a file
func SaveBackportedSpec(spec *openapi3.T, outputFile string) error {
	data, err := json.MarshalIndent(spec, "", "  ")
	if err != nil {
		return err
	}

	return ioutil.WriteFile(outputFile, data, 0644)
}

// ValidateSpec validates the OpenAPI spec
func ValidateSpec(filePath string) error {
	loader := openapi3.NewLoader()
	doc, err := loader.LoadFromFile(filePath)
	if err != nil {
		return err
	}

	return doc.Validate(loader.Context)
}

func main() {
	url := "https://api.getport.io/json"
	outputFile := "openapi.json"

	spec, err := DownloadOpenAPISpec(url)
	if err != nil {
		log.Fatalf("Error downloading OpenAPI spec: %v", err)
	}

	backportedSpec := BackportOpenAPI31To30(spec)

	err = SaveBackportedSpec(backportedSpec, outputFile)
	if err != nil {
		log.Fatalf("Error saving backported spec: %v", err)
	}

	err = ValidateSpec(outputFile)
	if err != nil {
		log.Fatalf("Validation error: %v", err)
	}

	fmt.Println("openapi.json successfully created and validated.")
}
