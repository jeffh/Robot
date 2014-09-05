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

- (void)addTask:(void(^)(id))task;
- (void)waitUntilAllTasksAreFinished;
- (void)performTask:(id)task;
- (void)performTaskOnMainThread:(id)task waitUntilDone:(BOOL)done;

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

- (void)touchUp:(id)event;
- (void)commitTouches:(id)touches;

@end

@interface UIKeyboardLayoutStar : UIKeyboardLayout

- (void)changeToKeyplane:(id)keyplane;
- (id)keyplaneForKey:(UIKBTree *)key;
- (id)currentKeyplane;
- (UIKBTree *)baseKeyForString:(NSString *)character;
- (UIKBKeyplaneView *)currentKeyplaneView;
- (id)simulateTouchForCharacter:(id)arg1
                    errorVector:(CGPoint)arg2
             shouldTypeVariants:(BOOL)arg3
             baseKeyForVariants:(BOOL)arg4;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (UIKBTree *)keyHitTestContainingPoint:(CGPoint)point;

@property(readonly) UIKeyboardTaskQueue * taskQueue;

@end

@interface UIKeyboardImpl : UIView

+ (instancetype)activeInstance;
- (void)dismissKeyboard;
- (void)cancelSplitTransition;
- (void)setSplitProgress:(double)progress;
- (void)_setNeedsCandidates:(BOOL)needsCandidates;
- (void)handleClear;
- (id)delegateAsResponder;
- (id)delegate;
- (void)addInputString:(NSString *)key withFlags:(int)flags;

- (UIKeyboardLayoutStar *)_layout;

@property(readonly) UIKeyboardTaskQueue * taskQueue;
@property(nonatomic) id geometryDelegate;

@end


/////////////////////////// END Private APIs /////////////////////////


@implementation RBKeyboard

+ (instancetype)mainKeyboard
{
    static RBKeyboard *RBKeyboard__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RBKeyboard__ = [[RBKeyboard alloc] init];
    });
    return RBKeyboard__;
}

- (BOOL)isVisible {
    UIKeyboardImpl *impl = [self activeKeyboardImpl];
    if ([impl respondsToSelector:@selector(delegateAsResponder)]) {
        return [impl delegateAsResponder] != nil;
    }
    if ([impl respondsToSelector:@selector(delegate)]) {
        return [impl delegate] != nil;
    }
    return [[self activeKeyboardImpl] delegate] != nil;
}

- (void)clearText
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    UIKeyboardImpl *impl = [self activeKeyboardImpl];
    [impl handleClear];
    [[impl taskQueue] waitUntilAllTasksAreFinished];
}

- (void)typeString:(NSString *)string
{
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    for (NSInteger i = 0; i < string.length; i++) {
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
    UIKeyboardImpl *keyboardImpl = [self activeKeyboardImpl];
    UIKeyboardLayoutStar *layout = [keyboardImpl _layout];

    UIKBTree *key = [layout baseKeyForString:character];
    NSAssert(key, @"Couldn't find key for string: %@", key);
    id keyplane = [[keyboardImpl _layout] keyplaneForKey:key];
    if (keyplane != [layout currentKeyplane]) {
        [layout changeToKeyplane:keyplane];
        NSAssert([layout currentKeyplane] == keyplane, @"Failed to find key: %@", key);
    }

    if ([[key representedString] isEqual:character]) {
        CGRect frame = key.frame;
        CGPoint keyCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        CGPoint windowPoint = [layout convertPoint:keyCenter toView:nil];

        UIView *touchedView = [layout.window hitTest:windowPoint withEvent:nil];
        RBTouch *touch = [[RBTouch alloc] initWithWindowPoint:windowPoint
                                                        phase:UITouchPhaseBegan
                                                       inView:touchedView
                                                  atTimestamp:CFAbsoluteTimeGetCurrent()];

        // instead of going through UIWindow, pass the touch to the layout directly to be slightly faster
        // this is the same tactic that UIKit's simulated touches do
        [layout touchesBegan:[NSSet setWithObject:touch] withEvent:nil];
        [touch updatePhase:UITouchPhaseEnded];
        [layout touchesEnded:[NSSet setWithObject:touch] withEvent:nil];
    } else {
        // accented characters
        [keyboardImpl addInputString:character withFlags:2];
    }

    [[keyboardImpl taskQueue] waitUntilAllTasksAreFinished];
    [RBTimeLapse resetMainRunLoop];
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

