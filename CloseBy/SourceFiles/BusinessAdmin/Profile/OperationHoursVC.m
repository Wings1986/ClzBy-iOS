//
//  OperationHoursVC.m
//  CloseBy
//
//  Created by iGold on 3/10/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "OperationHoursVC.h"

#import "URBAlertView.h"


@interface OperationHoursVC()
{
    
    IBOutlet UITextField *tfMonStart;
    IBOutlet UITextField *tfMonEnd;
    IBOutlet UITextField *tfTueStart;
    IBOutlet UITextField *tfTueEnd;
    IBOutlet UITextField *tfWedStart;
    IBOutlet UITextField *tfWedEnd;
    IBOutlet UITextField *tfThuStart;
    IBOutlet UITextField *tfThuEnd;
    IBOutlet UITextField *tfFriStart;
    IBOutlet UITextField *tfFriEnd;
    IBOutlet UITextField *tfSatStart;
    IBOutlet UITextField *tfSatEnd;
    IBOutlet UITextField *tfSunStart;
    IBOutlet UITextField *tfSunEnd;
    
    UITextField * currentInputField;
    
    IBOutlet UIDatePicker *mDatePicker;
    IBOutlet NSLayoutConstraint *bottomPicker;
    BOOL m_isShowPicker;
}
@end

@implementation OperationHoursVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"Operation Hours";

    [self makeViewLayer:tfMonStart];
    [self makeViewLayer:tfMonEnd];
    [self makeViewLayer:tfTueStart];
    [self makeViewLayer:tfTueEnd];
    [self makeViewLayer:tfWedStart];
    [self makeViewLayer:tfWedEnd];
    [self makeViewLayer:tfThuStart];
    [self makeViewLayer:tfThuEnd];
    [self makeViewLayer:tfFriStart];
    [self makeViewLayer:tfFriEnd];
    [self makeViewLayer:tfSatStart];
    [self makeViewLayer:tfSatEnd];
    [self makeViewLayer:tfSunStart];
    [self makeViewLayer:tfSunEnd];
    
    
    mDatePicker.backgroundColor = [UIColor whiteColor];
    bottomPicker.constant = -180;
    m_isShowPicker = NO;
    
    
    [CB_AlertView showAlertOnView:self.view];
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/BusinessOperatingHours.aspx?guid=%@&UserID=%@",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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

                 int count = 0;
                 for (NSDictionary * dic in responseJson[@"Data"]) {
                     
                     NSString * startTime = dic[@"StartTime"];
                     NSString * endTime = dic[@"EndTime"];
                     
                     if (startTime == nil || [startTime isKindOfClass:[NSNull class]]) {
                         startTime = @"";
                     }
                     if (endTime == nil || [endTime isKindOfClass:[NSNull class]]) {
                         endTime = @"";
                     }
                     
                     
                     if (count == 0) {
                         tfMonStart.text = startTime;
                         tfMonEnd.text = endTime;
                     }
                     else if (count == 1) {
                         tfTueStart.text = startTime;
                         tfTueEnd.text = endTime;
                     }
                     else if (count == 2) {
                         tfWedStart.text = startTime;
                         tfWedEnd.text = endTime;
                     }
                     else if (count == 3) {
                         tfThuStart.text = startTime;
                         tfThuEnd.text = endTime;
                     }
                     else if (count == 4) {
                         tfFriStart.text = startTime;
                         tfFriEnd.text = endTime;
                     }
                     else if (count == 5) {
                         tfSatStart.text = startTime;
                         tfSatEnd.text = endTime;
                     }
                     else if (count == 6) {
                         tfSunStart.text = startTime;
                         tfSunEnd.text = endTime;
                     }
                     
                     count ++;
                 }
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //              [MBProgressHUD hideHUDForView:self.view animated:YES];
             [CB_AlertView hideAlert];
         }];
}

- (void) makeViewLayer:(UITextField*) textField
{
    textField.layer.cornerRadius = textField.frame.size.height/2;
    textField.layer.borderColor = APP_COLOR.CGColor;
    textField.layer.borderWidth = 1;
}
- (IBAction)onClickUpdate:(id)sender {
    
    NSString* strMonStart = tfMonStart.text;
    NSString* strMonEnd = tfMonEnd.text;
    NSString* strTueStart = tfTueStart.text;
    NSString* strTueEnd = tfTueEnd.text;
    NSString* strWedStart = tfWedStart.text;
    NSString* strWedEnd = tfWedEnd.text;
    NSString* strThuStart = tfThuStart.text;
    NSString* strThuEnd = tfThuEnd.text;
    NSString* strFriStart = tfFriStart.text;
    NSString* strFriEnd = tfFriEnd.text;
    NSString* strSatStart = tfSatStart.text;
    NSString* strSatEnd = tfSatEnd.text;
    NSString* strSunStart = tfSunStart.text;
    NSString* strSunEnd = tfSunEnd.text;
    
    [CB_AlertView showAlertOnView:self.view];
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdateBusinessOperatingHours.aspx?guid=%@&UserID=%@&StartTime1=%@&EndTime1=%@&StartTime2=%@&EndTime2=%@&StartTime3=%@&EndTime3=%@&StartTime4=%@&EndTime4=%@&StartTime5=%@&EndTime5=%@&StartTime6=%@&EndTime6=%@&StartTime7=%@&EndTime7=%@",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID],
                             strMonStart, strMonEnd,
                             strTueStart, strTueEnd,
                             strWedStart, strWedEnd,
                             strThuStart, strThuEnd,
                             strFriStart, strFriEnd,
                             strSatStart, strSatEnd,
                             strSunStart, strSunEnd
                             ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [CB_AlertView hideAlert];
             
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSDictionary *responseJson = [responseString JSONValue];
             
             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                 [self performSegueWithIdentifier:@"gotoprofile" sender:nil];
             }
             
//             URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Completed"
//                                                                   message:@"Your profile is completed!"
//                                                         cancelButtonTitle:@"OK"
//                                                         otherButtonTitles:nil, nil];
//             //	[alertView addButtonWithTitle:@"Close"];
//             //	[alertView addButtonWithTitle:@"OK"];
//             [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//                 NSLog(@"button tapped: index=%li", (long)buttonIndex);
//                 [alertView hideWithCompletionBlock:^{
//                     // stub
//                     if (buttonIndex == 0) { // OK
//                         dispatch_async(dispatch_get_main_queue(),^{
//                             
//                                                      });
//                     }
//                 }];
//             }];
//             [alertView showWithAnimation:URBAlertAnimationFlipHorizontal];

             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //              [MBProgressHUD hideHUDForView:self.view animated:YES];
             [CB_AlertView hideAlert];
         }];
}
- (IBAction)onChangeDatePicker:(id)sender {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSString * time = [formatter stringFromDate:((UIDatePicker*)sender).date];
    
    currentInputField.text = time;
}

- (void)showShoppingPicker:(UITextField *) textField {
//    if (m_isShowPicker) {
//        return;
//    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         bottomPicker.constant = 0;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = YES;
                         
                         NSString * time = textField.text;
                         NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                         [formatter setDateFormat:@"HH:mm"];
                         NSDate * dateTime = [formatter dateFromString:time];
                         
                         if (dateTime != nil) {
                             mDatePicker.date = dateTime;
                         }
                         else {
                             time = [formatter stringFromDate:mDatePicker.date];
                         }
                         
                         currentInputField = textField;
                         currentInputField.text = time;

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
                         currentInputField = nil;
                     }];
}

#pragma mark -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;

    [textField resignFirstResponder];
    
    shouldEdit = NO;
    
    currentInputField = textField;
    
    [self showShoppingPicker:textField];

    return shouldEdit;
}

#pragma mark keyboard
- (void) hideKeyboard :(UIGestureRecognizer*) gesture{
    [super hideKeyboard:gesture];
    
    if (m_isShowPicker) {
        [self hideShoppingPicker];
    }
}

@end
