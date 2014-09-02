#import <Foundation/Foundation.h>


/*! A lazily evaluated array specifically design for gather views. Usually instances are created
 *  using the Robot DSL functions.
 *
 *  Can return derived copies of itself for finder grain scoping of the results.
 *
 */
@interface RBViewQuery : NSArray

- (instancetype)initWithMatchingPredicate:(NSPredicate *)predicate
                              inRootViews:(NSArray *)rootViews
                          sortDescriptors:(NSArray *)sortDesciptors;

@property (nonatomic, readonly) RBViewQuery *(^subrange)(NSRange subrange);
@property (nonatomic, readonly) RBViewQuery *(^inside)(UIView *rootView);
@property (nonatomic, readonly) RBViewQuery *(^insideOneOf)(NSArray *rootViews);
@property (nonatomic, readonly) RBViewQuery *(^sortedBy)(NSArray *sortDescriptors);

// may be useful if you're using a debugger and the property blocks above do not work
- (instancetype)queryOfRange:(NSRange)subrange;
- (instancetype)queryWithRootView:(UIView *)view;
- (instancetype)querySortedBy:(NSArray *)sortDescriptors;

@end
