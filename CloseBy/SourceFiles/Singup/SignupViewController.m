//
//  SignupViewController.m
//  CloseBy
//
//  Created by iGold on 2/21/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "SignupViewController.h"


#import "SignupBusinessViewController.h"
#import "SignupUserViewController.h"


@interface SignupViewController ()
{
    SignupBusinessViewController *businessController;
    SignupUserViewController * userController;
}
@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    businessController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupBusinessViewController"];
    businessController.parentController = self;
    
    userController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupUserViewController"];
    userController.parentController = self;
    
    [self.view addSubview:businessController.view];
//    [businessController didMoveToParentViewController:self];
    [self addChildViewController:businessController];

    [self.view addSubview:userController.view];
//    [userController didMoveToParentViewController:self];
    [self addChildViewController:userController];

    [self selectUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) selectBusiness {
    businessController.view.hidden = NO;
    userController.view.hidden = YES;
}
- (void) selectUser {
    businessController.view.hidden = YES;
    userController.view.hidden = NO;
}
- (void) onBack {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
