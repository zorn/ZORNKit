#import <Foundation/Foundation.h>
#import "ZORNCoreDataStackErrors.h"

#import "NSObject+ZORNCoreDataStackAdditions.h"
#import "NSManagedObject+ZORNCoreDataStackAdditions.h"
#import "NSManagedObjectContext+ZORNCoreDataStackAdditions.h"

extern NSString * const kZORNCoreDataStackStackIsComingDown;
extern NSString * const kZORNCoreDataStackStackIsReady;

@interface ZORNCoreDataStack : NSObject

#pragma mark - Configuration
// You'll set these after creating an instance of ZORNCoreDataStack and then call -buildStack; though buildStack can be implied by simply asking for the managedObjectContext as well.

@property (nonatomic, strong) NSURL *managedObjectModelURL;
@property (nonatomic, strong) NSString *persistentStoreType; // Default is NSSQLiteStoreType
@property (nonatomic, strong) NSURL *persistentStoreURL;

#pragma mark - Stack Methods
// These methods allow you to arbitrarily build and tearDown the stack as needed. When a stackIsBuilt you will not be allowed to change the configuration properties.

- (BOOL)buildStackWithError:(NSError **)returnError;
- (BOOL)tearDownStackWithError:(NSError **)returnError;
- (BOOL)stackIsBuilt;

#pragma mark - Stack Access
// Readonly accessors you can use once the stack is built
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

// used by category methods
+ (void)handleErrors:(NSError *)error;

@end
