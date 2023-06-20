/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !TARGET_OS_TV

#import "FBSDKWebViewAppLinkResolverWebViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FBSDKWebViewAppLinkResolverWebViewDelegate

- (void)webView:(NSObject *)webView didFinishNavigation:(null_unspecified NSObject *)navigation
{
  if (self.didFinishLoad) {
    self.didFinishLoad(webView);
  }
}

- (void)    webView:(NSObject *)webView
  didFailNavigation:(null_unspecified NSObject *)navigation
          withError:(NSError *)error
{
  if (self.didFailLoadWithError) {
    self.didFailLoadWithError(webView, error);
  }
}

- (void)                  webView:(NSObject *)webView
  decidePolicyForNavigationAction:(NSObject *)navigationAction
                  decisionHandler:(void (^)(NSObject*))decisionHandler
{
  if (self.hasLoaded) {
    self.didFinishLoad(webView);
//    decisionHandler();
  } else {
    self.hasLoaded = YES;
//    decisionHandler();
  }
}

@end

NS_ASSUME_NONNULL_END

#endif
