/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !TARGET_OS_TV

#import "FBSDKSupportDialogView+Internal.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit-Swift.h>
#import <FBSDKCoreKit_Basics/FBSDKCoreKit_Basics.h>

#import "FBSDKSafeCast.h"
#import "FBSDKConnectViewProviding.h"

#define FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH 10.0

@interface FBSupportDialogView () <NSObject>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) id<FBSDKConnectAppView> activityIndicatorView;

@end

@implementation FBSupportDialogView

static id<FBSDKConnectViewProviding> _connectViewProvider;
static id<FBSDKInternalURLOpener> _urlOpener;
static id<FBSDKErrorCreating> _errorFactory;

+ (void)configureWithViewProvider:(id<FBSDKConnectViewProviding>)viewProvider
                           urlOpener:(id<FBSDKInternalURLOpener>)urlOpener
                        errorFactory:(id<FBSDKErrorCreating>)errorFactory;
{
  _connectViewProvider = viewProvider;
  _urlOpener = urlOpener;
  _errorFactory = errorFactory;
}

+ (nullable id<FBSDKConnectViewProviding>)connectViewProvider
{
  return _connectViewProvider;
}

+ (void)setConnectViewProvider:(id<FBSDKConnectViewProviding>)connectViewProvider
{
  _connectViewProvider = connectViewProvider;
}

+ (nullable id<FBSDKInternalURLOpener>)urlOpener
{
  return _urlOpener;
}

+ (void)setUrlOpener:(nullable id<FBSDKInternalURLOpener>)urlOpener
{
  _urlOpener = urlOpener;
}

+ (nullable id<FBSDKErrorCreating>)errorFactory
{
  return _errorFactory;
}

+ (void)setErrorFactory:(nullable id<FBSDKErrorCreating>)errorFactory
{
  _errorFactory = errorFactory;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = UIColor.clearColor;
    self.opaque = NO;

    _activityIndicatorView = [self.class.connectViewProvider createConnectViewWithFrame:CGRectZero];
    _activityIndicatorView.navigationDelegate = self;

    UIView *dialogView = _FBSDKCastToClassOrNilUnsafeInternal(_activityIndicatorView, UIView.class);
    if (!dialogView) {
      return self;
    }

    [self addSubview:dialogView];

    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [[FBSDKCloseIcon new] imageWithSize:CGSizeMake(29.0, 29.0)];
    [_closeButton setImage:closeImage forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor colorWithRed:167.0 / 255.0
                                                green:184.0 / 255.0
                                                 blue:216.0 / 255.0
                                                alpha:1.0] forState:UIControlStateNormal];
    [_closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    _closeButton.showsTouchWhenHighlighted = YES;
    [_closeButton sizeToFit];
    [self addSubview:_closeButton];
    [_closeButton addTarget:self action:@selector(_close:) forControlEvents:UIControlEventTouchUpInside];

    UIActivityIndicatorViewStyle style;
    if (@available(iOS 13.0, *)) {
      style = UIActivityIndicatorViewStyleLarge;
    } else {
      #pragma clang diagnostic push
      #pragma clang diagnostic ignored "-Wdeprecated-declarations"
      style = UIActivityIndicatorViewStyleWhiteLarge;
      #pragma clang diagnostic pop
    }
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    _loadingView.color = UIColor.grayColor;
    _loadingView.hidesWhenStopped = YES;
    [dialogView addSubview:_loadingView];
  }
  return self;
}

- (void)dealloc
{
  self.activityIndicatorView.navigationDelegate = nil;
}

#pragma mark - Layout

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  [self.backgroundColor setFill];
  CGContextFillRect(context, self.bounds);
  [UIColor.blackColor setStroke];
  CGContextSetLineWidth(context, 1.0 / self.layer.contentsScale);
  CGContextStrokeRect(context, self.activityIndicatorView.frame);
  CGContextRestoreGState(context);
  [super drawRect:rect];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGRect bounds = self.bounds;
  if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
    CGFloat horizontalInset = CGRectGetWidth(bounds) * 0.2;
    CGFloat verticalInset = CGRectGetHeight(bounds) * 0.2;
    UIEdgeInsets iPadInsets = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    bounds = UIEdgeInsetsInsetRect(bounds, iPadInsets);
  }
  UIEdgeInsets dialogInsets = UIEdgeInsetsMake(
    FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH,
    FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH,
    FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH,
    FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH
  );
  self.activityIndicatorView.frame = CGRectIntegral(UIEdgeInsetsInsetRect(bounds, dialogInsets));

  CGRect dialogBounds = self.activityIndicatorView.bounds;
  self.loadingView.center = CGPointMake(CGRectGetMidX(dialogBounds), CGRectGetMidY(dialogBounds));

  if (CGRectGetHeight(dialogBounds) == 0.0) {
    self.closeButton.alpha = 0.0;
  } else {
    self.closeButton.alpha = 1.0;
    CGRect closeButtonFrame = self.closeButton.bounds;
    closeButtonFrame.origin = bounds.origin;
    self.closeButton.frame = CGRectIntegral(closeButtonFrame);
  }
}

#pragma mark - Actions

- (void)_close:(id)sender
{
  [self.delegate dialogViewDidCancel:self];
}

#if DEBUG

+ (void)resetClassDependencies
{
  self.connectViewProvider = nil;
  self.urlOpener = nil;
  self.errorFactory = nil;
}

#endif

@end

#endif
