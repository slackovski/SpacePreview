SpacePreview
============

A macOS Quick Look plugin for developer files.

.. contents:: Table of Contents
   :depth: 2

Features
--------

* Syntax highlighting for 70+ languages
* Markdown rendering with ``marked.js``
* Automatic light/dark theme
* Line numbers

Installation
------------

.. code-block:: bash

   git clone https://github.com/example/spacepreview
   cd spacepreview
   make install

Supported Languages
-------------------

Web Frontend
~~~~~~~~~~~~

.. list-table::
   :header-rows: 1

   * - Extension
     - Language
   * - ``.ts``, ``.tsx``
     - TypeScript
   * - ``.js``, ``.mjs``
     - JavaScript
   * - ``.vue``
     - Vue

Backend
~~~~~~~

- Go (``.go``)
- Swift (``.swift``)
- Java (``.java``)
- Kotlin (``.kt``)
- Rust (``.rs``)

.. note::
   All files are read-only. SpacePreview never modifies your files.
