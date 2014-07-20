#import <UIKit/UIKit.h>
#import "RBConstants.h"


/*! Wraps UIKit's keyboard implementation.
 *
 *  Uses private APIs.
 */
@interface RBKeyboard : NSObject

/*! Returns an instance to use UIKit's keyboard
 */
+ (instancetype)mainKeyboard;

/*! Attempts to type the given string to whatever input that has keyboard focus.
 *  Capitalization from the string is preserved, even if the textfield has
 *  special capitalization rules.
 *
 *  Not all keys can be entered via this method. See RBConstants.h for some
 *  constants of specific strings that cannot be given to this method. Use
 *  -[RBKeyboard typeKey:] instead.
 *
 *  @see -[RBKeyboard typeKey:]
 */
- (void)typeString:(NSString *)string;

/*! Attempts to type a given character to whatever input that has keyboard focus.
 *  Keys are also strings.
 */
- (void)typeKey:(NSString *)keyCharacter;

/*! Like -[RBKeyboard typeString:], but accepts an array of keys to press instead of
 *  a string. If the string is not an explicit key. Calls -[RBKeyboard typeString:]
 *  instead of -[RBKeyboard typeKey:].
 */
- (void)typeKeys:(NSArray *)keys;

/*! Dismisses (or hides) the keyboard. A special button that is available on iPads.
 */
- (void)dismiss;

@end

