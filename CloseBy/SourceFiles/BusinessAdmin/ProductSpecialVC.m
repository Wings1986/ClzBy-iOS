//
//  ProductSpecialVC.m
//  CloseBy
//
//  Created by iGold on 3/13/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "ProductSpecialVC.h"

@interface ProductSpecialVC()
{
    
    IBOutlet UITextField *tfTagline;
    IBOutlet UITextField *tfQuantity;
}
@end


@implementation ProductSpecialVC
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"productData = %@", _producteData);
    
    if (_producteData != nil) {
        tfTagline.text = _producteData[@"DiscountedTagLing"];
        
        NSNumber* quantity = _producteData[@"QuantityRemaining"];
        if (quantity != nil  && ![quantity isKindOfClass:[NSNull class]]) {
            tfQuantity.text = [NSString stringWithFormat:@"%d", [quantity intValue]];
        }
    }
    
}
- (IBAction)onClickSave:(id)sender {
    
    NSString * tagline = tfTagline.text;
    if (tagline.length < 1) {
        [[iToast makeText:@"Please input tag line"] show];
        return;
    }

    
    NSString * quantity = tfQuantity.text;
    if (quantity.length < 1) {
        [[iToast makeText:@"Please input Product Quantity"] show];
        return;
    }
    
    [super listSubviewsOfView:self.view];
    
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdateProductToDeal.aspx?guid=%@&UserID=%@&ProductID=%@&SpecialTagLine=%@&Quantity=%@",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID],
                             _producteData[@"ID"],
                             tagline,
                             quantity]
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
             
             if (responseJson != nil && ![[responseJson[@"Success"] uppercaseString] isEqualToString:@"FAIL"]) {
                 
                 URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Success"
                                                                       message:responseJson[@"Message"]
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil, nil];
                 [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                     [alertView hideWithCompletionBlock:^{

                         [self.navigationController popViewControllerAnimated:YES];
                         
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
@end
