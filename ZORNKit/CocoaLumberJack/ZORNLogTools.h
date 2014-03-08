#import <Foundation/Foundation.h>
#import <CocoaLumberjack/DDFileLogger.h>

@interface ZORNLogTools : NSObject

+ (NSString *)getLogFilesContentWithMaxSize:(NSUInteger)maxSize fromFileLogger:(DDFileLogger *)fileLogger;

@end
