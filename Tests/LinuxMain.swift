import XCTest

import SitrepCoreTests
import SitrepTests

var tests = [XCTestCaseEntry]()
tests += SitrepCoreTests.allTests()
tests += SitrepTests.allTests()
XCTMain(tests)
