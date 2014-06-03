#import <UIKit/UIKit.h>
#import "RBConstants.h"


/*! Wraps UIKit's keyboard implementation.
 */
@interface RBKeyboard : NSObject

+ (instancetype)mainKeyboard;
- (void)typeString:(NSString *)string;
- (void)typeKey:(NSString *)keyCharacter;
- (void)typeKeys:(NSArray *)keys;

- (BOOL)dismiss;

@end

