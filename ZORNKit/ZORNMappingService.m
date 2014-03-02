#import "ZORNMappingService.h"
#import "ZORNCoreDataStack.h"

#define SAVE_JSON YES

@interface ZORNMappingService ()

@property (strong, nonatomic) NSArray *dictionaryCollection;
@property (assign, nonatomic) Class objectClass;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) BOOL updateObjects;
@property (strong, nonatomic) NSString *uniqueIdentifierAttribute;
@property (strong, nonatomic) NSDictionary *mappingDictionary;

@end

@implementation ZORNMappingService

- (NSArray *)mapDictionaryCollection:(NSArray *)dictionaryCollection
        toObjectInstanseOfClass:(Class)objectClass
         inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  updateObjects:(BOOL)updateObjects usingMapping:(NSDictionary *)mappingDictionary
      uniqueIdentifierAttribute:(NSString *)uniqueIdentifierAttribute
             customMappingBlock:(ZORNMappingServiceMapObjectsCustomMappingBlock)customMappingBlock
                          error:(NSError **)returnError
{
    self.dictionaryCollection = dictionaryCollection;
    self.objectClass = objectClass;
    self.managedObjectContext = managedObjectContext;
    self.updateObjects = updateObjects;
    self.uniqueIdentifierAttribute = uniqueIdentifierAttribute;
    self.mappingDictionary = mappingDictionary;
    
    NSError *coreDataErrors = nil;
    coreDataErrors = [self validateCoreDataSystems];
    if (coreDataErrors) {
        *returnError = coreDataErrors;
        return nil;
    }
    
    NSMutableArray *importedObjects = [[NSMutableArray alloc] init];
    
    // for each object inside of the collection
    for (NSDictionary *collectionObject in dictionaryCollection) {
        
        // create or fetch a new instance of object
        NSArray *allKeys = [self.mappingDictionary allKeys];
        NSString *key = nil;
        for (NSString *someKey in allKeys) {
            if ([self.mappingDictionary valueForKey:someKey] == self.uniqueIdentifierAttribute) {
                key = someKey;
                break;
            }
        }
        
        id object = [self newOrFoundObjectForUniqueIdentifierValue:[collectionObject valueForKey:key]];
        
        // for each mapping attribute copy over the value from the collectionInstance to the objectInstance
        for (NSString *collectionAttribute in self.mappingDictionary) {
            NSString *objectAttribute = [self.mappingDictionary valueForKey:collectionAttribute];
            
            // get raw value
            id collectionValue = [collectionObject valueForKey:collectionAttribute];
            
            // check to see if this value should be ran through a formatter
            if ([self.objectClass respondsToSelector:@selector(zorn_mappingDateFormatterRelativeToAttributeOfKey:)]) {
                NSDateFormatter *formatter = [self.objectClass zorn_mappingDateFormatterRelativeToAttributeOfKey:collectionAttribute];
                if (formatter) {
                    collectionValue = [formatter dateFromString:collectionValue];
                }
            }
            
            // set non null values
            if (![collectionValue isKindOfClass:[NSNull class]]) {
                [object setValue:collectionValue forKey:objectAttribute];
            }
            
        }
        
        if (customMappingBlock) {
            customMappingBlock(object, collectionObject);
        }
        
        [importedObjects addObject:object];
        
    }
    
    // if this was a core data system, save
    if ([self.objectClass zorncds_isCoreDataInstanceClass]) {
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            DDLogError(@"Could not save context, had error: %@", error);
        }
    }
    
    return [NSArray arrayWithArray:importedObjects];
}

- (id)newOrFoundObjectForUniqueIdentifierValue:(id)uniqueID
{
    if ([self.objectClass zorncds_isCoreDataInstanceClass]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", self.uniqueIdentifierAttribute, uniqueID];
        NSManagedObject *object = [self.objectClass zorncds_findOnlyInManagedObjectContext:self.managedObjectContext withPredicate:predicate];
        if (!object) {
            object = [self.objectClass zorncds_createEntityInManagedObjectContext:self.managedObjectContext];
            [object setValue:uniqueID forKey:self.uniqueIdentifierAttribute];
        }
        return object;
    } else {
        return [self.objectClass new];
    }
}

- (NSError *)validateCoreDataSystems
{
    if ([self.objectClass zorncds_isCoreDataInstanceClass]) {
        if (!self.managedObjectContext) {
            NSDictionary *errorDetails = @{ NSLocalizedDescriptionKey : @"Need a managed object context to map data to NSManagedObject instances." };
            return [NSError errorWithDomain:@"com.clickablebliss" code:999 userInfo:errorDetails];
        }
    }
    return nil;
}

@end
