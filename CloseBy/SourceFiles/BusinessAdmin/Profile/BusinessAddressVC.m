//
//  BusinessAddressVC.m
//  CloseBy
//
//  Created by iGold on 3/13/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BusinessAddressVC.h"

#import "SlideNavigationController.h"


@interface BusinessAddressVC ()
{

    IBOutlet UITextField *tfBusinessAddress;
}
@end


@implementation BusinessAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Business Address";
    
    [self getBusinessAddress];
}

- (void) getBusinessAddress
{
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/BusinessAddress.aspx?guid=%@&UserID=%@",
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
             
             if (responseJson != nil && [responseJson[@"Success" ] isEqualToString:@"Success"]) {
                 NSString * businessAddress = responseJson[@"Data"][@"BusinessAddress"];
                 
                 if (businessAddress != nil && ![businessAddress isKindOfClass:[NSNull class]]) {
                     tfBusinessAddress.text = businessAddress;
                 }
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [CB_AlertView hideAlert];
         }];
}

- (IBAction)onClickUpdate:(id)sender {
    
    NSString * address = tfBusinessAddress.text;
    
    if (address.length < 1) {
        [[iToast makeText:@"Please input address"] show];
        return;
    }

    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdateBusinessAddress.aspx?guid=%@&UserID=%@&NewAddress=%@",
                             kServerURL, kGUID,
                             [GlobalAPI loadLoginID],
                             address] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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

             URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Completed"
                                                                   message:@"Your profile is completed!"
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
             [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                 NSLog(@"button tapped: index=%li", (long)buttonIndex);
                 [alertView hideWithCompletionBlock:^{
                     // stub
                     if (buttonIndex == 0) { // OK
                         dispatch_async(dispatch_get_main_queue(),^{
                             
                             UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
                             [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                                      withSlideOutAnimation:YES
                                                                                              andCompletion:nil];

//                             [self.navigationController popToRootViewControllerAnimated:YES];
                         });
                     }
                 }];
             }];
             [alertView show];

         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [CB_AlertView hideAlert];
         }];

    
}
@end
