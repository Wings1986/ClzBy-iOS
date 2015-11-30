//
//  SignupBusinessViewController.m
//  CloseBy
//
//  Created by iGold on 2/23/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "SignupBusinessViewController.h"
#import "AppDelegate.h"

typedef enum
{
    PICKER_NONE = 0,
    PICKER_SHOPCENTER ,
    PICKER_MAINCATEGORY
}PICKERMODE;

@interface SignupBusinessViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UITextField *tfName;
    IBOutlet UITextField *tfAddress;
    IBOutlet UITextField *tfFullName;
    IBOutlet UITextField *tfShopCenter;
    IBOutlet UITextField *tfMainCategory;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
    IBOutlet UITextField *tfContactNumber;
    
    IBOutlet UIScrollView *mScrollView;
    
    IBOutlet UIPickerView *mPickerView;
    IBOutlet NSLayoutConstraint *bottomPicker;
    BOOL m_isShowPicker;
    
    NSMutableArray * shoppingCentres;
    int     selectedIndexShoppingCenter;

    NSMutableArray * arrayCategory;
    int     selectedIndexCategory;
    
    PICKERMODE pickerMode;
}

@end

@implementation SignupBusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    bottomPicker.constant = -180;
    m_isShowPicker = NO;
    selectedIndexShoppingCenter = -1;
    selectedIndexCategory = -1;
    
    pickerMode = PICKER_NONE;
    
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
- (IBAction)onClickUser:(id)sender {
    
    [self.parentController selectUser];
}

- (IBAction)onClickSubmit:(id)sender {
    NSString * businessName = tfName.text;
    NSString * businessAddress = tfAddress.text;
    NSString * fullName = tfFullName.text;
    NSString * email = tfEmail.text;
    NSString * password = tfPassword.text;
    NSString * contactNumber = tfContactNumber.text;
    
    
    if (businessName.length < 1) {
        [[iToast makeText:@"Please input business name"] show];
        return;
    }
    if (businessAddress.length < 1) {
        [[iToast makeText:@"Please input business address"] show];
        return;
    }
    if (fullName.length < 1) {
        [[iToast makeText:@"Please input full name"] show];
        return;
    }
    if (selectedIndexShoppingCenter == -1) {
        [[iToast makeText:@"Please select shopping center"] show];
        return;
    }
    if (selectedIndexCategory == -1) {
        [[iToast makeText:@"Please select main category"] show];
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
    
    NSString *requestCategoriesUrl = [[NSString stringWithFormat:@"%@/AddBusiness.aspx?guid=%@&BusinessName=%@&BusinessAddress=%@&YourName=%@&SID=%@&MainCategoryID=%@&Email=%@&Pass=%@&ContactNumber=%@",
                                       kServerURL, kGUID,
                                       businessName, businessAddress, fullName,
                                       shoppingCentres[selectedIndexShoppingCenter][@"ID"],
                                       arrayCategory[selectedIndexCategory][@"ID"],
                                       email, password, contactNumber] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
             if (responseJson != nil && ![[responseJson[@"Success"] uppercaseString] isEqualToString:@"FAIL"]) {
                 
                 [GlobalAPI storeLoginID:responseJson[@"Data"][@"UserID"]];
                 [GlobalAPI storeUserType:[responseJson[@"Data"][@"IsBusiness"] boolValue]];
                 [GlobalAPI storeUsername:responseJson[@"Data"][@"BusinessName"]];
                 
                 URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Success"
                                                                       message:responseJson[@"Message"]
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil, nil];
                 [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                     [alertView hideWithCompletionBlock:^{
                         AppDelegate* delegate = [UIApplication sharedApplication].delegate;
                         [delegate gotoHomeScreen:YES];
                     }];
                 }];
                 [alertView show];
                 
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
             //              [MBProgressHUD hideHUDForView:self.view animated:YES];
             [CB_AlertView hideAlert];
         }];
    
}
- (IBAction)onClickFacebook:(id)sender {
}
- (IBAction)onClickCallSupport:(id)sender {
    [super sendEmail];
}

- (void) getShopCenter
{
    pickerMode = PICKER_SHOPCENTER;
    
    if (shoppingCentres == NULL) {
        [CB_AlertView showAlertOnView:self.view];
        
        NSString *requestUrl = [[NSString stringWithFormat:@"%@/getshoppingmalls.aspx?guid=%@",
                                          kServerURL,
                                          kGUID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"request = %@", requestUrl);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:requestUrl
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  [CB_AlertView hideAlert];
                  
                  NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                  
                  NSDictionary * responseJson = [responseString JSONValue];

                  NSLog(@"response = %@", responseJson);
                  
                  if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                      shoppingCentres = responseJson[@"Data"];
                  }
                  
                  if (shoppingCentres != NULL && shoppingCentres.count > 0) {
                      [self showShoppingPicker:tfShopCenter];
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [CB_AlertView hideAlert];
              }];
    }
    else {
        [self showShoppingPicker:tfShopCenter];
    }
}
- (void) getMainCategory
{
    pickerMode = PICKER_MAINCATEGORY;
    
    if (arrayCategory == NULL) {
        [CB_AlertView showAlertOnView:self.view];
        
        NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetMainCategories.aspx?guid=%@",
                                 kServerURL,
                                 kGUID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"request = %@", requestUrl);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:requestUrl
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 [CB_AlertView hideAlert];
                 
                 NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 
                 NSDictionary * responseJson = [responseString JSONValue];
                 
                 NSLog(@"response = %@", responseJson);
                 
                 if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                     arrayCategory = responseJson[@"Data"];
                 }
                 
                 if (arrayCategory != NULL && arrayCategory.count > 0) {
                     [self showShoppingPicker:tfMainCategory];
                 }
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [CB_AlertView hideAlert];
             }];
    }
    else {
        [self showShoppingPicker:tfMainCategory];
    }
}


- (void)showShoppingPicker :(UITextField*) tfField{
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         bottomPicker.constant = 0;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = YES;
                         [mPickerView reloadAllComponents];
                         

                         if (tfField == tfShopCenter) {
                             if (selectedIndexShoppingCenter == -1) {
                                 selectedIndexShoppingCenter = 0;
                             }
                             
                             if (selectedIndexShoppingCenter != -1) {
                                 
                                 tfShopCenter.text = shoppingCentres[selectedIndexShoppingCenter][@"Name"];
                                 
                                 [mPickerView selectRow:selectedIndexShoppingCenter inComponent:0 animated:YES];
                             }
                         }

                         if (tfField == tfMainCategory) {
                             if (selectedIndexCategory == -1) {
                                 selectedIndexCategory = 0;
                             }
                             
                             if (selectedIndexCategory != -1) {
                                 
                                 tfMainCategory.text = arrayCategory[selectedIndexCategory][@"CategoryName"];
                                 
                                 [mPickerView selectRow:selectedIndexCategory inComponent:0 animated:YES];
                             }
                         }
                         
                         
                     }];
}
- (void)hideShoppingPicker {
    if (!m_isShowPicker) {
        return;
    }

    [UIView animateWithDuration:1.0
                     animations:^{
                         bottomPicker.constant = -180;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = NO;
                     }];
}

#pragma mark -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
    
    if ([textField isEqual:tfShopCenter]) {
        
        [super listSubviewsOfView:self.view];

        
        shouldEdit = NO;

        [self getShopCenter];
    }
    else if ([textField isEqual:tfMainCategory]) {
        
        [super listSubviewsOfView:self.view];
        
        shouldEdit = NO;
        
        [self getMainCategory];
    }
    else {
        
        [self hideShoppingPicker];
    }
    
    return shouldEdit;
}

#pragma mark - ShoppingPicker View Delegate & DataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component
{
    if (pickerMode == PICKER_SHOPCENTER) {
        if (shoppingCentres == NULL) {
            return 0;
        }
        return shoppingCentres.count;
    }
    if (pickerMode == PICKER_MAINCATEGORY) {
        if (arrayCategory == NULL) {
            return 0;
        }
        return arrayCategory.count;
    }
    
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString * title = @"";

    if (pickerMode == PICKER_SHOPCENTER) {
        title = shoppingCentres[row][@"Name"];
    }
    if (pickerMode == PICKER_MAINCATEGORY) {
        title = arrayCategory[row][@"CategoryName"];
    }
    
    return title;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerMode == PICKER_SHOPCENTER) {
        selectedIndexShoppingCenter = (int)row;
        tfShopCenter.text = shoppingCentres[row][@"Name"];
    }
    if (pickerMode == PICKER_MAINCATEGORY) {
        selectedIndexCategory = (int)row;
        tfMainCategory.text = arrayCategory[row][@"CategoryName"];
    }
}

#pragma mark keyboard
- (void) hideKeyboard :(UIGestureRecognizer*) gesture{
    [super hideKeyboard:gesture];

    if (m_isShowPicker) {
        [self hideShoppingPicker];
    }
}


//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    [self animateTextField:textField up:YES];
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    //    [self animateTextField:textField up:NO];
//}
//
//-(void)animateTextField:(UITextField*)textField up:(BOOL)up
//{
//    
//    if (textField.frame.origin.y < self.view.frame.size.height - 320) {
//        return;
//    }
//    
//    
//    int movementDistance = textField.frame.origin.y - (self.view.frame.size.height - 320);
//    const float movementDuration = 0.3f; // tweak as needed
//    
//    int movement = (up ? movementDistance : 0);
//    
//    [UIView beginAnimations: @"animateTextField" context: nil];
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    [UIView setAnimationDuration: movementDuration];
//    
//    mScrollView.contentOffset = CGPointMake(0, movement);
//    
//    [UIView commitAnimations];
//}



@end
