#import "UIStoryboardSegue+ZORNAdditions.h"

@implementation UIStoryboardSegue (ZORNAdditions)

- (UIViewController *)zorn_destinationViewControllerOfClass:(Class)someClass
{
    UIViewController *vc = [self destinationViewController];
    NSAssert([vc isKindOfClass:someClass], @"class is not expected class");
    return vc;
}

@end
