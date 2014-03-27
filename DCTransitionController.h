#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SpringBoard-Minimal.h"

#import "DCTypes.h"
#import "DCTransitionDelegate.h"
#import "DCTransitionView.h"

@interface DCTransitionController : NSObject {
	DCTransitionView *_transitionView;
}

@property (nonatomic, assign) id<DCTransitionDelegate> delegate;
@property (nonatomic, retain) SBApplication *application;
@property (nonatomic, readonly, retain) UIView *view;
@property (nonatomic, assign) DCTransitionMode mode;
@property (nonatomic, retain) UIView *fromView;
@property (nonatomic, retain) UIView *toView;

- (void)beginTransition:(NSInteger)transition;
- (void)endTransition;

@end
