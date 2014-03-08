#import "ZORNLogTools.h"

@implementation ZORNLogTools

+ (NSString *)getLogFilesContentWithMaxSize:(NSUInteger)maxSize fromFileLogger:(DDFileLogger *)fileLogger
{
    NSMutableString *description = [NSMutableString string];
    
    if (fileLogger != nil) {
        NSArray *sortedLogFileInfos = [[fileLogger logFileManager] sortedLogFileInfos];
        NSUInteger count = [sortedLogFileInfos count];
        count--;
        // we start from the last one
        for (NSInteger index = count; index >= 0; index--) {
            DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:index];
            
            NSData *logData = [[NSFileManager defaultManager] contentsAtPath:[logFileInfo filePath]];
            if ([logData length] > 0) {
                NSString *result = [[NSString alloc] initWithBytes:[logData bytes] length:[logData length] encoding: NSUTF8StringEncoding];
                [description appendString:result];
            }
        }
        
        if ([description length] > maxSize) {
            description = (NSMutableString *)[description substringWithRange:NSMakeRange([description length]-maxSize-1, maxSize)];
        }
    }
    
    return description;
}

@end
