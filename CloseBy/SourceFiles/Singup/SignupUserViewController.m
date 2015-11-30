//
//  SignupUserViewController.m
//  CloseBy
//
//  Created by iGold on 2/23/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "SignupUserViewController.h"

#import "AppDelegate.h"


@interface SignupUserViewController ()
{
    IBOutlet UITextField *tfFullName;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
    IBOutlet UITextField *tfNumber;
    
    IBOutlet UIScrollView *mScrollView;
}
@end

@implementation SignupUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
- (IBAction)onClickBack:(id)sender {
    
    [self.parentController onBack];
    
}
- (IBAction)onClickBusiness:(id)sender {
    
    [self.parentController selectBusiness];
}

- (IBAction)onClickSubmit:(id)sender {
    
    NSString * fullName = tfFullName.text;
    NSString * email = tfEmail.text;
    NSString * password = tfPassword.text;
    NSString * contactNumber = tfNumber.text;

    if (fullName.length < 1) {
        [[iToast makeText:@"Please input full name"] show];
        return;
    }
    if (email.length < 1) {
        [[iToast makeText:@"Please input email"] show];
        return;
    }
    if (password.length < 1) {
        [[iToast makeText:@"please input password"] show];
        return;
    }
    if (contactNumber.length < 1) {
        [[iToast makeText:@"Please input contact number"] show];
        return;
    }
    
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestCategoriesUrl = [[NSString stringWithFormat:@"%@/AddManualUser.aspx?guid=%@&FullName=%@&EmailAddress=%@&password=%@&ContactNumber=%@&DeviceID=%@",
                                      kServerURL, kGUID, fullName, email, password, contactNumber, [self getMacAddress]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestCategoriesUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestCategoriesUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];
              
              NSLog(@"response = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  [GlobalAPI storeLoginID:responseJson[@"Data"][@"UserID"]];
                  [GlobalAPI storeUserType:[responseJson[@"Data"][@"IsBusiness"] boolValue]];
                  [GlobalAPI storeUsername:responseJson[@"Data"][@"BusinessName"]];
                  
                  AppDelegate* delegate = [UIApplication sharedApplication].delegate;
                  [delegate gotoHomeScreen:NO];
              }
              else {
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Signup Fail"
                                                                        message:responseJson[@"Message"]
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                  [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                      [alertView hideWithCompletionBlock:^{
                      }];
                  }];
                  [alertView show];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [CB_AlertView hideAlert];
          }];
    
}
- (IBAction)onClickFacebook:(id)sender {
    
    [super loginFacebook];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    
    if (textField.frame.origin.y < self.view.frame.size.height - 280) {
        return;
    }


    int movementDistance = textField.frame.origin.y - (self.view.frame.size.height - 280);
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : 0);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    mScrollView.contentOffset = CGPointMake(0, movement);
    
    [UIView commitAnimations];
}
@end
