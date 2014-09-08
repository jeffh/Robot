#import <UIKit/UIKit.h>

@interface RBCellProxy : NSProxy

- (id)initWithGetterBlock:(id(^)())getCellBlock;

- (void)RB__makeVisible;

@end
