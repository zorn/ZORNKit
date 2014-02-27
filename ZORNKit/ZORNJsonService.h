#import <Foundation/Foundation.h>

@interface ZORNJSONService : NSObject

// returns an array representation of the jsonData submitted. Will return nil if data was of a non-array
+ (NSArray *)arrayForJSONData:(NSData *)jsonData;

// returns a dictionary representation of the jsonData submitted. Will return nil if data was of a non-dictionary
+ (NSDictionary *)dictionaryForJSONData:(NSData *)jsonData;

// saves the JSON data to disk, in the documents folder. filename-timestamp.json
+ (void)saveJSONData:(NSData *)jsonData filename:(NSString *)filename;

@end
