#import <UIKit/UIKit.h>

#define RB_EXPORT FOUNDATION_EXTERN __attribute__((overloadable))

RB_EXPORT NSArray *allViews(void);
RB_EXPORT NSArray *allViews(NSPredicate *predicate);
RB_EXPORT NSArray *allViews(NSPredicate *predicate, NSArray *viewsToSearch);
RB_EXPORT NSArray *allViews(NSPredicate *predicate, UIView *viewToSearch);
RB_EXPORT id theFirstView(void);
RB_EXPORT id theFirstView(NSPredicate *predicate);
RB_EXPORT id theFirstView(NSPredicate *predicate, NSArray *viewsToSearch);
RB_EXPORT id theFirstView(NSPredicate *predicate, UIView *viewToSearch);

RB_EXPORT NSPredicate *_all(NSArray *predicate);

#define matching(PREDICATES) (_all(@[PREDICATES]))

RB_EXPORT NSPredicate *ofExactClass(Class aClass);
RB_EXPORT NSPredicate *ofClass(Class aClass);
RB_EXPORT NSPredicate *withLabel(NSString *accessibilityLabel);
RB_EXPORT NSPredicate *withTraits(UIAccessibilityTraits traits);
RB_EXPORT NSPredicate *withVisibility(BOOL isVisible);
RB_EXPORT NSPredicate *withAccessibility(BOOL isAcessibilityView);
RB_EXPORT NSPredicate *onScreen(void);

RB_EXPORT NSPredicate *where(NSString *predicateFormat, ...);
RB_EXPORT NSPredicate *where(BOOL(^matcher)(UIView *view));

RB_EXPORT void tapOn(id view);
RB_EXPORT void tapOn(NSArray *views);
RB_EXPORT void tapOn(id view, CGPoint pointRelativeToView);
RB_EXPORT void tapOn(NSArray *views, CGPoint (^pointForView)(UIView *view));
