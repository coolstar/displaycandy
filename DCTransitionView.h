#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DCTypes.h"

@interface DCTransitionView : UIView

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *applicationIdentifier;
@property (nonatomic, assign) DCTransitionMode mode;
@property (nonatomic, assign) DCTransitionDirection direction;
@property (nonatomic, retain) UIView *fromView;
@property (nonatomic, retain) UIView *toView;

- (void)animateWithDuration:(CFTimeInterval)duration;

@end
