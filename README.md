<p align="center">
    <img src="https://www.hackingwithswift.com/files/sitrep/logo.png" alt="Sitrep logo" width="483" maxHeight="150" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.4-red.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-blueviolet.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

Sitrep is a source code analyzer for Swift projects, giving you a high-level overview of your code:

- A count of your classes, structs, enums, protocols, and extensions.
- Total lines of code, and also source lines of code (minus comments and whitespace).
- Which file and type are the longest, plus their source lines of code.
- Which imports you’re using and how often.
- How many UIViews, UIViewControllers, and SwiftUI views are in your project.

Behind the scenes, Sitrep captures a lot more information that could be utilized – how many functions you have, how many comments (regular and documentation), how large your enums are, and more. These aren’t currently reported, but could be in a future release. It’s also written as both a library and an executable, so it can be integrated elsewhere as needed.

Sitrep is built using Apple’s [SwiftSyntax](https://github.com/apple/swift-syntax), which means it parses Swift code accurately and efficiently. 

**Note:** Please make sure that the SwiftSyntax version specified in Package.swift matches your current Swift tools version. For example, if you're using Swift tools 5.3 you need to change the spec from `0.50400.0` to `0.50300.0`.


## Installation

If you want to install the Sitrep command line tool, you have three options: [Homebrew](https://brew.sh), [Mint](https://github.com/yonaskolb/Mint), or building it from the command line yourself.

Use this command for Homebrew:

```bash
brew install twostraws/brew/sitrep
```

Using Homebrew allows you to run `sitrep` directly from the command line.

For Mint, install and run Sitrep with these command:

```bash
mint install twostraws/Sitrep@main
mint run sitrep@main
```

And finally, to build and install the command line tool yourself, clone the repository and run `make install`:

```bash
git clone https://github.com/twostraws/Sitrep
cd Sitrep
make install
```

As with the Homebrew option, building the command line tool yourself allows you to use the `sitrep` command directly from the command line.


## Using Sitrep as a library

Sitrep is implemented as a library that does all the hard work of scanning and reporting, plus a small front end that handles reading and writing on the command line. As an alternative to using Sitrep from the command line, you can also use its library SitrepCore from inside your own Swift code.

First, add Sitrep as a dependency in your `Package.swift` file:

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



## Command line flags

When run on the command line without any flags, Sitrep will automatically scan your current directory and print its findings as text. To control this behavior, Sitrep supports several command line flags:

- `-c` lets you specify a path to your **.sitrep.yml** configuration file, if you have one.
- `-f` sets the output format. For example, `-f json` enables JSON output. The default behavior is text output, which is equivalent to `-f text`.
- `-i` will print debug information, showing the settings Sitrep would use if a real scan were requested, then exits.
- `-p` sets the path Sitrep should scan. This defaults to your current working directory. 
- `-h` prints command line help.


## Configuration

You can customize the behavior of Sitrep by creating a **.sitrep.yml** file in the directory you wish to scan. This is a [YAML](https://en.wikipedia.org/wiki/YAML) file that allows you to provide permanent options for scanning this path, although right now this is limited to one thing: an array of directory names to exclude from the scan.

For example, if you wanted to exclude the **.build** directory and your tests, you might create a **.sitrep.yml** file such as this one:

```yaml
excluded:
  - .build
  - Tests
```

You can ask Sitrep to use a custom configuration file using the `-c` parameter, for example `sitrep -c /path/to/.sitrep.yml -p /path/to/swift/project`.

Alternatively, you can use the `-i` parameter to have Sitrep tell you the configuration options it would use in a real analysis run. This will print the configuration information then exit.


## Try it yourself

Sitrep is written using Swift 5.3. You can either build and run the executable directly, or integrate the SitrepCore library into your own code.

To build Sitrep, clone this repository and open Terminal in the repository root directory. Then run:

```bash
swift build
swift run sitrep -p ~/path/to/your/project/root
```

If you would like to keep a copy of the `sitrep` executable around, find it in the `.debug` directory after running `swift build`.

To run Sitrep from the command line just provide it with the name of a project directory to parse – it will locate all Swift files recursively from there. Alternatively, just using `sitrep` by itself will scan the current directory.


## Contribution guide

Any help you can offer with this project is most welcome, and trust me: there are opportunities big and small, so that someone with only a small amount of Swift experience can help.

Some suggestions you might want to explore:

- Converting more of the tracked data (number of functions, parameters to functions, length of functions, etc) into reported data.
- Reading more data from the parsed files, and using it to calculate things such as cyclomatic complexity.
- Reading non-Swift data, such as number of storyboard scenes, number of outlets, number of assets in asset catalogs, etc.

Please ensure you write tests to accompany any code you contribute, and that SwiftLint returns no errors or warnings.


## Credits

Sitrep was designed and built by Paul Hudson, and is copyright © Paul Hudson 2021. Sitrep is licensed under the Apache License v2.0 with Runtime Library Exception; for the full license please see the LICENSE file.

Sitrep is built on top of Apple’s [SwiftSyntax](https://github.com/apple/swift-syntax) library for parsing code, which is also available under the Apache License v2.0 with Runtime Library Exception.

Swift, the Swift logo, and Xcode are trademarks of Apple Inc., registered in the U.S. and other countries.

If you find Sitrep useful, you might find my website full of Swift tutorials equally useful: [Hacking with Swift](https://www.hackingwithswift.com).
