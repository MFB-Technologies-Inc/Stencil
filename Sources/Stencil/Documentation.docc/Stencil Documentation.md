# ``Stencil``

@Metadata {
    @DisplayName("Stencil")
}

## Overview

Stencil is a simple and powerful template language for Swift. It provides a
syntax similar to Django and Mustache. If you're familiar with these, you will
feel right at home with Stencil.

```html
There are {{ articles.count }} articles.

<ul>
  {% for article in articles %}
    <li>{{ article.title }} by {{ article.author }}</li>
  {% endfor %}
</ul>
```

```swift
import Stencil

struct Article {
  let title: String
  let author: String
}

let context = [
  "articles": [
    Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
    Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
  ]
]

let environment = Environment(loader: FileSystemLoader(paths: ["templates/"])
let rendered = try environment.renderTemplate(name: "articles.html", context: context)

print(rendered)
```

## Topics

### For Template Writers

Resources for Stencil template authors to write Stencil templates.

   - <doc:template-language>
   - <doc:built-in-template-tags-and-filters>

### For Developers

Resources to help you integrate Stencil into a Swift project.

- <doc:installation>
- <doc:getting-started>
- <doc:template-api>
- <doc:custom-template-tags-and-filters>

<!-- Copyright (c) 2022, Kyle Fuller
All rights reserved.

Copyright 2024 MFB Technologies, Inc.

This source code is licensed under the BSD-2-Clause License found in the
LICENSE file in the root directory of this source tree. -->
