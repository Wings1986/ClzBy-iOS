//
//  ProfileViewController.h
//  CloseBy
//
//  Created by iGold on 3/8/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideNavigationController.h"


@interface ProfileViewController : BaseViewController<SlideNavigationControllerDelegate>

@property (nonatomic, assign) BOOL bShowBackButton;
@property (nonatomic, assign) BOOL bShowEditButton;

@property (nonatomic, strong) NSString * businessUserID;

@property (nonatomic, strong) NSDictionary* responseData;

@end
