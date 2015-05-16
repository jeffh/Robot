#import "RBKeyboard.h"
#import "RBTouch.h"
#import "RBTimeLapse.h"
#import <objc/runtime.h>


/////////////////////////// START Private APIs /////////////////////////
@interface UIPeripheralHost : NSObject
+ (instancetype)sharedInstance;
-(void)createHostViewIfNeeded;
-(BOOL)isOnScreen;
-(BOOL)isOffScreen;
-(void)manualKeyboardWasOrderedIn:(id)anIn;
-(void)orderInAutomatic;
-(void)orderInAutomaticSkippingAnimation;
-(void)orderInAutomaticFromDirection:(int)direction withDuration:(double)duration;
-(void)orderOutAutomatic;
-(void)orderOutAutomaticSkippingAnimation;
-(void)orderOutAutomaticToDirection:(int)direction withDuration:(double)duration;
-(void)prepareForRotationToOrientation:(int)orientation;
-(void)rotateToOrientation:(int)orientation;
-(void)finishRotation;
-(void)prepareForRotationOfKeyboard:(id)keyboard toOrientation:(int)orientation;
-(void)rotateKeyboard:(id)keyboard toOrientation:(int)orientation;
-(void)finishRotationOfKeyboard:(id)keyboard;
-(void)completeCurrentTransitionIfNeeded;

-(void)setAutomaticAppearanceEnabledForMail:(BOOL)mail;
-(void)forceOrderInAutomatic;
-(void)forceOrderOutAutomatic;
-(void)forceOrderInAutomaticAnimated:(BOOL)automaticAnimated;
-(void)forceOrderOutAutomaticAnimated:(BOOL)animated;
-(void)forceOrderInAutomaticFromDirection:(int)direction withDuration:(double)duration;
-(void)forceOrderOutAutomaticToDirection:(int)direction withDuration:(double)duration;
-(id)containerWindow;
-(id)automaticKeyboard;
-(BOOL)hasCustomInputView;
-(BOOL)isHostingActiveImpl;
-(void)setPeripheralToolbarFrameForHostWidth:(float)hostWidth;
-(void)setPeripheralFrameForHostBounds:(CGRect)hostBounds;
-(CGSize)totalPeripheralSizeForOrientation:(int)orientation;
-(void)orderInWithAnimation:(BOOL)animation;
-(void)orderInWithAnimation:(BOOL)animation fromDirection:(int)direction duration:(double)duration;
-(void)orderOutWithAnimation:(BOOL)animation;
-(void)syncToExistingAnimations;
-(void)resetOrderOutDuration:(double)duration;
-(void)resetOrderOutDuration:(double)duration toCenter:(CGPoint)center;
-(BOOL)_isSuppressedByManualKeyboard;
-(void)orderOutWithAnimation:(BOOL)animation toDirection:(int)direction duration:(double)duration;
-(void)keyboardAutomaticWillOrderIn:(id)keyboardAutomatic context:(void*)context;
-(void)keyboardAutomaticOrderIn:(id)anIn finished:(id)finished;
-(void)keyboardAutomaticOrderOut:(id)anOut finished:(id)finished;
@end

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

@interface UIKBKeyView : UIView
- (void)activateKeys;
- (void)deactivateKeys;
@end

@interface UIKBKeyplaneView : UIView
- (NSArray *)keys;
- (UIKBKeyView *)viewForKey:(UIKBTree *)key;
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
- (void)completeAddInputString:(NSString *)key;
- (void)clearAutocorrectPromptTimer;
- (void)removeAutocorrectPromptAndCandidateList;
- (void)_setAutocorrects:(BOOL)enabled;
- (BOOL)usesAutocorrectionLists;
- (void)setAutocorrectSpellingEnabled:(BOOL)enabled;

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
    [[UIPeripheralHost sharedInstance] syncToExistingAnimations];
    return [[UIPeripheralHost sharedInstance] isOnScreen];
}

- (void)clearText
{
    [self debugLog:@"%@", NSStringFromSelector(_cmd)];
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    UIKeyboardImpl *impl = [self activeKeyboardImpl];
    [impl handleClear];
    [[impl taskQueue] waitUntilAllTasksAreFinished];
}

- (void)typeString:(NSString *)string
{
    [self debugLog:@"%@\"%@\"", NSStringFromSelector(_cmd), string];
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    for (NSInteger i = 0; i < string.length; i++) {
        NSString *character = [string substringWithRange:NSMakeRange(i, 1)];
        [self typeCharacter:character];
    }
}

- (void)typeKey:(NSString *)key
{
    [self debugLog:@"%@\"%@\"", NSStringFromSelector(_cmd), key];
    NSAssert([self activeKeyboard], @"Keyboard is not active. Cannot type. Did you forget to add the views into a UIWindow?");
    [self typeCharacter:key];
}

- (void)typeKeys:(NSArray *)keys
{
    [self debugLog:@"%@%@", NSStringFromSelector(_cmd), keys];
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
    [self debugLog:@"%@", NSStringFromSelector(_cmd)];
    [[UIPeripheralHost sharedInstance] orderOutAutomaticSkippingAnimation];
}

#pragma mark - Private

- (void)debugLog:(NSString *)format, ...
{
    if (self.debug) {
        va_list args;
        va_start(args, format);
        NSString *message = [NSString stringWithFormat:@"%@ [RBKeyboard]: %@",
                             [NSDate date],
                             [[NSString alloc] initWithFormat:format arguments:args]];
        printf("%s\n", message.UTF8String);
        va_end(args);
    }
}

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
    [[UIPeripheralHost sharedInstance] syncToExistingAnimations];
    [self debugLog:@"%@\"%@\"", NSStringFromSelector(_cmd), character];
    UIKeyboardImpl *keyboardImpl = [self activeKeyboardImpl];
    UIKeyboardLayoutStar *layout = [keyboardImpl _layout];

    UIKBTree *key = [layout baseKeyForString:character];
    NSAssert(key, @"Couldn't find key for string: %@", key);
    id keyplane = [[keyboardImpl _layout] keyplaneForKey:key];
    if (keyplane != [layout currentKeyplane]) {
        [layout changeToKeyplane:keyplane];
        [self debugLog:@" -> Changing Keyplane: %@", [keyplane name]];
        NSAssert([layout currentKeyplane] == keyplane, @"Failed to find key: %@", key);
    } else {
        [self debugLog:@" -> Current Keyplane: %@", [keyplane name]];
    }

    [keyboardImpl addInputString:character withFlags:2];
//    if ([[key representedString] isEqual:character]) {
//        CGRect frame = key.frame;
//        CGPoint keyCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
//        CGPoint referencePoint = [layout convertPoint:keyCenter toView:nil];
//
//        [self debugLog:@" -> Tapping Key (%@ -> %@)", NSStringFromCGPoint(keyCenter), NSStringFromCGPoint(referencePoint)];
//
//        [RBTouch tapOnView:layout.window atPoint:referencePoint];
//    } else {
//        [self debugLog:@" -> Insert Accented Character"];
//        [keyboardImpl addInputString:character withFlags:2];
//    }
    [[keyboardImpl taskQueue] waitUntilAllTasksAreFinished];
    [keyboardImpl clearAutocorrectPromptTimer];
    // iOS 8+
    if ([keyboardImpl respondsToSelector:@selector(removeAutocorrectPromptAndCandidateList)]) {
        [keyboardImpl removeAutocorrectPromptAndCandidateList];
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

