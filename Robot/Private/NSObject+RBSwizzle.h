#import <Foundation/Foundation.h>

@interface NSObject (RBSwizzle)

+ (void)RB_swizzleInstanceMethod:(SEL)selector movingOldTo:(SEL)oldSelector replacingWith:(SEL)newSelector;
+ (void)RB_replaceInstanceMethod:(SEL)selector withMethod:(SEL)replacementSelector;
+ (void)RB_swizzleClassMethod:(SEL)selector movingOldTo:(SEL)oldSelector replacingWith:(SEL)newSelector;
+ (void)RB_replaceClassMethod:(SEL)selector withMethod:(SEL)replacementSelector;

@end
