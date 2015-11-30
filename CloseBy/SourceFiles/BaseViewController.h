//
//  BaseViewController.h
//  CloseBy
//
//  Created by iGold on 3/9/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DaiDodgeKeyboard.h"

#import "RoundTextField.h"

@interface BaseViewController : UIViewController
{
    UIView *searchView;
    RoundTextField * searchField;
    
    UITapGestureRecognizer * tapGesture;
    
    UIToolbar *toolBar;
}

@property (nonatomic, assign) BOOL skipSearch;


#pragma mark keyboard event

- (void) hideKeyboard :(UIGestureRecognizer*) gesture;
- (void)listSubviewsOfView:(UIView *)view;


@end
