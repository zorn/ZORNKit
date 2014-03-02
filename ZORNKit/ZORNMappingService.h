#import <Foundation/Foundation.h>
#import "ZORNMappingServiceMappableObjectProtocol.h"

typedef void (^ZORNMappingServiceMapObjectsCustomMappingBlock) (NSObject *mappedObject, NSDictionary *valueDictionary);
typedef void (^ZORNMappingServiceMapObjectsCompletionHandler) (NSArray *objects, NSError *error);

@interface ZORNMappingService : NSObject

- (NSArray *)mapDictionaryCollection:(NSArray *)dictionaryCollection
             toObjectInstanseOfClass:(Class)objectClass
              inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       updateObjects:(BOOL)updateObjects
                        usingMapping:(NSDictionary *)mappingDictionary
           uniqueIdentifierAttribute:(NSString *)uniqueIdentifierAttribute
                  customMappingBlock:(ZORNMappingServiceMapObjectsCustomMappingBlock)customMappingBlock
                               error:(NSError **)returnError;

@end
