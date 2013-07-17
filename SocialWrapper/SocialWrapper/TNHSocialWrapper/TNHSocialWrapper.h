//
//  TNHSocialWrapper.h
//
//  Created by Thao Nguyen Huy on 7/16/13.
//  Copyright (c) 2013 CNC Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSTwitterEngine.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

typedef enum {
    SocialWrapperSharingStateSuccess    = 0,
    SocialWrapperSharingStateCanceled   = 1,
    SocialWrapperSharingStateFailed     = 2
}SocialWrapperSharingState;

@interface TNHSocialWrapper : NSObject <FHSTwitterEngineAccessTokenDelegate>

+ (TNHSocialWrapper *)sharedWrapper;

/**==============================================/
// Wrapper for Twitter (using FHSTwitterEngine) //
/==============================================**/
/**
    Check for Twitter authorized status, will load saved access token if have
 */
- (BOOL)isAuthorizedWithTwitter;
/**
    Login with Twitter account on sender, return YES if login success, otherwise return NO
 */
- (void)loginTwitterFromViewController:(UIViewController *)sender withCompletionBlock:(void(^)(BOOL success))block;
/**
    Get informations about logged Twitter account, Twitter does not return email on response
 */
- (id)getTwitterUserInfo;
/**
    Get IDs list of current logged account's friends.
 */
- (id)getTwitterFriendIds;
/**
    Post a tweet to Twitter, 
    @param: tweetString cannot be nil or empty
 */
- (void)postTweet:(NSString *)tweetString withImageData:(NSData *)theData inReplyTo:(NSString *)irt withCompletionBlock:(void(^)(NSError *error))block;
/**
    Logout current Twitter session
 */
- (void)logoutTwitter;


/**==============================================/
// Wrapper for Facebook (using FacebookSDK)     //
/==============================================**/

@property (nonatomic, strong) FBSession *session;

/**
    Called when application asked for open an URL
 */
- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication;
/**
    Called when application did become active
 */
- (void)handleDidBecomeActive;
/**
    Check for Facebook session was opened or not
 */
- (BOOL)isAuthorizedWithFacebook;
/**
    Login with Facebook account, return YES if login success, otherwise return NO
 */
- (void)loginFacebookWithCompletionBlock:(void(^)(BOOL success))block;
/**
    Get informations about logged Facebook account, must enter permissions required
 */
- (void)getFacebookUserInfoWithCompletionBlock:(void(^)(id result, NSError *error))block;
/**
    Get friends list of current logged account.
 */
- (void)getFacebookFriendsWithCompletionBlock:(void(^)(id result, NSError *error))block;
/**
    Post to Facebook wall, user will enter your message
 */
- (void)postToFacebookWithCompletionBlock:(void(^)(SocialWrapperSharingState status))block;
/**
 */
- (void)postToFacebookWithParams:(NSDictionary *)params completionBlock:(void (^)(SocialWrapperSharingState))block;
/**
    Close current Facebook session, Called when application will terminate
 */
- (void)closeFacebookSession;
/**
    Clear current Facebook session
 */
- (void)logoutFacebook;

/**==============================================/
// Wrapper for Google+ (using GooglePlusSDK)    //
/==============================================**/

@property (nonatomic, strong) GTMOAuth2Authentication *mAuth;

- (BOOL)isAuthorizedWithGooglePlus;
- (void)loginGooglePlusFromViewController:(id <UINavigationControllerDelegate>)sender;
- (void)getGoogleUserInfoWithCompletionBlock:(void(^)(id result, NSError *error))block;
- (void)logoutGooglePlus;

@end
