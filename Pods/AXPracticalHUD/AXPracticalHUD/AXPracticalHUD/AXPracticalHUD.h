//
//  AXPracticalHUD.h
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXBarProgressView.h"
#import "AXCircleProgressView.h"
#import "AXGradientProgressView.h"
#import "AXPracticalHUDContentView.h"

#ifndef kAXPracticalHUDPadding
#define kAXPracticalHUDPadding 4.0f
#endif
#ifndef kAXPracticalHUDMaxMovement
#define kAXPracticalHUDMaxMovement 14.0f
#endif
#ifndef kAXPracticalHUDFontSize
#define kAXPracticalHUDFontSize 14.0f
#endif
#ifndef kAXPracticalHUDDetailFontSize
#define kAXPracticalHUDDetailFontSize 12.0f
#endif
#ifndef kAXPracticalHUDDefaultMargin
#define kAXPracticalHUDDefaultMargin 15.0f
#endif
/*!
 *  Mode of hud view
 */
typedef NS_ENUM(NSInteger, AXPracticalHUDMode) {
    /*!
     *  Progress is shown using an UIActivityIndicatorView. This is the default.
     */
    AXPracticalHUDModeIndeterminate,
    /*!
     *  Progress is shown using a round, pie-chart like, progress view.
     */
    AXPracticalHUDModeDeterminate,
    /*!
     *  Progress is shown using a horizontal progress bar
     */
    AXPracticalHUDModeDeterminateHorizontalBar,
    /*!
     *  Progress is shown using a horizontal colorful progress bar
     */
    AXPracticalHUDModeDeterminateColorfulHorizontalBar,
    /*!
     *  Progress is shown using a ring-shaped progress view.
     */
    AXPracticalHUDModeDeterminateAnnularEnabled,
    /*!
     *  Shows a custom view
     */
    AXPracticalHUDModeCustomView,
    /*!
     *  Shows only labels
     */
    AXPracticalHUDModeText
};
/*!
 *  Animation styles of hud view animating.
 */
typedef NS_ENUM(NSInteger, AXPracticalHUDAnimation) {
    /*!
     *  Using fade animation.
     */
    AXPracticalHUDAnimationFade,
    /*!
     *  Using flip in animation.
     */
    AXPracticalHUDAnimationFlipIn
};
/*!
 *  Position of hud view.
 */
typedef NS_ENUM(NSInteger, AXPracticalHUDPosition) {
    /*!
     *  Top position.
     */
    AXPracticalHUDPositionTop,
    /*!
     *  Center position.
     */
    AXPracticalHUDPositionCenter,
    /*!
     *  Bottom position
     */
    AXPracticalHUDPositionBottom
};
/// Completion block when task finished.
typedef void(^AXPracticalHUDCompletionBlock)();
/// HUD delegate
@protocol AXPracticalHUDDelegate;

@interface AXPracticalHUD : UIView
/// Restore the hud view when hud hided if YES, setting the properties of hud view to the initial state. Default is No.
@property(assign, nonatomic) BOOL restoreEnabled;
/// Lock the background to avoid the touch events if YES. Default is NO.
@property(assign, nonatomic) BOOL lockBackground;
/// Total size of hud container view. Read only.
@property(readonly, nonatomic) CGSize size;
/// Using the square content view if YES. Default is NO.
@property(assign, nonatomic) BOOL square;
/// Margin of content views. Default is 15.0f.
@property(assign, nonatomic) CGFloat margin;
/// Offset of container view in x position. Default is 0.0f.
@property(assign, nonatomic) CGFloat offsetX;
/// Offset of container view in y position. Default is 0.0f.
@property(assign, nonatomic) CGFloat offsetY;
/// Minimum size of container view. Default is CGSizeZero.
@property(assign, nonatomic) CGSize minSize;
/// Grace time showing hud view. Default is 0.0f.
@property(assign, nonatomic) NSTimeInterval graceTime;
/// Animation style of hud view. Default is .Fade.
@property(assign, nonatomic) AXPracticalHUDAnimation animation;
/// Completion block when hud view has hidden.
@property(copy, nonatomic) AXPracticalHUDCompletionBlock completion;
/// Minimum showing time interval of hud view. Default is 0.5f.
@property(assign, nonatomic) NSTimeInterval minShowTime;
/// Using dim background is YES. Default is NO.
@property(assign, nonatomic) BOOL dimBackground;
/// Delegate
@property(assign, nonatomic) id<AXPracticalHUDDelegate>delegate;
/// The insets of views. Default is {15.0f, 15.0f, 15.0f, 15.0f}
@property(assign, nonatomic) UIEdgeInsets contentInsets;
@property(readonly, nonatomic) BOOL progressing;
@property(assign, nonatomic) CGFloat opacity;
@property(strong, nonatomic) UIColor *color;
@property(strong, nonatomic) UIColor *endColor;
@property(assign, nonatomic) BOOL translucent;
@property(assign, nonatomic) AXPracticalHUDTranslucentStyle translucentStyle;
@property(strong, nonatomic) NSString *text;
@property(strong, nonatomic) UIFont *font;
@property(assign, nonatomic) AXPracticalHUDMode mode;
@property(assign, nonatomic) AXPracticalHUDPosition position;
@property(assign, nonatomic) CGFloat progress;
@property(strong, nonatomic) NSString *detailText;
@property(strong, nonatomic) UIView *customView;
@property(assign, nonatomic) CGFloat cornerRadius;
@property(strong, nonatomic) UIColor *detailTextColor;
@property(strong, nonatomic) UIColor *textColor;
@property(strong, nonatomic) UIFont *detailFont;
@property(strong, nonatomic) UIColor *activityIndicatorColor;
@property(assign, nonatomic) BOOL removeFromSuperViewOnHide;

- (instancetype)initWithView:(UIView *)view;
- (instancetype)initWithWindow:(UIWindow *)window;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

- (void)showAnimated:(BOOL)animated
      executingBlock:(dispatch_block_t)executing
             onQueue:(dispatch_queue_t)queue
          completion:(AXPracticalHUDCompletionBlock)completion;

- (void)showAnimated:(BOOL)animated
  executingBlockOnGQ:(dispatch_block_t)executing
          completion:(AXPracticalHUDCompletionBlock)completion;

- (void)showAnimated:(BOOL)animated
     executingMethod:(SEL)method
            toTarget:(id)target
          withObject:(id)object;

- (void)hideAnimated:(BOOL)animated
          afterDelay:(NSTimeInterval)delay
          completion:(AXPracticalHUDCompletionBlock)completion;
@end

@interface AXPracticalHUD(Shared)
+ (instancetype)sharedHUD;

- (void)showPieInView:(UIView *)view;
- (void)showProgressInView:(UIView *)view;
- (void)showColorfulProgressInView:(UIView *)view;
- (void)showTextInView:(UIView *)view;
- (void)showSimpleInView:(UIView *)view;
- (void)showErrorInView:(UIView *)view;
- (void)showSuccessInView:(UIView *)view;

- (void)showPieInView:(UIView *)view
                 text:(NSString *)text
               detail:(NSString *)detail
        configuration:(void(^)(AXPracticalHUD *HUD))configuration;
- (void)showProgressInView:(UIView *)view
                      text:(NSString *)text
                    detail:(NSString *)detail
             configuration:(void(^)(AXPracticalHUD *HUD))configuration;
- (void)showColorfulProgressInView:(UIView *)view
                              text:(NSString *)text
                            detail:(NSString *)detail
                     configuration:(void(^)(AXPracticalHUD *HUD))configuration;
- (void)showTextInView:(UIView *)view
                  text:(NSString *)text
                detail:(NSString *)detail
         configuration:(void(^)(AXPracticalHUD *HUD))configuration;
- (void)showSimpleInView:(UIView *)view
                    text:(NSString *)text
                  detail:(NSString *)detail
           configuration:(void(^)(AXPracticalHUD *HUD))configuration;
- (void)showErrorInView:(UIView *)view
                   text:(NSString *)text
                 detail:(NSString *)detail
          configuration:(void(^)(AXPracticalHUD *HUD))configuration;
- (void)showSuccessInView:(UIView *)view
                     text:(NSString *)text
                   detail:(NSString *)detail
            configuration:(void(^)(AXPracticalHUD *HUD))configuration;
@end

@interface AXPracticalHUD(Convenence)
+ (instancetype)showHUDInView:(UIView *)view animated:(BOOL)animated;
+ (BOOL)hideHUDInView:(UIView *)view animated:(BOOL)animated;
+ (NSInteger)hideAllHUDsInView:(UIView *)view animated:(BOOL)animated;
+ (instancetype)HUDInView:(UIView *)view;
+ (NSArray *)HUDsInView:(UIView *)view;
@end

@protocol AXPracticalHUDDelegate <NSObject>
@optional
- (void)HUDDidHidden:(AXPracticalHUD *)HUD;
@end