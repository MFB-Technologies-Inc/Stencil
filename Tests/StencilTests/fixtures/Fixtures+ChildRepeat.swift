// Fixtures+ChildRepeat.swift
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
    static let childRepeat = """
    {% extends "base-repeat.html" %}
    {% block header %}Super_{{ block.super }} Child_Header{% endblock %}
    {% block body %}Child_Body{% endblock %}
    """
}
