#import <Foundation/Foundation.h>

#import "DCTypes.h"

@interface DCSettings : NSObject {
	NSDictionary *_settings;
}

+ (DCSettings *)sharedSettings;
- (BOOL)isEnabled;
- (DCTransition)transitionForMode:(DCTransitionMode)mode;
- (DCTransitionDirection)directionForMode:(DCTransitionMode)mode;
- (NSInteger)suckPointForMode:(DCTransitionMode)mode;
- (CGFloat)durationForMode:(DCTransitionMode)mode;
- (void)reload;

@end
