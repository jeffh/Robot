#import "RBViewQuery.h"
#import "RBAccessibility.h"
#import "NSObject+RBKVCUndefined.h"


@interface RBViewQuery ()
@property (nonatomic) NSPredicate *predicate;
@property (nonatomic) NSArray *rootViews;
@property (nonatomic) NSArray *sortDescriptors;
@property (nonatomic) NSRange range;

@property (nonatomic) NSArray *cache;
@end


@implementation RBViewQuery

+ (instancetype)queryFromViewOrArrayOfViews:(id)viewOrArrayOfViews
{
    RBViewQuery *query = [[self alloc] initWithMatchingPredicate:nil inRootViews:nil sortDescriptors:nil];
    if ([viewOrArrayOfViews isKindOfClass:[UIView class]]) {
        viewOrArrayOfViews = @[viewOrArrayOfViews];
    }
    query->_cache = [NSArray arrayWithArray:viewOrArrayOfViews];
    return query;
}

- (instancetype)initWithMatchingPredicate:(NSPredicate *)predicate
                              inRootViews:(NSArray *)rootViews
                          sortDescriptors:(NSArray *)sortDesciptors
{
    self = [super init];
    if (self) {
        self.predicate = predicate;
        self.rootViews = rootViews;
        self.sortDescriptors = sortDesciptors;
        self.range = NSMakeRange(0, NSNotFound);
        self.cache = nil;
    }
    return self;
}

#pragma mark - DSL

- (RBViewQuery *(^)(NSRange))subrange
{
    return ^RBViewQuery *(NSRange range) {
        RBViewQuery *query = [self mutableCopy];
        query.range = range;
        return query;
    };

}

- (RBViewQuery *(^)(UIView *))inside
{
    return ^RBViewQuery *(UIView *rootView) {
        RBViewQuery *query = [self mutableCopy];
        query.rootViews = @[rootView];
        return query;
    };
}

- (RBViewQuery *(^)(NSArray *))insideOneOf
{
    return ^RBViewQuery *(NSArray *rootViews) {
        RBViewQuery *query = [self mutableCopy];
        query.rootViews = rootViews;
        return query;
    };
}

- (RBViewQuery *(^)(NSArray *))sortedBy
{
    return ^RBViewQuery *(NSArray *sortDescriptors) {
        RBViewQuery *query = [self mutableCopy];
        query.sortDescriptors = sortDescriptors;
        return query;
    };
}

- (instancetype)queryOfRange:(NSRange)subrange
{
    return self.subrange(subrange);
}

- (instancetype)queryWithRootView:(UIView *)view
{
    return self.inside(view);
}

- (instancetype)querySortedBy:(NSArray *)sortDescriptors
{
    return self.sortedBy(sortDescriptors);
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    RBViewQuery *query = [[[self class] allocWithZone:zone] initWithMatchingPredicate:[self.predicate copy]
                                                                          inRootViews:[self.rootViews copy]
                                                                      sortDescriptors:[self.sortDescriptors copy]];
    query.range = self.range;
    query.cache = _cache;
    query.range = self.range;
    return query;
}

#pragma mark - NSArray

- (NSUInteger)count
{
    return MIN(self.range.length, self.cache.count);
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.cache objectAtIndex:index + self.range.location];
}

#pragma mark - Private

- (NSArray *)cache
{
    if (!_cache) {
        [UIView RB_allowUndefinedKeysInBlock:^{
            NSArray *views = [[RBAccessibility sharedInstance] subviewsOfViews:self.rootViews
                                                           satisfyingPredicate:self.predicate];
            _cache = [views sortedArrayUsingDescriptors:self.sortDescriptors];
        }];
    }
    return _cache;
}

@end
