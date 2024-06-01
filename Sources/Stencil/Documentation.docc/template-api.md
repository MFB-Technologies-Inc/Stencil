# Template API

This document describes Stencils Swift API, and not the Swift template language.

## Environment

An environment contains shared configuration such as custom filters and tags
along with template loaders.

```swift
let environment = Environment()
```

You can optionally provide a loader or extensions when creating an environment:

```swift
let environment = Environment(loader: ..., extensions: [...])
```

### Rendering a Template

Environment provides convinience methods to render a template either from a
string or a template loader.

```swift
let template = "Hello {{ name }}"
let context = ["name": "Kyle"]
let rendered = environment.renderTemplate(string: template, context: context)
```

Rendering a template from the configured loader:

```swift
let context = ["name": "Kyle"]
let rendered = environment.renderTemplate(name: "example.html", context: context)
```

### Loading a Template

Environment provides an API to load a template from the configured loader.

```swift
let template = try environment.loadTemplate(name: "example.html")
```

## Loader

Loaders are responsible for loading templates from a resource such as the file
system.

Stencil provides a <doc:FileSystemLoader> which allows you to load a template
directly from the file system.

### FileSystemLoader

<doc:FileSystemLoader>

Loads templates from the file system. This loader can find templates in folders
on the file system.

```swift
FileSystemLoader(paths: ["./templates"])
```

```swift
FileSystemLoader(bundle: [Bundle.main])
```

### DictionaryLoader

<doc:DictionaryLoader>

Loads templates from a dictionary.

```swift
DictionaryLoader(templates: ["index.html": "Hello World"])
```

### Custom Loaders

<doc:Loader> is a protocol, so you can implement your own compatible loaders. You
will need to implement a ``Loader/loadTemplate(name:environment:)`` method to load the template,
throwing a ``TemplateDoesNotExist`` when the template is not found.

```swift
class ExampleMemoryLoader: Loader {
  func loadTemplate(name: String, environment: Environment) throws -> Template {
    if name == "index.html" {
      return Template(templateString: "Hello", environment: environment)
    }

    throw TemplateDoesNotExist(name: name, loader: self)
  }
}
```

## Context

A <doc:Context> is a structure containing any templates you would like to use in
a template. It’s somewhat like a dictionary, however you can push and pop to
scope variables. So that means that when iterating over a for loop, you can
push a new scope into the context to store any variables local to the scope.

You would normally only access the <doc:Context> within a custom template tag or
filter.

### Subscripting

You can use subscripting to get and set values from the context.

```swift
context["key"] = value
let value = context["key"]
```

### Push

<doc:Context/push(dictionary:closure:)>

A <doc:Context> is a stack. You can push a new level onto the <doc:Context> so that
modifications can easily be poped off. This is useful for isolating mutations
into scope of a template tag. Such as `{% if %}` and `{% for %}` tags.

```swift
context.push(["name": "example"]) {
    // context contains name which is `example`.
}

// name is popped off the context after the duration of the closure.
```

### Flatten

<doc:Context/flatten()>

Using ``Context/flatten()`` method you can get whole <doc:Context> stack as one
dictionary including all variables.

```swift
let dictionary = context.flatten()
```

<!-- Copyright (c) 2022, Kyle Fuller
All rights reserved.

Copyright 2024 MFB Technologies, Inc.

This source code is licensed under the BSD-2-Clause License found in the
LICENSE file in the root directory of this source tree. -->
