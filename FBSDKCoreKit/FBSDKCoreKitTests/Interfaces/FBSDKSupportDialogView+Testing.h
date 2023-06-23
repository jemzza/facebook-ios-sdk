/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "FBSDKDialogView+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBSDKDialogView (Testing) <WKNavigationDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nullable, nonatomic, strong) id<FBSDKDialog> activityIndicatorView;

+ (void)resetClassDependencies;

@end

NS_ASSUME_NONNULL_END
