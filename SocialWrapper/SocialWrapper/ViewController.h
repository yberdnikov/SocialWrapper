//
//  ViewController.h
//  SocialWrapper
//
//  Created by Thao Nguyen Huy on 7/16/13.
//  Copyright (c) 2013 CNC Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate>

- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)postToWall:(id)sender;
- (IBAction)logoutFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;
- (IBAction)sendTweet:(id)sender;
- (IBAction)logoutTwitter:(id)sender;
- (IBAction)loginGoogle:(id)sender;
- (IBAction)sharePlus:(id)sender;
- (IBAction)logoutGoogle:(id)sender;

@end
