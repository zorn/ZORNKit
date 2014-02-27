#import "ZORNTwitterService.h"

NSString * const kZORNTwitterServiceHasTwitterAccountAccessChanged = @"kZORNTwitterServiceHasTwitterAccountAccessChanged";

@interface ZORNTwitterService ()
@property (strong) ACAccountStore *accountStore;
@end

@implementation ZORNTwitterService

- (id)init
{
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.hasTwitterAccountAccess = NO;
    }
    return self;
}

- (void)requestTwitterAccountAccessWithHandler:(void (^)(BOOL granted, NSError *error))completionHandler
{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    __weak ZORNTwitterService *weakSelf = self;
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
        if (granted) {
            weakSelf.hasTwitterAccountAccess = YES;
        }
        completionHandler(granted, error);
    }];
}

- (void)setHasTwitterAccountAccess:(BOOL)hasTwitterAccountAccess
{
    _hasTwitterAccountAccess = hasTwitterAccountAccess;
    [[NSNotificationCenter defaultCenter] postNotificationName:kZORNTwitterServiceHasTwitterAccountAccessChanged object:self];
}

- (NSArray *)systemTwitterAccounts
{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    return [self.accountStore accountsWithAccountType:twitterAccountType];
}

- (ACAccount *)systemTwitterAccountWithUsername:(NSString *)username
{
    for (ACAccount *acccount in [self systemTwitterAccounts]) {
        if ([acccount.username isEqualToString:username]) {
            return acccount;
        }
    }
    return nil;
}

- (NSString *)twitterBaseURL
{
    return @"https://api.twitter.com/1.1/";
}

- (NSURL *)urlForFriendsList
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self twitterBaseURL], @"friends/list.json"];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)urlForHomeTimeline
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self twitterBaseURL], @"statuses/home_timeline.json"];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)urlForUserProfile
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self twitterBaseURL], @"users/show.json"];
    return [NSURL URLWithString:urlString];
}

- (SLRequest *)authenticatedRequestForURL:(NSURL *)url parameters:(NSDictionary *)parameters
{
    NSAssert(self.authenticatedTwitterAccount, @"assume authenticatedTwitterAccount is not nil");
    SLRequest *newRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:parameters];
    [newRequest setAccount:self.authenticatedTwitterAccount];
    return newRequest;
}

- (void)requestHomeTimelineForAuthenticateUserWithMaxID:(NSString *)maxID sinceID:(NSString *)sinceID responseHandler:(SLRequestHandler)responseHandler
{
    NSMutableDictionary *params = [@{
                             @"count" : @"200",
                             @"include_user_entities" : @YES
                             } mutableCopy];
    
    if (maxID) {
        [params setObject:maxID forKey:@"max_id"];
    }
    
    if (sinceID) {
        [params setObject:sinceID forKey:@"since_id"];
    }
    
    SLRequest *request = [self authenticatedRequestForURL:[self urlForHomeTimeline] parameters:[NSDictionary dictionaryWithDictionary:params]];
    NSLog(@"Requesting URL %@ with params %@", [[request URL] absoluteString], [request parameters]);
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        responseHandler(responseData, urlResponse, error);
    }];
}

- (void)requestFriendsListForUsername:(NSString *)username pageCursor:(NSString *)pageCursor responseHandler:(SLRequestHandler)responseHandler
{
    NSDictionary *params = @{
                             @"screen_name" : username,
                             @"cursor" : pageCursor,
                             @"skip_status" : @YES,
                             @"count" : @"200",
                             @"include_user_entities" : @YES
                             };
    SLRequest *request = [self authenticatedRequestForURL:[self urlForFriendsList] parameters:params];
    NSLog(@"Requesting URL %@ with params %@", [[request URL] absoluteString], [request parameters]);
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        responseHandler(responseData, urlResponse, error);
    }];
}

- (void)requestUserProfileForUsername:(NSString *)username responseHandler:(SLRequestHandler)responseHandler
{
    NSDictionary *params = @{
                             @"screen_name" : username,
                             @"include_user_entities" : @YES
                             };
    SLRequest *request = [self authenticatedRequestForURL:[self urlForUserProfile] parameters:params];
    NSLog(@"Requesting URL %@ with params %@", [[request URL] absoluteString], [request parameters]);
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        responseHandler(responseData, urlResponse, error);
    }];
}

+ (NSDateFormatter *)twitterDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return formatter;
}

/*
- (void)fetchTimelineForUser:(NSString *)username
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
 
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [self.accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 NSDictionary *params = @{@"screen_name" : username,
                                          @"include_rts" : @"0",
                                          @"trim_user" : @"1",
                                          @"count" : @"100"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             NSError *jsonError;
                             NSDictionary *timelineData =
                             [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingAllowFragments error:&jsonError];
                             
                             if (timelineData) {
                                 NSLog(@"Timeline Response: %@\n", timelineData);
                             }
                             else {
                                 // Our JSON deserialization went awry
                                 NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                             }
                         }
                         else {
                             // The server did not respond successfully... were we rate-limited?
                             NSLog(@"The response status code is %d", urlResponse.statusCode);
                         }
                     }
                 }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
}


- (IBAction)fetchTimeline:(id)sender
{
    [self fetchTimelineForUser:@"zorn"];
}
*/

@end
