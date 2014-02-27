#import "NSManagedObjectContext+ZORNCoreDataStackAdditions.h"

@implementation NSManagedObjectContext (ZORNCoreDataStackAdditions)

- (void)zorncds_saveForcefully
{
    NSError *error = nil;
    if (![self save:&error]) {
        NSLog(@"Could not save managed object context %@, had error: %@", self, error);
        abort();
    }
}

@end
