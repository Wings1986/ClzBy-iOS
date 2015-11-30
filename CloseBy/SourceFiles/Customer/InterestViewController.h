//
//  InterestViewController.h
//  CloseBy
//
//  Created by daniel on 12/16/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"


@protocol InterestViewControllerDelegate<NSObject>
@optional
- (void) chooseCategory:(NSString*) arrCategory;
@end


@interface InterestViewController : BaseViewController


@property (assign, nonatomic) id <InterestViewControllerDelegate>delegate;


@end
