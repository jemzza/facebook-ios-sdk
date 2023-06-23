/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !TARGET_OS_TV

#import <UIKit/UIKit.h>

@protocol FBSDKSupportDialogViewDelegate;
@protocol FBSDKConnectViewProviding;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(FBSupportDialogView)
@interface FBSupportDialogView : UIView

@property (nonatomic, weak) id<FBSDKSupportDialogViewDelegate> delegate;

/**
 Internal method exposed to facilitate transition to Swift.
 API Subject to change or removal without warning. Do not use.

 @warning INTERNAL - DO NOT USE
 */
// UNCRUSTIFY_FORMAT_OFF
+ (void)configureWithViewProvider:(id<FBSDKConnectViewProviding>)connectProvider
                           urlOpener:(id<FBSDKInternalURLOpener>)urlOpener
                        errorFactory:(id<FBSDKErrorCreating>)errorFactory
NS_SWIFT_NAME(configure(provider:urlOpener:errorFactory:));
// UNCRUSTIFY_FORMAT_ON

@end

NS_SWIFT_NAME(SupportDialogViewDelegate)
@protocol FBSDKSupportDialogViewDelegate <NSObject>

- (void)dialogView:(FBSupportDialogView *)dialogView didCompleteWithResults:(NSDictionary<NSString *, id> *)results;
- (void)dialogView:(FBSupportDialogView *)dialogView didFailWithError:(NSError *)error;
- (void)dialogViewDidCancel:(FBSupportDialogView *)dialogView;
- (void)dialogViewDidFinishLoad:(FBSupportDialogView *)dialogView;

@end

NS_ASSUME_NONNULL_END

#endif
