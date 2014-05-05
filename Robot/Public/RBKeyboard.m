#import "RBKeyboard.h"
#import "RBTimer.h"
#import <objc/runtime.h>


/////////////////////////// START Private APIs /////////////////////////
@interface UIKeyboard : UIView

+ (instancetype)activeKeyboard;
+ (instancetype)activeKeyboardForScreen:(id)arg1;
+ (void)clearActiveForScreen:(id)arg1;
+ (BOOL)isInHardwareKeyboardMode;
+ (BOOL)isOnScreen;
+ (BOOL)splitKeyboardEnabled;

- (id)_typeCharacter:(id)arg1 withError:(CGPoint)arg2 shouldTypeVariants:(BOOL)arg3 baseKeyForVariants:(BOOL)arg4;
- (BOOL)typingEnabled;
- (BOOL)canDismiss;

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

@end


@interface UIKeyboardSyntheticTouch : NSObject

- (void)setLocationInWindow:(CGPoint)point;
// not actually implemented by UIKit
- (void)_setLocationInWindow:(CGPoint)point resetPrevious:(BOOL)resetPrevious;

@end
/////////////////////////// END Private APIs /////////////////////////


@interface RBKeyboard ()

@property (nonatomic) RBTimer *timer;

@end


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
        RBKeyboard__ = [[RBKeyboard alloc] initWithTimer:[RBTimer defaultTimer]];
    });
    return RBKeyboard__;
}

- (instancetype)initWithTimer:(RBTimer *)timer
{
    self = [super init];
    self.timer = timer;
    return self;
}

- (void)waitForKeyboardToBeOnScreen
{
    [self.timer waitOrFailForName:@"keyboard to be on screen"
                   forAtMostTime:1
                           block:^BOOL{ return [self isOnScreen]; }];
}

- (void)typeString:(NSString *)string instantly:(BOOL)instantly
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type.");
    for (NSInteger i=0; i<string.length; i++) {
        NSString *character = [string substringWithRange:NSMakeRange(i, 1)];
        [self typeCharacter:character instantly:instantly];
    }
}

- (void)typeKey:(NSString *)key instantly:(BOOL)instantly
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type.");
    [self typeCharacter:key instantly:instantly];
}

- (void)typeKeys:(NSArray *)keys instantly:(BOOL)instantly
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type.");
    for (NSString *key in keys) {
        if ([self isKnownSpecialKey:key]) {
            [self typeCharacter:key instantly:instantly];
        } else {
            [self typeString:key instantly:instantly];
        }
    }
}

- (void)typeString:(NSString *)string
{
    [self typeString:string instantly:YES];
}

- (void)typeKey:(NSString *)key
{
    [self typeKey:key instantly:YES];
}

- (void)typeKeys:(NSArray *)keys
{
    [self typeKeys:keys instantly:YES];
}

- (void)dismiss
{
    if ([[self allKeyStrings] containsObject:RBKeyDismiss]) {
        [[self activeKeyboardImpl] dismissKeyboard];
    }
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

- (void)typeCharacter:(NSString *)character instantly:(BOOL)instantly
{
    [[self activeKeyboard] _typeCharacter:character withError:CGPointZero shouldTypeVariants:NO baseKeyForVariants:NO];
    // The keyboard performs operations asynchronously, so race conditions can occur if doing stuff too quickly
    if (instantly) {
        [[[self activeKeyboardImpl] taskQueue] waitUntilAllTasksAreFinished];
    } else {
        [self.timer waitForTime:0.17];
    }
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

