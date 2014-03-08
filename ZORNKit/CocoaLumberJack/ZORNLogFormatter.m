#import "ZORNLogFormatter.h"

@interface ZORNLogFormatter ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation ZORNLogFormatter

- (id)init
{
    self = [super init];
    if(self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [self.dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag) {
        case LOG_FLAG_ERROR: {
            logLevel = @"Error\t";
            break;
        }
        case LOG_FLAG_WARN: {
            logLevel = @"Warning\t";
            break;
        }
        default: {
            logLevel = @"\t\t";
            break;
        }
    }
    
    NSString *messageTimestamp = [self.dateFormatter stringFromDate:(logMessage->timestamp)];
    NSString *logMsg = logMessage->logMsg;
    int lineNumber = logMessage->lineNumber;
    return [NSString stringWithFormat:@"%@ %@ [%@ %@]:%d # %@", logLevel, messageTimestamp, logMessage.fileName, logMessage.methodName, lineNumber, logMsg];
}

@end