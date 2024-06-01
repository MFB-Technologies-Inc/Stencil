// Fixtures+ChildChild.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

extension Fixtures {
    static let childChild = """
    {% extends "child.html" %}
    {% block header %}{{ block.super }} Child_Child_Header{% endblock %}
    """
}
