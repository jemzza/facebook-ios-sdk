/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !TARGET_OS_TV

#import "FBSDKHybridAppEventsScriptMessageHandler.h"

#import <FBSDKCoreKit_Basics/FBSDKCoreKit_Basics.h>

#import "FBSDKAppEventsWKWebViewKeys.h"
#import "FBSDKEventLogging.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const FBSDKAppEventsWKWebViewMessagesPixelReferralParamKey = @"_fb_pixel_referral_id";

@protocol FBSDKEventLogging;
@class WKUserContentController;

@interface FBSDKHybridAppEventsScriptMessageHandler ()

@property (nonatomic, weak) id<FBSDKEventLogging> eventLogger;
@property (nonatomic) id<FBSDKLoggingNotifying> loggingNotifier;

@end

@implementation FBSDKHybridAppEventsScriptMessageHandler

- (instancetype)initWithEventLogger:(id<FBSDKEventLogging>)eventLogger
                    loggingNotifier:(id<FBSDKLoggingNotifying>)loggingNotifier
{
  if ((self = [super init])) {
    _eventLogger = eventLogger;
    _loggingNotifier = loggingNotifier;
  }
  return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(NSObject *)message
{

}

@end

NS_ASSUME_NONNULL_END

#endif
