//
//  LoginBusinessViewController.m
//  CloseBy
//
//  Created by Kevin on 2/17/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "LoginBusinessViewController.h"

#import "SignupViewController.h"


@interface LoginBusinessViewController ()
{
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
}
@end

@implementation LoginBusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [tfEmail setText:@"marmalade@gmail.com"];
    [tfPassword setText:@"george69"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}

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
- (IBAction)onClickRegister:(id)sender {
    [self performSegueWithIdentifier:@"gotosignup" sender:self];
}

- (IBAction)onClickFacebook:(id)sender {
}
- (IBAction)onClickSupport:(id)sender {
        [super sendEmail];
}

#pragma mark - UITextField delegate methods
#define kOFFSET_KEYBOARD 70
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self keyboardWillShow];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self keyboardWillHide];
    [textField resignFirstResponder];
}
-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        //        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_KEYBOARD;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += kOFFSET_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
@end
