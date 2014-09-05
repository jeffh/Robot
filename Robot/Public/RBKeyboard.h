#import <UIKit/UIKit.h>
#import "RBConstants.h"
#import "RBMacros.h"


/*! Wraps UIKit's keyboard implementation. This provides an
 *  API to operate on UIKit's default US-based keyboard. Performing
 *  actions through this interface will properly go through text input
 *  flow (eg - UITextField delegate calls).
 *
 *  Other non-English keyboard are not tested and may or may not work.
 *  Custom keyboard are not tested with this and will probably NOT work with this.
 *
 *  Uses private APIs.
 *
 *  @warning be sure to dismiss the keyboard after usage to avoid
 *           dangling UI components that are awaiting keyboard input.
 */
RB_USES_PRIVATE_APIS
@interface RBKeyboard : NSObject

/*! Returns an instance to use UIKit's keyboard
 */
+ (instancetype)mainKeyboard;

/*! Returns YES if the keyboard is currently visible.
 */
- (BOOL)isVisible;

/*! Clear the text in the active text input. This simulates the user tapping
 *  on the "x" button next to text fields.
 *
 *  Calling this method doesn't verify the existance of the clear button.
 *
 *  For UITextFields, this will walk through the textFieldShouldClear: flow.
 */
- (void)clearText;

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
 *  Capitalization from the string is preserved, even if the textfield has
 *  special capitalization rules.
 */
- (void)typeKey:(NSString *)keyCharacter;

/*! Like -[RBKeyboard typeString:], but accepts an array of keys to press instead of
 *  a string. If the string is not an explicit key. Calls -[RBKeyboard typeString:]
 *  instead of -[RBKeyboard typeKey:].
 *
 *  Capitalization from the string is preserved, even if the textfield has
 *  special capitalization rules.
 */
- (void)typeKeys:(NSArray *)keys;

/*! Dismisses (or hides) the keyboard.
 *  The keyboard should be dismissed at teardown to avoid dangling delegates.
 */
- (void)dismiss;

@end

