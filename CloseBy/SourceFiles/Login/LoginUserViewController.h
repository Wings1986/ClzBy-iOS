//
//  LoginUserViewController.h
//  CloseBy
//
//  Created by Kevin on 2/18/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginBaseViewController.h"
#import "THSegmentedPageViewControllerDelegate.h"



@interface LoginUserViewController : LoginBaseViewController<THSegmentedPageViewControllerDelegate>

@property(nonatomic,strong)NSString *viewTitle;

@end
