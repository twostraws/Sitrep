<p align="center">
    <img src="https://www.hackingwithswift.com/files/sitrep/logo.png" alt="Sitrep logo" width="483" maxHeight="150" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.1-brightgreen.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-lightgrey.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

Sitrep is source code analyzer for Swift projects, giving you a high-level overview of your code:

- A count of your classes, structs, enums, protocols, and extensions.
- Total lines of code, and also source lines of code (minus comments and whitespace).
- Which file and type are the longest, plus their source lines of code.
- Which imports you’re using and how often.
- How many UIViews, UIViewControllers, and SwiftUI views are in your project.

Behind the scenes, Sitrep captures a lot more information that could be utilized – how many functions you have, how many comments (regular and documentation), how large your enums are, and more. These aren’t currently reported, but could be in a future release. It’s also written as both a library and an executable, so it can be integrated elsewhere as needed.

Sitrep is built using Apple’s [SwiftSyntax](https://github.com/apple/swift-syntax), which means it parses Swift code accurately and efficiently.


## Installation

Sitrep can be used through the Swift Package Manager. You can add it as a dependency in your `Package.swift` file:

```swift
let package = Package(
    //...
    dependencies: [
        .package(url: "https://github.com/twostraws/Sitrep", .branch("master"))
    ],
    //...
)
```

Then `import SitrepCore` wherever you’d like to use it.


To install the Sitrep command line tool, clone the repository and run `make install`:

```bash
git clone https://github.com/twostraws/Sitrep
cd Sitrep
make install
```

From now on you can use the `sitrep` command to scan Swift projects.


## Try it yourself

Sitrep is written using Swift 5.1. You can either build and run the executable directly, or integrate the SitrepCore library into your own code.

To run Sitrep from the command line just provide it with the name of a project directory to parse – it will locate all Swift files recursively from there. Alternatively, just using `sitrep` by itself will scan the current directory.


## Contribution guide

Any help you can offer with this project is most welcome, and trust me: there are opportunities big and small, so that someone with only a small amount of Swift experience can help.

Some suggestions you might want to explore:

- Converting more of the tracked data (number of functions, parameters to functions, length of functions, etc) into reported data.
- Adding a sitrep.yml file that lets users configure how files are scanned, such as the ability to ignore certain directories, what kind of output is printed, or to enable stripped parsing of individual types using `BodyStripper`.
- Additional command-line options, such as whether to output JSON.
- Reading more data from the parsed files, and using it to calculate things such as cyclomatic complexity.
- Reading non-Swift data, such as number of storyboard scenes, number of outlets, number of assets in asset catalogs, etc.

Please ensure you write tests to accompany any code you contribute, and that SwiftLint returns no errors or warnings.


## Credits

Sitrep was designed and built by Paul Hudson, and is copyright © Paul Hudson 2020. Sitrep is licensed under the Apache License v2.0 with Runtime Library Exception; for the full license please see the LICENSE file.

Sitrep is built on top of Apple’s [SwiftSyntax](https://github.com/apple/swift-syntax) library for parsing code, which is also available under the Apache License v2.0 with Runtime Library Exception.

Swift, the Swift logo, and Xcode are trademarks of Apple Inc., registered in the U.S. and other countries.

If you find Sitrep useful, you might find my website full of Swift tutorials equally useful: [Hacking with Swift](https://www.hackingwithswift.com).
