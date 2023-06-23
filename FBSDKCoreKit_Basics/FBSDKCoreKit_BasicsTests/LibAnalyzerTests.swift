/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

@testable import FBSDKCoreKit_Basics

import XCTest

final class LibAnalyzerTests: XCTestCase {

  func testGetMethodsTableFromPrefixesAndFrameworks() {
    let prefixes = ["FBSDK", "_FBSDK"]
    let frameworks = ["FBSDKCoreKit", "FBSDKLoginKit", "FBSDKShareKit"]
    let result = LibAnalyzer.getMethodsTable(prefixes, frameworks: frameworks)
    XCTAssertFalse(result.isEmpty, "Should find at least one method declared in the provided frameworks")
  }
}
