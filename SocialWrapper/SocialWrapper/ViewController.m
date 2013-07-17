//
//  ViewController.m
//  SocialWrapper
//
//  Created by Thao Nguyen Huy on 7/16/13.
//  Copyright (c) 2013 CNC Software. All rights reserved.
//

#import "ViewController.h"
#import "TNHSocialWrapper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Facebook
- (IBAction)loginWithFacebook:(id)sender {
    [[TNHSocialWrapper sharedWrapper] loginFacebookWithCompletionBlock:^(BOOL success) {
    }];
}

- (IBAction)postToWall:(id)sender {
    if ([[TNHSocialWrapper sharedWrapper] isAuthorizedWithFacebook]) {
        [[TNHSocialWrapper sharedWrapper] postToFacebookWithCompletionBlock:nil];
    }
    else {
        [[TNHSocialWrapper sharedWrapper] loginFacebookWithCompletionBlock:^(BOOL success) {
            if (success) {
                [[TNHSocialWrapper sharedWrapper] postToFacebookWithCompletionBlock:nil];                
            }
        }];
    }
}

- (IBAction)logoutFacebook:(id)sender {
    [[TNHSocialWrapper sharedWrapper] logoutFacebook];
}

#pragma mark - Twitter
- (IBAction)loginWithTwitter:(id)sender {
    [[TNHSocialWrapper sharedWrapper] loginTwitterFromViewController:self withCompletionBlock:nil];
}

- (IBAction)sendTweet:(id)sender {
    [[TNHSocialWrapper sharedWrapper] postTweet:[NSString stringWithFormat:@"Tweet at %@", [NSDate date]] withImageData:nil inReplyTo:nil withCompletionBlock:nil];
}

- (IBAction)logoutTwitter:(id)sender {
    [[TNHSocialWrapper sharedWrapper] logoutTwitter];
}

#pragma mark - Google
- (IBAction)loginGoogle:(id)sender {
    [[TNHSocialWrapper sharedWrapper] loginGooglePlusFromViewController:self];
}

- (IBAction)sharePlus:(id)sender {
    
}

- (IBAction)logoutGoogle:(id)sender {
    [[TNHSocialWrapper sharedWrapper] logoutGooglePlus];
}

@end
