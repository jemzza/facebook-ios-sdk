/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

@testable import FBSDKCoreKit

import TestTools
import UIKit
import XCTest

final class BridgeAPIRequestTests: XCTestCase {

  // swiftlint:disable implicitly_unwrapped_optional
  var internalURLOpener: TestInternalURLOpener!
  var internalUtility: TestInternalUtility!
  var settings: TestSettings!
  // swiftlint:enable implicitly_unwrapped_optional

  override func setUp() {
    super.setUp()

    internalURLOpener = TestInternalURLOpener(canOpenURL: true)
    internalUtility = TestInternalUtility()
    settings = TestSettings()

    _BridgeAPIRequest.configure(
      internalURLOpener: internalURLOpener,
      internalUtility: internalUtility,
      settings: settings
    )
  }

  override func tearDown() {
    _BridgeAPIRequest.resetClassDependencies()

    internalURLOpener = nil
    internalUtility = nil
    settings = nil

    super.tearDown()
  }

  private func makeRequest(
    protocolType: FBSDKBridgeAPIProtocolType = .web,
    scheme: URLScheme = .https
  ) -> _BridgeAPIRequest? {
    _BridgeAPIRequest(
      protocolType: protocolType,
      scheme: scheme,
      methodName: "methodName",
      parameters: ["parameter": "value"],
      userInfo: ["key": "value"]
    )
  }

  func testDefaultClassDependencies() throws {
    _BridgeAPIRequest.resetClassDependencies()
    _ = makeRequest()

    XCTAssertNil(_BridgeAPIRequest.settings, "Should not have a default settings")
    XCTAssertNil(_BridgeAPIRequest.internalUtility, "Should not have a default internal utility")
    XCTAssertNil(_BridgeAPIRequest.internalURLOpener, "Should not have a default internal url opener")
  }

  func testRequestProtocolConformance() {
    XCTAssertTrue(
      (_BridgeAPIRequest.self as Any) is BridgeAPIRequestProtocol.Type,
      "_BridgeAPIRequest should conform to the expected protocol"
    )
  }

  func testOpenableURL() {
    XCTAssertNotNil(
      makeRequest(protocolType: .native, scheme: .facebookAPI),
      "BridgeAPIRequests should only be created for openable URLs"
    )
  }

  func testUnopenableRequestURL() throws {
    let request = try XCTUnwrap(makeRequest())
    internalURLOpener.canOpenURL = false

    XCTAssertThrowsError(
      try request.requestURL(),
      "Unopenable request URLs should not be provided"
    )
  }

  func testCopying() throws {
    let request = try XCTUnwrap(makeRequest())
    let copy = try XCTUnwrap(request.copy() as AnyObject)
    XCTAssertTrue(request === copy, "Instances should be provided as copies of themselves")
  }
}
