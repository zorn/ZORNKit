#import <Foundation/Foundation.h>

typedef void (^ZORNMappingServiceMapObjectsCustomMappingBlock) (NSObject *mappedObject, NSDictionary *valueDictionary);
typedef void (^ZORNMappingServiceMapObjectsCompletionHandler) (NSArray *objects, NSError *error);

@interface ZORNMappingService : NSObject

- (void)mapDictionaryCollection:(NSArray *)dictionaryCollection toObjectInstanseOfClass:(Class)objectClass inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext updateObjects:(BOOL)updateObjects usingMapping:(NSDictionary *)mappingDictionary uniqueIdentifierAttribute:(NSString *)uniqueIdentifierAttribute completionHandler:(ZORNMappingServiceMapObjectsCompletionHandler)completionHandler;

- (void)mapDictionaryCollection:(NSArray *)dictionaryCollection toObjectInstanseOfClass:(Class)objectClass inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext updateObjects:(BOOL)updateObjects usingMapping:(NSDictionary *)mappingDictionary uniqueIdentifierAttribute:(NSString *)uniqueIdentifierAttribute customMappingBlock:(ZORNMappingServiceMapObjectsCustomMappingBlock)customMappingBlock completionHandler:(ZORNMappingServiceMapObjectsCompletionHandler)completionHandler;


@end
