/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

/**
 Internal Type exposed to facilitate transition to Swift.
 API Subject to change or removal without warning. Do not use.

 @warning INTERNAL - DO NOT USE
 */

@objcMembers
@objc(FBSDKSupportDialog)
public final class _SupportDialog: NSObject {
  public var shouldDeferVisibility = false
  public weak var delegate: DialogDelegate?
  var name: String
  var frameActive: CGRect
  var parameters: [String: String]?
  var backgroundView: UIView?
  var dialogView: FBSupportDialogView?
  var path: String?

  private enum AnimationDuration {
    static let show = 0.2
    static let dismiss = 0.3
  }

  private enum URLParameterKeys {
    static let display = "display"
    static let sdk = "sdk"
    static let redirectURI = "redirect_uri"
    static let appID = "app_id"
    static let accessToken = "access_token"
  }

  private enum URLParameterValues {
    static let touch = "touch"
    static let sdkVersion = "ios-\(Settings.shared.sdkVersion)"
    static let success = "fbconnect://success"
  }

  public init(
    name: String,
    parameters: [String: String]?,
    frameActive: CGRect = .zero,
    path: String? = nil
  ) {
    self.name = name
    self.parameters = parameters
    self.frameActive = frameActive
    self.path = path
  }

  public convenience init(name: String) {
    self.init(name: name, parameters: nil, frameActive: .zero)
  }

  public func show() {
    do {
      guard (try? Self.getDependencies().windowFinder.findWindow()) != nil else {
        _Logger.singleShotLogEntry(
          .developerErrors,
          logEntry: "There are no valid windows in which to present this web dialog"
        )
        let error = try Self.getDependencies().errorFactory.unknownError(
          message: "There are no valid windows in which to present this web dialog"
        )
        fail(with: error)
        return
      }

      let frame = frameActive.isEmpty ? applicationFrameForOrientation() : frame
      dialogView = FBSupportDialogView(frame: frame)
      dialogView?.delegate = self

    } catch {
      fail(with: error)
    }
  }

  func addObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(deviceOrientationDidChangeNotification(_:)),
      name: UIDevice.orientationDidChangeNotification,
      object: nil
    )
  }

  func deviceOrientationDidChangeNotification(_ notification: Notification) {
    if let animated = notification.userInfo?["UIDeviceOrientationRotateAnimatedUserInfoKey"] as? Bool {
      let animationDuration = animated ? CATransaction.animationDuration() : 0
      updateView(scale: 1.0, alpha: 1.0, animationDuration: animationDuration) { finished in
        if finished {
          self.dialogView?.setNeedsLayout()
        }
      }
    }
  }

  func removeObservers() {
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
  }

  func cancel() {
    delegate?.dialogDidCancel(self)
    dismiss(animated: true)
  }

  func complete(with results: [String: Any]) {
    delegate?.dialog(self, didCompleteWithResults: results)
    dismiss(animated: true)
  }

  func dismiss(animated: Bool) {
    removeObservers()

    let didDismiss: (Bool) -> Void = { _ in
      self.backgroundView?.removeFromSuperview()
      self.dialogView?.removeFromSuperview()
    }

    if animated {
      UIView.animate(
        withDuration: 0.3,
        animations: {
          self.dialogView?.alpha = 0.0
          self.backgroundView?.alpha = 0.0
        },
        completion: didDismiss
      )
    } else {
      didDismiss(true)
    }
  }

  func fail(with error: Error) {
    delegate?.dialog(self, didFailWithError: error)
    dismiss(animated: true)
  }

  func generateURL() throws -> URL {
    var urlParameters = [String: String]()
    urlParameters[URLParameterKeys.display] = URLParameterValues.touch
    urlParameters[URLParameterKeys.sdk] = URLParameterValues.sdkVersion
    urlParameters[URLParameterKeys.redirectURI] = URLParameterValues.success
    urlParameters[URLParameterKeys.appID] = Settings.shared.appID
    urlParameters[URLParameterKeys.accessToken] = AccessToken.current?.tokenString

    if let parameters = parameters {
      urlParameters = parameters.merging(urlParameters) { _, last in last }
    }
    return try InternalUtility.shared.facebookURL(
      hostPrefix: "m",
      path: path ?? "/dialog/\(name)",
      queryParameters: urlParameters
    )
  }

  func applicationFrameForOrientation() -> CGRect {
    var applicationFrame = dialogView?.window?.screen.bounds
    guard var insets = dialogView?.window?.safeAreaInsets else {
      return .zero
    }

    if insets.top == 0 {
      insets.top = UIApplication.shared.statusBarFrame.size.height
    }

    applicationFrame?.origin.x += insets.left
    applicationFrame?.origin.y += insets.top
    applicationFrame?.size.width -= insets.left + insets.right
    applicationFrame?.size.height -= insets.top + insets.bottom
    return applicationFrame ?? .zero
  }

  func updateView(
    scale: CGFloat,
    alpha: CGFloat,
    animationDuration: TimeInterval,
    completion: ((Bool) -> Void)? = nil
  ) {
    let transform = dialogView?.transform
    let applicationFrame = frame.isEmpty ? applicationFrameForOrientation() : frame
    if scale == 1 {
      dialogView?.transform = .identity
      dialogView?.frame = applicationFrame
      dialogView?.transform = transform ?? .identity
    }

    let updateBlock = { [self] in
      dialogView?.transform = transform ?? .identity
      dialogView?.center = CGPoint(x: applicationFrame.midX, y: applicationFrame.midY)
      dialogView?.alpha = alpha
      backgroundView?.alpha = alpha
    }

    if animationDuration == 0 {
      updateBlock()
    } else {
      UIView.animate(withDuration: animationDuration, animations: updateBlock, completion: completion)
    }
  }
}


extension _SupportDialog: SupportDialogViewDelegate {

  public func dialogView(_ dialogView: FBSupportDialogView, didCompleteWithResults results: [String: Any]) {
    complete(with: results)
  }

  public func dialogView(_ dialogView: FBSupportDialogView, didFailWithError error: Error) {
    fail(with: error)
  }

  public func dialogViewDidCancel(_ dialogView: FBSupportDialogView) {
    cancel()
  }

  public func dialogViewDidFinishLoad(_ dialogView: FBSupportDialogView) {
  }
}

extension _SupportDialog: DependentAsType {
  struct TypeDependencies {
    var errorFactory: ErrorCreating
    var windowFinder: _WindowFinding
  }

  static var configuredDependencies: TypeDependencies?

  static var defaultDependencies: TypeDependencies? = TypeDependencies(
    errorFactory: _ErrorFactory(),
    windowFinder: InternalUtility.shared
  )
}
