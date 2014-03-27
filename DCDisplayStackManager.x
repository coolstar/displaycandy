#import "DCDisplayStackManager.h"

static NSMutableArray *displayStacks;

%hook SBDisplayStack

- (id)init
{
	if ((self = %orig))
	{
		[displayStacks addObject:self];
	}

	return self;
}

%end

%ctor
{
	displayStacks = [[NSMutableArray alloc] init];
}

@implementation DCDisplayStackManager

static DCDisplayStackManager *sharedDisplayStackManager = nil;

+ (DCDisplayStackManager *)sharedManager
{
	@synchronized([DCDisplayStackManager class])
	{
		if (!sharedDisplayStackManager)
		{
			sharedDisplayStackManager = [[self alloc] init];
		}

		return sharedDisplayStackManager;
	}

	return nil;
}

- (SBDisplayStack *)preActivateDisplayStack
{
	return [displayStacks objectAtIndex:0];
}

- (SBDisplayStack *)activeDisplayStack
{
	return [displayStacks objectAtIndex:1];
}

- (SBDisplayStack *)suspendingDisplayStack
{
	return [displayStacks objectAtIndex:2];
}

- (SBDisplayStack *)suspendedEventOnlyDisplayStack
{
	return [displayStacks objectAtIndex:3];
}

@end
