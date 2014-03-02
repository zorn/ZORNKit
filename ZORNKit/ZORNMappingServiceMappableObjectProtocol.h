#import <Foundation/Foundation.h>

@protocol ZORNMappingServiceMappableObjectProtocol <NSObject>

+ (NSDateFormatter *)zorn_mappingDateFormatterRelativeToAttributeOfKey:(NSString *)key;
+ (NSDictionary *)zorn_JSONToModelAttributeMapping;

@end
