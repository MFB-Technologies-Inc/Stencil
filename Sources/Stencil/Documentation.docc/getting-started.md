# Getting Started

The easiest way to render a template using Stencil is to create a template and
call render on it providing a context.

```swift
let template = Template(templateString: "Hello {{ name }}")
try template.render(["name": "kyle"])
```

For more advanced uses, you would normally create an ``Environment`` and call
the ``Environment/renderTemplate(name:context:)`` convinience method.

```swift
let environment = Environment()

let context = ["name": "kyle"]
try environment.renderTemplate(string: "Hello {{ name }}", context: context)
```

Template Loaders
----------------

A template loader allows you to load files from disk or elsewhere. Using a
``FileSystemLoader`` we can easily render a template from disk.

For example, to render a template called `index.html` inside the
`templates/` directory we can use the following:

```swift
let fsLoader = FileSystemLoader(paths: ["templates/"])
let environment = Environment(loader: fsLoader)

let context = ["name": "kyle"]
try environment.renderTemplate(name: "index.html", context: context)
```

<!-- Copyright (c) 2022, Kyle Fuller
All rights reserved.

Copyright 2024 MFB Technologies, Inc.

This source code is licensed under the BSD-2-Clause License found in the
LICENSE file in the root directory of this source tree. -->
