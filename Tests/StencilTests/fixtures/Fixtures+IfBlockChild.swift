// Fixtures+IfBlockChild.swift
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
    static let ifBlockChild = """
    {% extends "if-block.html" %}
    {% block title %}{% if sort == "new" %}{{ block.super }} - Nieuwste spellen{% elif sort == "upcoming" %}{{ block.super }} - Binnenkort op de agenda{% elif sort == "near-me" %}{{ block.super }} - In mijn buurt{% endif %}{% endblock %}
    """
}
