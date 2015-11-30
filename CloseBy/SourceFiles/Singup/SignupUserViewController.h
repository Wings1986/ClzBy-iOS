//
//  SignupUserViewController.h
//  CloseBy
//
//  Created by iGold on 2/23/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginBaseViewController.h"

#import "SignupViewController.h"


@interface SignupUserViewController : LoginBaseViewController

@property (nonatomic, strong) SignupViewController * parentController;

@end
