#import "DCSettingsListController.h"

@implementation DCSettingsListController

- (id)specifiers
{
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"DisplayCandySettings" target:self] retain];
	}

	_launchAnimation = [self specifierForID:@"launchAnimation"];
	_launchAnimationDirection = [self specifierForID:@"launchAnimationDirection"];
	_launchAnimationSuckPoint = [self specifierForID:@"launchAnimationSuckPoint"];

	_suspendAnimation = [self specifierForID:@"suspendAnimation"];
	_suspendAnimationDirection = [self specifierForID:@"suspendAnimationDirection"];
	_suspendAnimationSuckPoint = [self specifierForID:@"suspendAnimationSuckPoint"];

	_switchAnimation = [self specifierForID:@"switchAnimation"];
	_switchAnimationDirection = [self specifierForID:@"switchAnimationDirection"];

	[self disableLaunchAnimationOptionsIfNeccessary];
	[self disableSuspendAnimationOptionsIfNeccessary];
	[self disableSwitchAnimationOptionsIfNeccessary];

	return _specifiers;
}

- (void)setAnimation:(id)animation specifier:(PSSpecifier *)specifier
{
	[self setPreferenceValue:animation specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([specifier isEqual:_launchAnimation])
		[self disableLaunchAnimationOptionsIfNeccessary];
	else if ([specifier isEqual:_suspendAnimation])
		[self disableSuspendAnimationOptionsIfNeccessary];
	else if ([specifier isEqual:_switchAnimation])
		[self disableSwitchAnimationOptionsIfNeccessary];
}

- (BOOL)shouldEnableDirectionSpecifierForAnimation:(NSNumber *)animation
{
	NSArray *animations = [[NSArray alloc] initWithObjects:@1, @2, @9, @10, @11, @13, nil];

	BOOL shouldEnable = [animations containsObject:animation];
	[animations release];

	return shouldEnable;
}

- (void)disableLaunchAnimationOptionsIfNeccessary
{
	BOOL shouldEnableDirection = [self shouldEnableDirectionSpecifierForAnimation:[self readPreferenceValue:_launchAnimation]];
	[_launchAnimationDirection setProperty:@(shouldEnableDirection) forKey:@"enabled"];
	[self reloadSpecifier:_launchAnimationDirection];

	BOOL shouldEnableSuckPoint = ([[self readPreferenceValue:_launchAnimation] intValue] == 6);
	[_launchAnimationSuckPoint setProperty:@(shouldEnableSuckPoint) forKey:@"enabled"];
	[self reloadSpecifier:_launchAnimationSuckPoint];

}

- (void)disableSuspendAnimationOptionsIfNeccessary
{
	BOOL shouldEnableDirection = [self shouldEnableDirectionSpecifierForAnimation:[self readPreferenceValue:_suspendAnimation]];
	[_suspendAnimationDirection setProperty:@(shouldEnableDirection) forKey:@"enabled"];
	[self reloadSpecifier:_suspendAnimationDirection];


	BOOL shouldEnableSuckPoint = ([[self readPreferenceValue:_suspendAnimation] intValue] == 6);
	[_suspendAnimationSuckPoint setProperty:@(shouldEnableSuckPoint) forKey:@"enabled"];
	[self reloadSpecifier:_suspendAnimationSuckPoint];

}

- (void)disableSwitchAnimationOptionsIfNeccessary
{
	BOOL shouldEnableDirection = [self shouldEnableDirectionSpecifierForAnimation:[self readPreferenceValue:_switchAnimation]];
	[_switchAnimationDirection setProperty:@(shouldEnableDirection) forKey:@"enabled"];
	[self reloadSpecifier:_switchAnimationDirection];

}

@end
