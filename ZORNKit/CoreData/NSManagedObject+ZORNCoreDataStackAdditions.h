#import <CoreData/CoreData.h>

@interface NSManagedObject (ZORNCoreDataStackAdditions)

#pragma mark - Identification

+ (NSString *)zorncds_entityName;
+ (NSEntityDescription *)zorncds_entityDescriptionInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - Creation

+ (instancetype)zorncds_createEntityInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - Fetching

+ (NSFetchRequest *)zorncds_fetchRequestForEntityInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)zorncds_findOnlyInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)zorncds_findOnlyInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withPredicate:(NSPredicate *)predicate;
+ (NSArray *)zorncds_executeFetchRequest:(NSFetchRequest *)fetchRequest inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSUInteger)td_countOfEntitiesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
