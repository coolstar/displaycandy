#import "DCSettings.h"
#import "DCTypes.h"

static NSString * const kSettingsPlistPath = @"/User/Library/Preferences/com.protosphere.displaycandy.plist";

@interface DCSettings ()
- (DCTransition)_transitionForMode:(DCTransitionMode)mode processRandom:(BOOL)processRandom;
@end

@implementation DCSettings

+ (DCSettings *)sharedSettings
{
    @synchronized([DCSettings class]) {
		static DCSettings *sharedSettings = nil;

        if (!sharedSettings) {
            sharedSettings = [[self alloc] init];
        }

        return sharedSettings;
    }

    return nil;
}

- (id)init
{
	self = [super init];

    if (self) {
		[self reload];
    }

    return self;
}

- (BOOL)isEnabled
{
    return ([_settings objectForKey:@"enabled"] ? [[_settings objectForKey:@"enabled"] boolValue] : YES);
}

- (DCTransition)transitionForMode:(DCTransitionMode)mode
{
    DCTransition transition = [self _transitionForMode:mode processRandom:YES];

    return transition;
}

- (DCTransition)_transitionForMode:(DCTransitionMode)mode processRandom:(BOOL)processRandom
{
    static DCTransition validSwitchModes[11] = {DCTransitionDefault,
												DCTransitionCube,
												DCTransitionFlip,
												DCTransitionPageCurl,
												DCTransitionPageUncurl,
												DCTransitionRipple,
                                                DCTransitionFade,
												DCTransitionCover,
												DCTransitionReveal,
												DCTransitionPush,
												DCTransitionCameraIris};

    DCTransition transition;

    switch (mode) {
        case DCTransitionModeLaunch:
            transition = ([_settings objectForKey:@"launchAnimation"] ? [[_settings objectForKey:@"launchAnimation"] intValue] : DCTransitionSwing);
            break;
        case DCTransitionModeSuspend:
            transition = ([_settings objectForKey:@"suspendAnimation"] ? [[_settings objectForKey:@"suspendAnimation"] intValue] : DCTransitionSwing);
            break;
        case DCTransitionModeSwitch:
            transition = ([_settings objectForKey:@"switchAnimation"] ? [[_settings objectForKey:@"switchAnimation"] intValue] : DCTransitionRipple);
            break;
        default:
            transition = DCTransitionDefault;
    }

    if ((transition == DCTransitionRandom) && processRandom) {
        unsigned i;
        unsigned i_max = (DCTransitionModeSwitch ? 10 : 13);

        i = arc4random_uniform(i_max);

        if (mode == DCTransitionModeSwitch)
            transition = validSwitchModes[i];
        else
            transition = i;
    }

    return transition;
}

- (DCTransitionDirection)directionForMode:(DCTransitionMode)mode
{
    DCTransition transition = [self _transitionForMode:mode processRandom:NO];    
    DCTransitionDirection direction;

    switch (mode) {
        case DCTransitionModeLaunch:
            direction = ([_settings objectForKey:@"launchAnimationDirection"] ? [[_settings objectForKey:@"launchAnimationDirection"] intValue] : DCTransitionDirectionRight);
            break;
        case DCTransitionModeSuspend:
            direction = [[_settings objectForKey:@"suspendAnimationDirection"] intValue];
            break;
        case DCTransitionModeSwitch:
            direction = ([_settings objectForKey:@"switchAnimationDirection"] ? [[_settings objectForKey:@"switchAnimationDirection"] intValue] : DCTransitionDirectionRight);
			break;
        default:
            direction = DCTransitionDirectionRight;
    }

    if (transition == DCTransitionRandom) {
        unsigned i = arc4random_uniform(3);
        direction = i;
    }

    return direction;
}

- (NSInteger)suckPointForMode:(DCTransitionMode)mode
{
    switch (mode) {
        case DCTransitionModeLaunch:
            return [[_settings objectForKey:@"launchAnimationSuckPoint"] intValue];
        case DCTransitionModeSuspend:
            return [[_settings objectForKey:@"suspendAnimationSuckPoint"] intValue];
        default:
            return 0;
    }
}

- (CGFloat)durationForMode:(DCTransitionMode)mode
{
    switch (mode) {
        case DCTransitionModeLaunch:
            return ([_settings objectForKey:@"launchAnimationDuration"] ? [[_settings objectForKey:@"launchAnimationDuration"] floatValue] : 0.5f);
        case DCTransitionModeSuspend:
            return ([_settings objectForKey:@"suspendAnimationDuration"] ? [[_settings objectForKey:@"suspendAnimationDuration"] floatValue] : 0.5f);
        case DCTransitionModeSwitch:
            return ([_settings objectForKey:@"switchAnimationDuration"] ? [[_settings objectForKey:@"switchAnimationDuration"] floatValue] : 0.5f);
        default:
            return 0;
    }
}

- (void)reload
{
    [_settings release];
    _settings = [[NSDictionary alloc] initWithContentsOfFile:kSettingsPlistPath];
}

@end
