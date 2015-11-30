//
//  AddBeaconViewController.m
//  CloseBy
//
//  Created by iGold on 3/9/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "AddBeaconViewController.h"
#import "AddFlashMessageViewController.h"


#import "URBAlertView.h"


@interface AddBeaconViewController()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    
    IBOutlet UITextField *tfBeaconUDID;
    IBOutlet UITextField *tfBeaconMajor;
    IBOutlet UITextField *tfBeaconMinor;
    IBOutlet UITextField *tfBeaconType;
    
    IBOutlet UIButton *btnRegister;
    
    IBOutlet UIPickerView *mPickerView;
    IBOutlet NSLayoutConstraint *constraintBottomPicker;
    BOOL m_isShowPicker;
    
    NSMutableArray * arrayBeaconType;
    int     selectedIndexBeaconType;
}
@end


@implementation AddBeaconViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    constraintBottomPicker.constant = -180.0f;
    m_isShowPicker = NO;
//    arrayBeaconType = [[NSMutableArray alloc] init];
    
    if (_beaconData == NULL) {
        self.title = @"Register Beacon";
        [btnRegister setTitle:@"Register Beacon" forState:UIControlStateNormal];
    }
    else {
        tfBeaconUDID.text = _beaconData[@"BeaconUUID"];
        tfBeaconUDID.enabled = YES;
        tfBeaconMajor.text = [NSString stringWithFormat:@"%@", _beaconData[@"Major"]];
        tfBeaconMajor.enabled = NO;
        tfBeaconMinor.text = [NSString stringWithFormat:@"%@", _beaconData[@"Minor"]];
        tfBeaconMinor.enabled = NO;
        
        self.title = @"Update Beacon";
        [btnRegister setTitle:@"Update Beacon" forState:UIControlStateNormal];
    }
    [self getBeaconTypeList];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"gotoflashmessage"]) {
        
        AddFlashMessageViewController * vc = segue.destinationViewController;

        NSLog(@"uuid = %@ major = %@, minor = %@", tfBeaconUDID.text, tfBeaconMajor.text, tfBeaconMinor.text);
        
        vc.beaconUUID = tfBeaconUDID.text;
        vc.beaconMajor = tfBeaconMajor.text;
        vc.beaconMinor = tfBeaconMinor.text;
        
    }
    
}


- (IBAction)onClickRegister:(id)sender {
    
    NSString * beaconUDID = tfBeaconUDID.text;
    if (beaconUDID.length < 1) {
        [[iToast makeText:@"Please input beacon UDID"] show];
        return;
    }
    NSString * beaconMajor = tfBeaconMajor.text;
    if (beaconMajor.length < 1) {
        [[iToast makeText:@"Please input beacon Major"] show];
        return;
    }
    NSString * beaconMinor = tfBeaconMinor.text;
    if (beaconMinor.length < 1) {
        [[iToast makeText:@"Please input beacon Minor"] show];
        return;
    }
    
    if (selectedIndexBeaconType == -1) {
        [[iToast makeText:@"Please select beacon type"] show];
        return;
    }
    
    [super listSubviewsOfView:self.view];
    [self hidePicker];

    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString * apiName = _beaconData == nil ? @"RegisterNewBeacon.aspx" : @"UpdateBeaconType.aspx";
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/%@?guid=%@&userid=%@&BeaconUUID=%@&Major=%@&Minor=%@&BeaconTypeID=%@",
                                       kServerURL,
                                        apiName,
                                        kGUID,
                                       [GlobalAPI loadLoginID],
                                        beaconUDID,
                             beaconMajor,
                             beaconMinor,
                                       arrayBeaconType[selectedIndexBeaconType][@"ID"] ]
                                       stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [CB_AlertView hideAlert];
             
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSDictionary *responseJson = [responseString JSONValue];
             
             NSLog(@"response = %@", responseJson);
             
             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                 
                 NSString * msg = selectedIndexBeaconType == 1 ? responseJson[@"Message"] : @"A beacon updated";
                 
                 URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Success"
                                                                       message:msg
                                                             cancelButtonTitle:selectedIndexBeaconType == 1 ? @"NO" : @"OK"
                                                             otherButtonTitles:selectedIndexBeaconType == 1 ? @"YES" : nil,
                                            nil];
                 [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {

                     [alertView hideWithCompletionBlock:^{
                         // stub

                         if (buttonIndex == 0) { // NO
                             dispatch_async(dispatch_get_main_queue(),^{
                                 
                                 [self.navigationController popViewControllerAnimated:YES];
                                 
                             });
                         }
                         if (buttonIndex == 1) { // YES
                             dispatch_async(dispatch_get_main_queue(),^{
                                 
                                 [self performSegueWithIdentifier:@"gotoflashmessage" sender:self];
                                 
                             });
                         }
                     }];
                 }];
                 [alertView show];

             }
             else {
                 URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Fail"
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

- (void) getBeaconTypeList
{
    if (arrayBeaconType == NULL) {
        [CB_AlertView showAlertOnView:self.view];
        
        NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetAllBeaconTypes.aspx?guid=%@",
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
                     arrayBeaconType = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                     
                     if (_beaconData != NULL) {
                         
                         int i = 0;
                         for (NSDictionary* dic in arrayBeaconType) {
                             if ([dic[@"ID"] isEqualToNumber:_beaconData[@"BeaconTypeID"]]) {
                                 selectedIndexBeaconType = i;
                                 break;
                             }
                             i ++;
                         }
                         
                         if (selectedIndexBeaconType != -1) {
                             tfBeaconType.text = arrayBeaconType[selectedIndexBeaconType][@"BeaconTypeName"];
                         }
                     }
                 }
                 

             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [CB_AlertView hideAlert];
             }];
    }
}

- (void)showPicker {
    if (arrayBeaconType == nil) {
        return;
    }
    if (m_isShowPicker) {
        return;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         constraintBottomPicker.constant = 0;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = YES;
                         [mPickerView reloadAllComponents];
                         
                         
                         if (selectedIndexBeaconType == -1) {
                             selectedIndexBeaconType = 0;
                         }
                         
                         if (selectedIndexBeaconType != -1 && arrayBeaconType.count > 0) {
                             
                             tfBeaconType.text = arrayBeaconType[selectedIndexBeaconType][@"BeaconTypeName"];
                             
                             [mPickerView selectRow:selectedIndexBeaconType inComponent:0 animated:YES];
                         }
                     }];
}
- (void)hidePicker {
    if (!m_isShowPicker) {
        return;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         constraintBottomPicker.constant = -180;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = NO;
                     }];
}

#pragma mark -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
    
    if ([textField isEqual:tfBeaconType]) {
        
        [super listSubviewsOfView:self.view];
        
        
        shouldEdit = NO;
        
        [self showPicker];
    }
    else {
        
        [self hidePicker];
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
    if (arrayBeaconType == NULL) {
        return 0;
    }
    return arrayBeaconType.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString * title = arrayBeaconType[row][@"BeaconTypeName"];
    return title;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedIndexBeaconType = (int)row;
    tfBeaconType.text = arrayBeaconType[row][@"BeaconTypeName"];
}

#pragma mark keyboard
- (void) hideKeyboard :(UIGestureRecognizer*) gesture{
    [super hideKeyboard:gesture];
    
    if (m_isShowPicker) {
        [self hidePicker];
    }
}
@end
