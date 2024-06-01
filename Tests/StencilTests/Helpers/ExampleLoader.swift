// ExampleLoader.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

import Stencil

class ExampleLoader: Loader {
    func loadTemplate(name: String, environment: Environment) throws -> Template {
        if name == "example.html" {
            return Template(templateString: "Hello World!", environment: environment, name: name)
        }

        throw TemplateDoesNotExist(templateNames: [name], loader: self)
    }
}
