.. _readme:

Port API Client
===============

.. image:: https://github.com/jbcom/port-api/actions/workflows/ci.yml/badge.svg
    :target: https://github.com/jbcom/port-api/actions/workflows/ci.yml
.. image:: https://github.com/jbcom/port-api/actions/workflows/publish.yml/badge.svg
    :target: https://github.com/jbcom/port-api/actions/workflows/publish.yml
.. image:: https://github.com/jbcom/port-api/actions/workflows/openapi-generator.yml/badge.svg
    :target: https://github.com/jbcom/port-api/actions/workflows/openapi-generator.yml
.. image:: https://img.shields.io/github/license/jbcom/port-api
    :target: https://github.com/jbcom/port-api/blob/main/LICENSE
.. image:: https://img.shields.io/github/v/release/jbcom/port-api
    :target: https://github.com/jbcom/port-api/releases
.. image:: https://img.shields.io/librariesio/github/jbcom/port-api
    :target: https://github.com/jbcom/port-api
.. image:: https://img.shields.io/badge/renovate-enabled-brightgreen
    :target: https://github.com/renovatebot/renovate

Overview
--------

This repository contains client libraries for the Port API generated from the OpenAPI specification.

Supported Languages
-------------------

- Python
- Java
- TypeScript
- C#
- Go

Installation
------------

Instructions for installing the generated clients for different languages.

### Python

.. code-block:: shell

    pip install port-api-client

### Java

Add the following dependency to your `pom.xml`:

.. code-block:: xml

    <dependency>
        <groupId>com.yourcompany</groupId>
        <artifactId>port-api-client</artifactId>
        <version>1.0.0</version>
    </dependency>

### TypeScript

.. code-block:: shell

    npm install port-api-client

### C#

.. code-block:: shell

    dotnet add package PortApiClient --version 1.0.0

### Go

.. code-block:: shell

    go get github.com/yourcompany/port-api-client@v1.0.0

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   contributing
   usage
   api/reference

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
