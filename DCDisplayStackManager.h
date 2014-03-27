#import <Foundation/Foundation.h>
#import "SpringBoard-Minimal.h"

@interface DCDisplayStackManager : NSObject

+ (DCDisplayStackManager *)sharedManager;
- (SBDisplayStack *)preActivateDisplayStack;
- (SBDisplayStack *)activeDisplayStack;
- (SBDisplayStack *)suspendingDisplayStack;
- (SBDisplayStack *)suspendedEventOnlyDisplayStack;

@end
