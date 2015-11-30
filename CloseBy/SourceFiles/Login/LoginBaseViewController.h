//
//  LoginBaseViewController.h
//  CloseBy
//
//  Created by iGold on 3/1/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MFMailComposeViewController.h>//mail controller


@interface LoginBaseViewController : BaseViewController <MFMailComposeViewControllerDelegate>


- (void) requestLogin:(NSString*) email pwd:(NSString*) password;
- (void) requestSkip;
- (void) loginFacebook;
- (void) sendEmail;

-(NSString *)getMacAddress;

@end
