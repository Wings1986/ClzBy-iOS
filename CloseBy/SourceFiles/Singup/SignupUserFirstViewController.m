//
//  SignupUserFirstViewController.m
//  CloseBy
//
//  Created by iGold on 3/2/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "SignupUserFirstViewController.h"

#import "SignupUserViewController.h"

@interface SignupUserFirstViewController()
{
    
}
@end


@implementation SignupUserFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClickManual:(id)sender {

    for (UIView * subView in self.view.subviews) {
        subView.hidden = YES;
    }

    
    SignupUserViewController     *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupUserViewController"];
    
    controller.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:controller.view];
    [self addChildViewController:controller];

}
- (IBAction)onClickFacebook:(id)sender {
    
    [super loginFacebook];
    
}
@end
