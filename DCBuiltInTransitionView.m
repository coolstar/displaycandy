#import <QuartzCore/QuartzCore.h>
#import "SpringBoard-Minimal.h"
#import "DCSettings.h"
#import "DCTypes.h"
#import "DCBuiltInTransitionView.h"
#include "DCFunctions.h"

@interface CAFilter : NSObject
+ (id)filterWithName:(NSString *)name;
@end

@interface DCBuiltInTransitionView ()
- (NSString *)stringForDirection:(DCTransitionDirection)direction;
- (CGPoint)homeButtonPointForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@implementation DCBuiltInTransitionView

- (void)animateWithDuration:(CFTimeInterval)duration
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:[self delegate]];
    [animation setValue:@([self mode]) forKey:@"mode"];
    [animation setType:[self type]];
    [animation setDuration:duration];

    if ([[self type] isEqualToString:@"cube"] || [[self type] isEqualToString:@"oglFlip"])
         [animation setSubtype:[self stringForDirection:[self direction]]];

    if ([[self type] isEqualToString:@"suckEffect"]) {
        CGSize viewSize = [self frame].size;
        CAFilter *suckFilter = [CAFilter filterWithName:@"suckEffect"];

        CGPoint suckPoint = ([[DCSettings sharedSettings] suckPointForMode:[self mode]] == 0)
                             ? [self homeButtonPointForInterfaceOrientation:[[UIApplication sharedApplication] activeInterfaceOrientation]]
                             : CGPointMake(viewSize.width / 2, viewSize.height / 2);

        [suckFilter setValue:[NSValue valueWithCGPoint:suckPoint] forKey:@"inputPosition"];        
        [animation setFilter:suckFilter];
    }

    [[self toView] setHidden:NO];
    [[self layer] addAnimation:animation forKey:nil];
}

- (void)dealloc
{
    [_type release];
    
    [super dealloc];
}

- (NSString *)stringForDirection:(DCTransitionDirection)direction
{
    switch (direction) {
        case DCTransitionDirectionLeft:
            return @"fromRight";
        case DCTransitionDirectionRight:
            return @"fromLeft";
        case DCTransitionDirectionUp:
            return @"fromTop";
        case DCTransitionDirectionDown:
            return @"fromBottom";
        default:
            return @"fromLeft";
    }
}

- (CGPoint)homeButtonPointForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGSize viewSize = [self frame].size;    

    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            return CGPointMake(viewSize.width / 2, viewSize.height);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGPointMake(viewSize.width / 2, 0);
        case UIInterfaceOrientationLandscapeLeft:
            return CGPointMake(0, viewSize.height / 2);
        case UIInterfaceOrientationLandscapeRight:
            return CGPointMake(viewSize.width, viewSize.height / 2);
        default:
            return CGPointZero;
    }
}

@end
