#import "RBMacros.h"

RB_INLINE NSArray *RBForceIntoNonEmptyArray(id objectOrArray) {
    if ([objectOrArray isKindOfClass:[NSArray class]]) {
        NSCAssert([objectOrArray count], @"Expected to receive an array with a view, but got nothing");
        return objectOrArray;
    } else if (objectOrArray) {
        return @[objectOrArray];
    } else {
        NSCAssert(objectOrArray, @"Expected to receive an array or view, but got nil");
        return nil;
    }
}

#define RBTIME(BLOCK) \
    static NSTimeInterval cumulativeDuration = 0; \
    NSDate *startDate = [NSDate date]; \
    (BLOCK); \
    NSDate *endDate = [NSDate date]; \
    NSTimeInterval delta = [endDate timeIntervalSinceDate:startDate]; \
    cumulativeDuration += delta; \
    NSLog(@"> culm duration: %f (+ %f)", cumulativeDuration, delta);
