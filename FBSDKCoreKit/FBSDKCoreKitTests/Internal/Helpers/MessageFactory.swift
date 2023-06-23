/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

final class MessageFactory: _MessageProviding {
  var capturedFrame: CGRect?
  let message = MessageFactory()

  func createMessageTitle(frame: CGRect) -> AppConnect {
    capturedFrame = frame
    return message
  }
}
