//
//  BusinessDescriptionVC.m
//  CloseBy
//
//  Created by iGold on 3/10/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BusinessDescriptionVC.h"

#import "SAMTextView.h"
@interface BusinessDescriptionVC()
{
    
    IBOutlet SAMTextView *tvDescription;
}
@end

@implementation BusinessDescriptionVC


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"Business Description";
    
    
    tvDescription.placeholder = @"Please enter description";
    tvDescription.text = @"";
    tvDescription.layer.cornerRadius = 5;
    tvDescription.layer.borderColor = APP_COLOR.CGColor;
    tvDescription.layer.borderWidth = 1;

    
    [CB_AlertView showAlertOnView:self.view];
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/Businessdesc.aspx?guid=%@&UserID=%@",
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
                 tvDescription.text = responseJson[@"Data"][@"Description"];
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //              [MBProgressHUD hideHUDForView:self.view animated:YES];
             [CB_AlertView hideAlert];
         }];
}
- (IBAction)onClickUpdate:(id)sender {
    NSString * description = tvDescription.text;
    if (description.length < 1) {
        [[iToast makeText:@"please input description"] show];
        return;
    }
    
    [CB_AlertView showAlertOnView:self.view];
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdateBusinessDesc.aspx?guid=%@&UserID=%@&DescText=%@",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID],
                             description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [CB_AlertView hideAlert];
             
             [[iToast makeText:@"please input description"] show];
             
             [self performSegueWithIdentifier:@"gotooperationhours" sender:nil];
             
             return;
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //              [MBProgressHUD hideHUDForView:self.view animated:YES];
             [CB_AlertView hideAlert];
         }];
}

@end
