#import "NSURL+ZORNKitAdditions.h"

@implementation NSURL (ZORNKitAdditions)

+ (NSURL *)zorn_applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
