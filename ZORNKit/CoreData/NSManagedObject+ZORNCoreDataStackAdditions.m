#import "NSManagedObject+ZORNCoreDataStackAdditions.h"
#import "ZORNCoreDataStack.h"

@implementation NSManagedObject (ZORNCoreDataStackAdditions)

#pragma mark - Identification

+ (NSString *)zorncds_entityName
{
    // FIXME: This assumes entity names are the same as class names.
    return NSStringFromClass([self class]);
}

+ (NSEntityDescription *)zorncds_entityDescriptionInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription entityForName:[self zorncds_entityName] inManagedObjectContext:managedObjectContext];
}

#pragma mark - Creation

+ (instancetype)zorncds_createEntityInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self zorncds_entityName] inManagedObjectContext:managedObjectContext];
}

#pragma mark - Fetching

+ (NSFetchRequest *)zorncds_fetchRequestForEntityInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[self zorncds_entityDescriptionInManagedObjectContext:managedObjectContext]];
    return request;
}

+ (instancetype)zorncds_findOnlyInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self zorncds_findOnlyInManagedObjectContext:managedObjectContext withPredicate:nil];
}

+ (instancetype)zorncds_findOnlyInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *entityFR = [self zorncds_fetchRequestForEntityInManagedObjectContext:managedObjectContext];
    if (predicate) {
        [entityFR setPredicate:predicate];
    }
    NSArray *results = [self zorncds_executeFetchRequest:entityFR inManagedObjectContext:managedObjectContext];
    if ([results count] == 1) {
        return [results lastObject];
    } else {
        if ([results count] > 1) {
            NSLog(@"Expected results to be 1 or 0 but was greater that 1: %@", results);
        }
        return nil;
    }
}

+ (NSArray *)zorncds_findAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *entityFR = [self zorncds_fetchRequestForEntityInManagedObjectContext:managedObjectContext];
    NSArray *results = [self zorncds_executeFetchRequest:entityFR inManagedObjectContext:managedObjectContext];
    return results;
}


+ (NSArray *)zorncds_executeFetchRequest:(NSFetchRequest *)fetchRequest inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (nil == result) {
        [ZORNCoreDataStack handleErrors:error];
        return nil;
    } else {
        return result;
    }
}

+ (NSUInteger)td_countOfEntitiesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [self zorncds_fetchRequestForEntityInManagedObjectContext:managedObjectContext];
    NSUInteger answer = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (NSNotFound == answer) {
        [ZORNCoreDataStack handleErrors:error];
        return NSNotFound;
    } else {
        return answer;
    }
}

@end
