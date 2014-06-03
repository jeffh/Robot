#import "RBKeyboard.h"
#import <objc/runtime.h>


/////////////////////////// START Private APIs /////////////////////////
@interface UIKeyboard : UIView

+ (instancetype)activeKeyboard;
+ (instancetype)activeKeyboardForScreen:(id)arg1;
+ (void)clearActiveForScreen:(id)arg1;
+ (BOOL)isInHardwareKeyboardMode;
+ (BOOL)isOnScreen;
+ (BOOL)splitKeyboardEnabled;

- (id)initWithDefaultSize;

- (id)_typeCharacter:(id)arg1 withError:(CGPoint)arg2 shouldTypeVariants:(BOOL)arg3 baseKeyForVariants:(BOOL)arg4;
- (BOOL)typingEnabled;
- (BOOL)canDismiss;
- (void)deactivate;
- (BOOL)isActive;
- (void)activate;

@end


@interface UIKeyboardTaskQueue : NSObject

- (void)waitUntilAllTasksAreFinished;
- (void)continueExecutionOnMainThread;

@end


@interface UIKeyboardImpl : UIView

+ (instancetype)activeInstance;
- (void)dismissKeyboard;
- (void)cancelSplitTransition;
- (void)setSplitProgress:(double)progress;

@property(readonly) UIKeyboardTaskQueue * taskQueue;
@property(nonatomic) id geometryDelegate;

@end


@interface UIKeyboardSyntheticTouch : NSObject

- (void)setLocationInWindow:(CGPoint)point;
// not actually implemented by UIKit
- (void)_setLocationInWindow:(CGPoint)point resetPrevious:(BOOL)resetPrevious;

@end
/////////////////////////// END Private APIs /////////////////////////


@implementation RBKeyboard

+ (void)initialize
{
    Class keyboardTouchClass = NSClassFromString(@"UIKeyboardSyntheticTouch");
    if (![keyboardTouchClass instancesRespondToSelector:@selector(_setLocationInWindow:resetPrevious:)]) {
        IMP setLocationAndReset = imp_implementationWithBlock(^(id that, CGPoint point, BOOL reset){ });
        Method m = class_getClassMethod(self, @selector(_setLocationInWindow:resetPrevious:));
        class_addMethod(keyboardTouchClass, @selector(_setLocationInWindow:resetPrevious:), setLocationAndReset, method_getTypeEncoding(m));
    }
}

+ (instancetype)mainKeyboard
{
    static RBKeyboard *RBKeyboard__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RBKeyboard__ = [[RBKeyboard alloc] init];
    });
    return RBKeyboard__;
}

- (void)typeString:(NSString *)string
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    for (NSInteger i=0; i<string.length; i++) {
        NSString *character = [string substringWithRange:NSMakeRange(i, 1)];
        [self typeCharacter:character];
    }
}

- (void)typeKey:(NSString *)key
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    [self typeCharacter:key];
}

- (void)typeKeys:(NSArray *)keys
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    for (NSString *key in keys) {
        if ([self isKnownSpecialKey:key]) {
            [self typeCharacter:key];
        } else {
            [self typeString:key];
        }
    }
}

- (BOOL)dismiss
{
    BOOL dismissed = NO;
    if ((dismissed = [[self allKeyStrings] containsObject:RBKeyDismiss])) {
        [self typeKey:RBKeyDismiss];
    }
    return dismissed;
}

#pragma mark - Private

- (UIKeyboard *)activeKeyboard
{
    return [UIKeyboard activeKeyboard];
}

- (UIKeyboardImpl *)activeKeyboardImpl
{
    return [UIKeyboardImpl activeInstance];
}

- (BOOL)isOnScreen
{
    return [[self activeKeyboard] typingEnabled];
}

- (void)typeCharacter:(NSString *)character
{
    [[self activeKeyboard] _typeCharacter:character withError:CGPointZero shouldTypeVariants:NO baseKeyForVariants:NO];
    [[[self activeKeyboardImpl] taskQueue] waitUntilAllTasksAreFinished];
}

- (BOOL)isKnownSpecialKey:(NSString *)key
{
    NSArray *specialKeys = @[RBKeyDelete, RBKeyDictation, RBKeyDismiss, RBKeyInternational, RBKeyMore, RBKeyShift];
    return [specialKeys containsObject:key];
}

- (NSArray *)allKeyStrings
{
    return [[self activeKeyboardImpl] valueForKeyPath:@"layout.keyplane.keys.representedString"];
}

@end

