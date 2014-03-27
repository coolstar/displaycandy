#import <UIKit/UIKit.h>
#import "SpringBoard-Minimal.h"
#import "DCTransitionDelegate.h"

@interface DCAppToAppWrapperView : SBAppToAppTransitionView <DCTransitionDelegate>
@property(nonatomic, assign) DCTransition transition;
@end
