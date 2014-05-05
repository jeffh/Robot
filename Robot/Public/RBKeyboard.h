#import <Foundation/Foundation.h>


@class RBTimer;


/*! Wraps UIKit's keyboard implementation.
 */
@interface RBKeyboard : NSObject

+ (instancetype)mainKeyboard;
- (instancetype)initWithTimer:(RBTimer *)timer;
- (void)waitForKeyboardToBeOnScreen;
- (void)typeString:(NSString *)string instantly:(BOOL)instantly;
- (void)typeKey:(NSString *)keyCharacter instantly:(BOOL)instantly;
- (void)typeKeys:(NSArray *)keys instantly:(BOOL)instantly;

// instantly = YES
- (void)typeString:(NSString *)string;
- (void)typeKey:(NSString *)keyCharacter;
- (void)typeKeys:(NSArray *)keys;

@end

/*! A constant that represents the shift key.
 *
 *  You can use uppercase letters instead of this explictly.
 */
FOUNDATION_EXTERN const NSString *RBKeyShift;
/*! The key to view symbols and numbers.
 */
FOUNDATION_EXTERN const NSString *RBKeyMore;
/*! The key to switch keyboard
 */
FOUNDATION_EXTERN const NSString *RBKeyInternational;
/*! The key to dismiss the keyboard
 */
FOUNDATION_EXTERN const NSString *RBKeyDismiss;
/*! The key to activate Siri/Dictation
 */
FOUNDATION_EXTERN const NSString *RBKeyDictation;
/*! The delete key (to delete characters)
 */
FOUNDATION_EXTERN const NSString *RBKeyDelete;
