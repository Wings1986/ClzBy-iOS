//
//  MapViewController.h
//  CloseBy
//
//  Created by iGold on 2/23/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideNavigationController.h"


@interface MapViewController : UIViewController<SlideNavigationControllerDelegate>

@property (nonatomic, assign) NSInteger selectedBusinessID;

@end
