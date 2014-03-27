#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DCTransitionView.h"

@interface DCSwingTransitionView : DCTransitionView {
	UIView *_fromViewContainer;
	UIView *_toViewContainer;
}

@end
