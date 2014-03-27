#import <UIKit/UIKit.h>

@interface PSSpecifier : NSObject
- (void)setProperty:(id)property forKey:(NSString *)key;
@end

@interface PSViewController : UIViewController 
- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
@end

@interface PSListController : PSViewController {
	NSArray *_specifiers;
}

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(PSListController *)target;
- (PSSpecifier *)specifierForID:(NSString *)id;
- (void)reloadSpecifier:(PSSpecifier *)specifier;

@end

