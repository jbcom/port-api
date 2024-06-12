# Configuration file for the Sphinx documentation builder.

# -- Project information -----------------------------------------------------

project = 'Port API Documentation'
author = 'Jon Bogaty'
release = '1.0.0'

# -- General configuration ---------------------------------------------------

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
    'sphinx.ext.todo',
    'sphinx.ext.githubpages',
    'sphinx_markdown_tables',
    'myst_parser',
    'sphinxcontrib.mermaid',  # Add this line to include the mermaid extension
]

# List of patterns, relative to source directory, that match files and directories
# to ignore when looking for source files.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# The master toctree document.
master_doc = 'index'

# -- Options for HTML output -------------------------------------------------

html_theme = 'sphinx_rtd_theme'
html_theme_options = {
    'collapse_navigation': False,
    'sticky_navigation': True,
    'navigation_depth': 4,
    'includehidden': True,
    'titles_only': False,
}

html_static_path = ['stylesheets']  # Ensure this path is relative to your docs directory
html_css_files = [
    'extra.css',  # Reference your custom stylesheet here
]

# -- Mermaid configuration ---------------------------------------------------

mermaid_version = "8.9.2"
