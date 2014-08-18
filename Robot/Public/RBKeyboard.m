#import "RBKeyboard.h"
#import "RBTouch.h"
#import "RBTimeLapse.h"
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

@end

@interface UIKBTree : NSObject
- (CGRect)frame;
- (NSString *)representedString;
- (BOOL)visible;
@end

@interface UIKBKeyplaneView : UIView
- (NSArray *)keys;
@end

@interface UIKeyboardLayout : UIView

@end

@interface UIKeyboardLayoutStar : UIKeyboardLayout

- (void)changeToKeyplane:(id)keyplane;
- (id)keyplaneForKey:(UIKBTree *)key;
- (UIKBTree *)baseKeyForString:(NSString *)character;
- (UIKBKeyplaneView *)currentKeyplaneView;

- (UIKBTree *)keyHitTestContainingPoint:(CGPoint)point;

@property(readonly) UIKeyboardTaskQueue * taskQueue;

@end

@interface UIKeyboardImpl : UIView

+ (instancetype)activeInstance;
- (void)dismissKeyboard;
- (void)cancelSplitTransition;
- (void)setSplitProgress:(double)progress;
- (void)_setNeedsCandidates:(BOOL)needsCandidates;

- (UIKeyboardLayoutStar *)_layout;

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
    // if we swizzle this class, we get keyboard entry for by the OS
    Class keyboardTouchClass = NSClassFromString(@"UIKeyboardSyntheticTouch");
    if (![keyboardTouchClass instancesRespondToSelector:@selector(_setLocationInWindow:resetPrevious:)]) {
        IMP setLocationAndReset = imp_implementationWithBlock(^(id that, CGPoint point, BOOL reset){ });
        Method setLocationMethod = class_getClassMethod(self, @selector(_setLocationInWindow:resetPrevious:));
        class_addMethod(keyboardTouchClass, @selector(_setLocationInWindow:resetPrevious:), setLocationAndReset, method_getTypeEncoding(setLocationMethod));
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

- (void)dismiss
{
    [RBTimeLapse disableAnimationsInBlock:^{
        [[self activeKeyboardImpl] dismissKeyboard];
    }];
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

- (void)typeCharacter:(NSString *)character
{
    // Historically, beta SDKs do not always support this.
    BOOL isSupportedSDK = [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending;
    if (isSupportedSDK) {
        [[self activeKeyboard] _typeCharacter:character withError:CGPointZero shouldTypeVariants:NO baseKeyForVariants:NO];
        [[[self activeKeyboardImpl] taskQueue] waitUntilAllTasksAreFinished];
    } else {
        UIKeyboardImpl *impl = [self activeKeyboardImpl];
        [impl _setNeedsCandidates:YES];

        UIKeyboardLayoutStar *layout = [impl _layout];
        UIKBTree *key = [layout baseKeyForString:character];
        [layout changeToKeyplane:[[impl _layout] keyplaneForKey:key]];
        CGRect frame = key.frame;
        CGPoint keyCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        CGPoint windowPoint = [layout convertPoint:keyCenter toView:nil];

        RBTouch *touch = [RBTouch touchAtPoint:windowPoint inWindow:layout.window];
        [touch updatePhase:UITouchPhaseEnded];
        [touch sendEvent];

        [[impl taskQueue] waitUntilAllTasksAreFinished];
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

