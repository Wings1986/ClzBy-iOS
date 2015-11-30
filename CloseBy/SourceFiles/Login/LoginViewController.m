//
//  LoginViewController.m
//  CloseBy
//
//  Created by iGold on 2/20/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "LoginViewController.h"

#import "RoundTextField.h"

@interface LoginViewController ()
{
    IBOutlet RoundTextField *tfEmail;
    IBOutlet RoundTextField *tfPassword;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#ifdef DEBUG
    [tfEmail setText:@"marmalade@gmail.com"];
    [tfPassword setText:@"george69"];
#endif
    
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

#pragma mark - button action
- (IBAction)onClickLogin:(id)sender {
    
    NSString * email = tfEmail.text;
    NSString * password = tfPassword.text;
    
    if (email.length < 1) {
        [[iToast makeText:@"Please input email"] show];
        return;
    }
    if (password.length < 1) {
        [[iToast makeText:@"please input password"] show];
        return;
    }
    
    [super requestLogin:email pwd: password];
}


- (IBAction)onClickFacebook:(id)sender {
    
    [super loginFacebook];
}

- (IBAction)onClickHelp:(id)sender {
}
- (IBAction)onClickSkip:(id)sender {

    [super requestSkip];
    
}

@end
