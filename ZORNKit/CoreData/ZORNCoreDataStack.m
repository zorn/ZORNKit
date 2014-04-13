#import "ZORNCoreDataStack.h"

NSString * const kZORNCoreDataStackStackIsReady = @"kZORNCoreDataStackStackIsReady";
NSString * const kZORNCoreDataStackStackIsComingDown = @"kZORNCoreDataStackStackIsComingDown";

@implementation ZORNCoreDataStack

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.persistentStoreType = NSSQLiteStoreType;
    }
    return self;
}

#pragma mark - Configuration

- (void)setManagedObjectModelURL:(NSURL *)managedObjectModelURL
{
    NSAssert(NO == self.stackIsBuilt, @"Don't edit the managedObjectModelURL while a stack is built.");
    _managedObjectModelURL = managedObjectModelURL;
}

- (void)setPersistentStoreType:(NSString *)persistentStoreType
{
    NSAssert(NO == self.stackIsBuilt, @"Don't edit the managedObjectModelURL while a stack is built.");
    _persistentStoreType = persistentStoreType;
}

- (void)setPersistentStoreURL:(NSURL *)persistentStoreURL
{
    NSAssert(NO == self.stackIsBuilt, @"Don't edit the managedObjectModelURL while a stack is built.");
    _persistentStoreURL = persistentStoreURL;
}

#pragma mark - Stack Methods

- (BOOL)buildStackWithError:(NSError **)returnError
{
    if ([self stackIsBuilt]) {
        NSError *error = [NSError errorWithDomain:kZORNCoreDataStackErrorDomain code:kZORNCoreDataStackStackAlreadyBuiltErrorCode userInfo:@{ NSLocalizedDescriptionKey : kZORNCoreDataStackStackAlreadyBuiltErrorLocalizedDescription, NSRecoveryAttempterErrorKey : kZORNCoreDataStackStackAlreadyBuiltErrorRecoverySuggestion}];
        if (returnError != NULL) {
            *returnError = error;
        }
        return NO;
    }
    
    NSAssert(!self.managedObjectModel, @"assuming nil");
    NSAssert(!self.persistentStoreCoordinator, @"assuming nil");
    NSAssert(!self.managedObjectContext, @"assuming nil");
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.managedObjectModelURL];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:self.persistentStoreType configuration:nil URL:self.persistentStoreURL options:nil error:&error]) {
        *returnError = error;
        return NO;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZORNCoreDataStackStackIsReady object:self userInfo:@{@"managedObjectContext" : self.managedObjectContext}];
    
    return YES;
}

- (BOOL)tearDownStackWithError:(NSError **)returnError
{
    NSAssert(self.managedObjectContext, @"don't call this when there is no current stack");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZORNCoreDataStackStackIsComingDown object:self userInfo:@{@"managedObjectContext" : self.managedObjectContext}];
    
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil;
    
    return YES;
}

- (BOOL)stackIsBuilt
{
    return self.managedObjectContext != nil;
}

#pragma mark - Error Handling

+ (void)defaultErrorHandler:(NSError *)error
{
    NSDictionary *userInfo = [error userInfo];
    for (NSArray *detailedError in [userInfo allValues])
    {
        if ([detailedError isKindOfClass:[NSArray class]])
        {
            for (NSError *e in detailedError)
            {
                if ([e respondsToSelector:@selector(userInfo)])
                {
                    DDLogError(@"Error Details: %@", [e userInfo]);
                }
                else
                {
                    DDLogError(@"Error Details: %@", e);
                }
            }
        }
        else
        {
            DDLogError(@"Error: %@", detailedError);
        }
    }
    DDLogError(@"Error Message: %@", [error localizedDescription]);
    DDLogError(@"Error Domain: %@", [error domain]);
    DDLogError(@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
}

+ (void)handleErrors:(NSError *)error
{
	[self defaultErrorHandler:error];
}

@end
