#import "ZORNJSONService.h"

@implementation ZORNJSONService

+ (id)objectForJSONData:(NSData *)jsonData
{
    NSError *jsonError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];
    if (!object) {
        NSLog(@"Could not deserialize json in -objectForJSONData, had error: %@", jsonError);
        return nil;
    } else {
        return object;
    }
}

+ (NSArray *)arrayForJSONData:(NSData *)jsonData
{
    id object = [self objectForJSONData:jsonData];
    if (![object isKindOfClass:[NSArray class]]) {
        NSLog(@"arrayForJSONData did not result in a instance of NSArray");
        return nil;
    } else {
        return object;
    }
}

+ (NSDictionary *)dictionaryForJSONData:(NSData *)jsonData
{
    id object = [self objectForJSONData:jsonData];
    if (![object isKindOfClass:[NSDictionary class]]) {
        NSLog(@"dictionaryForJSONData did not result in a instance of NSDictionary");
        return nil;
    } else {
        return object;
    }
}

+ (void)saveJSONData:(NSData *)jsonData filename:(NSString *)filename
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMddyyyyHHmmss"];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    NSString *finalFilename = [NSString stringWithFormat:@"%@.json", timestamp];
    if (filename) {
       finalFilename = [NSString stringWithFormat:@"%@-%@.json", filename, timestamp];
    }
    
    NSURL *path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    path = [path URLByAppendingPathComponent:finalFilename];
    if (![jsonData writeToURL:path atomically:YES]) {
        NSLog(@"saveJSONData:filename: failed");
    };
}

@end
