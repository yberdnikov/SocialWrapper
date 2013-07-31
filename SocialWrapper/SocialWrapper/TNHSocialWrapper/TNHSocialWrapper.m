//
//  TNHSocialWrapper.m
//
//  Created by Thao Nguyen Huy on 7/16/13.
//  Copyright (c) 2013 CNC Software. All rights reserved.
//

#import "TNHSocialWrapper.h"

#define __TWITTER_ENABLED__     1
#define __FACEBOOK_ENABLED__    1
#define __GOOGLEPLUS_ENABLED__  1

static NSString *const kTwitterConsumerKey      = @"Xg3ACDprWAH8loEPjMzRg";
static NSString *const kTwitterSecretKey        = @"9LwYDxw1iTc6D9ebHdrYCZrJP4lJhQv5uf4ueiPHvJ0";

static NSString *const kGoogleClientIDKey       = @"948207138677.apps.googleusercontent.com";
static NSString *const kGoogleClientSecretKey   = @"o_KeGME4pF14koshbdY3K6yy";
static NSString *const kKeychainItemName        = @"Wrapper: Google Contacts";

@interface TNHSocialWrapper ()
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;
- (void)incrementNetworkActivity:(NSNotification *)notify;
- (void)decrementNetworkActivity:(NSNotification *)notify;
- (void)signInNetworkLostOrFound:(NSNotification *)notify;

@end

@implementation TNHSocialWrapper {
  int mNetworkActivityCounter;
}

+ (TNHSocialWrapper *)sharedWrapper {
    static TNHSocialWrapper *_sharedWrapper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWrapper = [[TNHSocialWrapper alloc] init];
    });
    return _sharedWrapper;
}

- (id)init {
    if (self = [super init]) {
#if __TWITTER_ENABLED__
        [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:kTwitterConsumerKey
                                                         andSecret:kTwitterSecretKey];
        [[FHSTwitterEngine sharedEngine] setDelegate:self];
#endif
        
#if __FACEBOOK_ENABLED__
        if (!self.session.isOpen) {
            self.session = [[FBSession alloc] initWithPermissions:@[@"email"]];
            if (self.session.state == FBSessionStateCreatedTokenLoaded) {
                [self.session openWithCompletionHandler:nil];
            }
        }
#endif
        
#if __GOOGLEPLUS_ENABLED__
        self.mAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                           clientID:kGoogleClientIDKey
                                                                       clientSecret:kGoogleClientSecretKey];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuth2WebViewStartedLoading object:nil];
        [notificationCenter addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuth2WebViewStoppedLoading object:nil];
        [notificationCenter addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuth2FetchStarted object:nil];
        [notificationCenter addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuth2FetchStopped object:nil];
        [notificationCenter addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkLost  object:nil];
        [notificationCenter addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkFound object:nil];
#endif
    }
    return self;
}

- (void)dealloc {
#if __GOOGLEPLUS_ENABLED__
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}

#pragma mark -
#pragma mark - Twitter wrapper
- (void)loginTwitterFromViewController:(UIViewController *)sender withCompletionBlock:(void(^)(BOOL success))block {
    [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:sender withCompletion:^(BOOL success) {
        if (block) {
            block(success);
        }
    }];
}

- (void)postTweet:(NSString *)tweetString withImageData:(NSData *)theData inReplyTo:(NSString *)irt withCompletionBlock:(void(^)(NSError *error))block {
    NSError *error = nil;
    if (theData) {
        if (irt) {
            error = [[FHSTwitterEngine sharedEngine] postTweet:tweetString withImageData:theData inReplyTo:irt];
        }
        else {
            error = [[FHSTwitterEngine sharedEngine] postTweet:tweetString withImageData:theData];
        }
    }
    else {
        if (irt) {
            error = [[FHSTwitterEngine sharedEngine] postTweet:tweetString inReplyTo:irt];
        }
        else {
            error = [[FHSTwitterEngine sharedEngine] postTweet:tweetString];
        }
    }
    if (block) {
        block(error);
    }
}

- (void)logoutTwitter {
    [[FHSTwitterEngine sharedEngine] clearAccessToken];
}

- (BOOL)isAuthorizedWithTwitter {
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    return [[FHSTwitterEngine sharedEngine] isAuthorized];
}

- (id)getTwitterUserInfo {
    return [[FHSTwitterEngine sharedEngine] verifyCredentials];
}

- (id)getTwitterFriendIds {
    return [[FHSTwitterEngine sharedEngine] getFriendsIDs];
}

#pragma mark * FHSTwitterEngineAccessTokenDelegate
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken
                                              forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark -
#pragma mark - Facebook wrapper
@synthesize session = _session;

- (void)setSession:(FBSession *)session {
    _session = session;
    [FBSession setActiveSession:_session];
}

- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}

- (void)handleDidBecomeActive {
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (BOOL)isAuthorizedWithFacebook {
    return self.session.isOpen;
}

- (void)loginFacebookWithCompletionBlock:(void(^)(BOOL success))block {
    if (self.session.state != FBSessionStateCreated) {
        self.session = [[FBSession alloc] initWithPermissions:@[@"email"]];
    }

    [self.session openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        BOOL success = YES;
        if (error) {
            success = NO;
        }
        if (block) {
            block(success);
        }
    }];
}

- (void)getFacebookFriendsWithCompletionBlock:(void(^)(id result, NSError *error))block {
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (block) {
            block(result, error);
        }
    }];
}

- (void)getFacebookUserInfoWithCompletionBlock:(void(^)(id result, NSError *error))block {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (block) {
            block(result, error);
        }
    }];
}

- (void)postToFacebookWithCompletionBlock:(void(^)(SocialWrapperSharingState status))block {
    [self postToFacebookWithParams:nil completionBlock:block];
}

- (void)postToFacebookWithParams:(NSDictionary *)params completionBlock:(void (^)(SocialWrapperSharingState))block {
    [FBWebDialogs presentFeedDialogModallyWithSession:self.session parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        SocialWrapperSharingState status = SocialWrapperSharingStateSuccess;
        if (result == FBWebDialogResultDialogNotCompleted) { // user close dialog by close button
            status = SocialWrapperSharingStateCanceled;
        }
        else {
            if (error) { // posting error
                status = SocialWrapperSharingStateFailed;
            }
            else {
                if ([resultURL.description rangeOfString:@"?post_id="].location == NSNotFound) { // user close dialog by cancel button
                    status = SocialWrapperSharingStateCanceled;
                }
            }
        }
        if (block) {
            block(status);
        }
    }];
}

- (void)closeFacebookSession {
    [self.session close];
}

- (void)logoutFacebook {
    [self.session closeAndClearTokenInformation];
}

#pragma mark -
#pragma mark - GooglePlus wrapper
@synthesize mAuth = _mAuth;

- (BOOL)isAuthorizedWithGooglePlus {
    return self.mAuth.canAuthorize;
}

- (void)loginGooglePlusFromViewController:(id <UINavigationControllerDelegate>)sender {
    [self logoutGooglePlus];    
    SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
    NSString *scope = @"https://www.googleapis.com/auth/plus.me";
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:scope
                                                              clientID:kGoogleClientIDKey
                                                          clientSecret:kGoogleClientSecretKey
                                                      keychainItemName:kKeychainItemName
                                                              delegate:self
                                                      finishedSelector:finishedSel];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"en"
                                                       forKey:@"hl"];
    viewController.signIn.additionalAuthorizationParameters = params;
    viewController.signIn.shouldFetchGoogleUserEmail = YES;
    viewController.signIn.shouldFetchGoogleUserProfile = YES;
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    viewController.initialHTMLString = html;
    viewController.showsInitialActivityIndicator = YES;
    [[(UIViewController *)sender navigationController] pushViewController:viewController animated:YES];
}

- (void)getGoogleUserInfoWithCompletionBlock:(void (^)(id, NSError *))block {
    if (self.mAuth.canAuthorize) {
        NSString *urlStr = @"https://www.googleapis.com/oauth2/v1/userinfo?alt=json";
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.mAuth authorizeRequest:request completionHandler:^(NSError *error) {
            NSString *result = nil;
            if (!error) {
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
                if (data) {
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
            }
            if (block) {
                if (!result || error) {
                    block(result, error);
                }
                else {
                    block(result, nil);
                }
            }
        }];
    }
}

- (void)logoutGooglePlus {
    if ([self.mAuth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.mAuth];
    }
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    self.mAuth = nil;
}

#pragma mark * Google Plus finished selector
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        
        self.mAuth = nil;
    } else {
        self.mAuth = auth;
        [self getGoogleUserInfoWithCompletionBlock:^(id result, NSError *error) {
            NSLog(@"%@ - %@", result, error);
        }];
    }
}

- (void)incrementNetworkActivity:(NSNotification *)notify {
    ++mNetworkActivityCounter;
    if (mNetworkActivityCounter == 1) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)decrementNetworkActivity:(NSNotification *)notify {
    --mNetworkActivityCounter;
    if (mNetworkActivityCounter == 0) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)signInNetworkLostOrFound:(NSNotification *)notify {
    if ([[notify name] isEqual:kGTMOAuth2NetworkLost]) {
        // network connection was lost; alert the user, or dismiss
        // the sign-in view with
        //   [[[notify object] delegate] cancelSigningIn];
    } else {
        // network connection was found again
    }
}

@end
