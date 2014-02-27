#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

extern NSString * const kZORNTwitterServiceHasTwitterAccountAccessChanged;

typedef void (^CBTwitterStoreErrorHandler) (NSString *message, NSError* error);

// ZORNTwitterService is an iOS interface for accessing data from Twitter.
@interface ZORNTwitterService : NSObject

// request from the user access to the twitter accounts they've setup in Settings
- (void)requestTwitterAccountAccessWithHandler:(void (^)(BOOL granted, NSError *error))completionHandler;

@property (strong, nonatomic) ACAccount *authenticatedTwitterAccount;
@property (assign, nonatomic) BOOL hasTwitterAccountAccess;

- (NSArray *)systemTwitterAccounts;

- (ACAccount *)systemTwitterAccountWithUsername:(NSString *)username;

- (NSURL *)urlForFriendsList;

- (NSURL *)urlForHomeTimeline;

- (NSURL *)urlForUserProfile;

- (void)requestHomeTimelineForAuthenticateUserWithMaxID:(NSString *)maxID sinceID:(NSString *)sinceID responseHandler:(SLRequestHandler)responseHandler;
- (void)requestFriendsListForUsername:(NSString *)username pageCursor:(NSString *)pageCursor responseHandler:(SLRequestHandler)responseHandler;
- (void)requestUserProfileForUsername:(NSString *)username responseHandler:(SLRequestHandler)responseHandler;

+ (NSDateFormatter *)twitterDateFormatter;

@end
