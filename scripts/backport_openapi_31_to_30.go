package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/getkin/kin-openapi/openapi3"
)

func downloadOpenAPISpec(url string) (*openapi3.T, error) {
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

func backportOpenAPI31To30(doc *openapi3.T) *openapi3.T {
	doc.OpenAPI = "3.0.3"

	if doc.Components != nil {
		doc.Components.RequestBodies = nil
		doc.Components.Headers = nil
		doc.Components.Examples = nil
		doc.Components.Links = nil
		doc.Components.Callbacks = nil
		doc.Components.SecuritySchemes = nil

		for _, schema := range doc.Components.Schemas {
			backportSchema(schema.Value)
		}
	}

	for _, pathItem := range doc.Paths {
		for _, operation := range pathItem.Operations() {
			if operation.RequestBody != nil && operation.RequestBody.Value != nil {
				operation.RequestBody.Value.Content = nil
			}
			for _, param := range operation.Parameters {
				if param.Value != nil && param.Value.Schema != nil {
					backportSchema(param.Value.Schema.Value)
				}
			}
			operation.Responses = nil
		}
	}

	return doc
}

func backportSchema(schema *openapi3.Schema) {
	if schema == nil {
		return
	}

	if schema.Properties != nil {
		for _, prop := range schema.Properties {
			backportSchema(prop.Value)
		}
	}

	if schema.Items != nil {
		backportSchema(schema.Items.Value)
	}

	if schema.AdditionalProperties != nil {
		if addProps, ok := schema.AdditionalProperties.Value.(*openapi3.Schema); ok {
			backportSchema(addProps)
		}
	}
}

func saveBackportedSpec(doc *openapi3.T, outputFile string) error {
	data, err := json.MarshalIndent(doc, "", "  ")
	if err != nil {
		return err
	}

	return ioutil.WriteFile(outputFile, data, 0644)
}

func main() {
	url := "https://api.getport.io/json"
	outputFile := "openapi.json"

	doc, err := downloadOpenAPISpec(url)
	if err != nil {
		fmt.Printf("Error downloading OpenAPI spec: %v\n", err)
		os.Exit(1)
	}

	backportedDoc := backportOpenAPI31To30(doc)

	err = saveBackportedSpec(backportedDoc, outputFile)
	if err != nil {
		fmt.Printf("Error saving backported spec: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Successfully backported OpenAPI 3.1 spec to OpenAPI 3.0 and saved to openapi.json")
}
