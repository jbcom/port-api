Contributing
============

Thank you for considering contributing to the Port API project. Please follow these guidelines to help us improve our project.

How to Contribute:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

Release Process
===============

Below is the flowchart for the release process:

.. mermaid::

    graph TD;
      A[New Release] --> B[Generate Clients and Tests];
      B --> C[Run Tests];
      C --> D{All Tests Pass?};
      D -->|Yes| E[Publish to Repositories];
      D -->|No| F[Fix Issues];
      F --> B;
      E --> G[Update Documentation];
      G --> H[Notify Users];
