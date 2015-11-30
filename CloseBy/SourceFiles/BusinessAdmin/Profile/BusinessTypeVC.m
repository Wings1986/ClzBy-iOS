//
//  BusinessTypeVC.m
//  CloseBy
//
//  Created by iGold on 3/10/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BusinessTypeVC.h"

#import "TNRadioButtonGroup.h"

@interface BusinessTypeVC()
{
    TNRadioButtonGroup *radioGroup;
    
    int m_nCurrentType;
}
@end

@implementation BusinessTypeVC


-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Business Type";
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/BusinessType.aspx?guid=%@&userid=%@",
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
             
             NSDictionary * responseJson = [responseString JSONValue];
             
             NSLog(@"response = %@", responseJson);
             
             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                 int businessType = [responseJson[@"Data"][@"BusinessTypeID"] intValue];
                 
                 m_nCurrentType = businessType;
                 
                 [self createRadioButton:m_nCurrentType];
                 
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

- (void) createRadioButton:(int) indexSelected
{
    TNCircularRadioButtonData *radio1 = [TNCircularRadioButtonData new];
    radio1.labelText = @"Services";
    radio1.identifier = @"0";
    radio1.selected = indexSelected == 0 ? YES : NO;
    radio1.labelColor = APP_COLOR;
    radio1.borderColor = APP_COLOR;
    radio1.circleColor = APP_COLOR;
    radio1.borderRadius = 20;
    radio1.circleRadius = 10;
    
    
    TNCircularRadioButtonData *radio2 = [TNCircularRadioButtonData new];
    radio2.labelText = @"Products";
    radio2.identifier = @"1";
    radio2.selected = indexSelected == 1 ? YES : NO;
    radio2.labelColor = APP_COLOR;
    radio2.borderColor = APP_COLOR;
    radio2.circleColor = APP_COLOR;
    radio2.borderRadius = 20;
    radio2.circleRadius = 10;
    
    TNCircularRadioButtonData *radio3 = [TNCircularRadioButtonData new];
    radio3.labelText = @"Both products and services";
    radio3.identifier = @"2";
    radio3.selected = indexSelected == 2 ? YES : NO;
    radio3.labelColor = APP_COLOR;
    radio3.borderColor = APP_COLOR;
    radio3.circleColor = APP_COLOR;
    radio3.borderRadius = 20;
    radio3.circleRadius = 10;
    
    TNCircularRadioButtonData *radio4 = [TNCircularRadioButtonData new];
    radio4.labelText = @"NONE";
    radio4.identifier = @"3";
    radio4.selected = indexSelected == 3 ? YES : NO;
    radio4.labelColor = APP_COLOR;
    radio4.borderColor = APP_COLOR;
    radio4.circleColor = APP_COLOR;
    radio4.borderRadius = 20;
    radio4.circleRadius = 10;
    
    
    radioGroup = [[TNRadioButtonGroup alloc] initWithRadioButtonData:@[radio1, radio2, radio3, radio4] layout:TNRadioButtonGroupLayoutVertical];
    radioGroup.identifier = @"Sex group";
    [radioGroup create];
    radioGroup.position = CGPointMake(25, 25);
    [self.view addSubview:radioGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioGroupUpdated:) name:SELECTED_RADIO_BUTTON_CHANGED object:radioGroup];
    
    // show how update data works...
    //    [radioGroup update];
    
}

- (void)radioGroupUpdated:(NSNotification *)notification {
    NSLog(@"[MainView] Sex group updated to %@", radioGroup.selectedRadioButton.data.identifier);
    NSString * identifier = radioGroup.selectedRadioButton.data.identifier;
    
    m_nCurrentType = [identifier intValue];
}



- (IBAction)onClickUpdate:(id)sender {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdateBusinessType.aspx?guid=%@&userid=%@&NewBusinessType=%d",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID],
                             m_nCurrentType] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
                 
                 [self performSegueWithIdentifier:@"gotoprofiledescription" sender:nil];
                 
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
@end
