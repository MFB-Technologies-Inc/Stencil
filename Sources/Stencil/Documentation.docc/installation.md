# Installation

## Swift Package Manager

If you're using the Swift Package Manager, you can add `Stencil` to your
dependencies inside `Package.swift`.

```swift
import PackageDescription

let package = Package(
  name: "MyApplication",
  dependencies: [
    .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
  ]
)
```

## Carthage

> Use at your own risk. We don't offer support for Carthage and instead recommend you use Swift Package Manager.

1) Add `Stencil` to your `Cartfile`:

```
github "stencilproject/Stencil" ~> 0.15.1
```

2) Checkout your dependencies, generate the Stencil Xcode project, and then use Carthage to build Stencil:

```shell
$ carthage update
$ (cd Carthage/Checkouts/Stencil && swift package generate-xcodeproj)
$ carthage build
```

3) Follow the Carthage steps to add the built frameworks to your project.

To learn more about this approach see [Using Swift Package Manager with Carthage](https://fuller.li/posts/using-swift-package-manager-with-carthage/).

<!-- Copyright (c) 2022, Kyle Fuller
All rights reserved.

Copyright 2024 MFB Technologies, Inc.

This source code is licensed under the BSD-2-Clause License found in the
LICENSE file in the root directory of this source tree. -->
