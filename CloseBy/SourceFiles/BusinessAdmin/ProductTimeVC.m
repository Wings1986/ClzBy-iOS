//
//  ProductTimeVC.m
//  CloseBy
//
//  Created by iGold on 3/13/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "ProductTimeVC.h"

#import "DropDownListView.h"

@interface ProductTimeVC()<UIPickerViewDataSource, UIPickerViewDelegate, kDropDownListViewDelegate>
{
    
    IBOutlet UITextField *tfDiscountTagline;
    IBOutlet UITextField *tfQuantity;
    IBOutlet UITextField *tfPrice;
    IBOutlet UITextField *tfDuration;
    
    IBOutlet UIPickerView *mPickerView;
    IBOutlet NSLayoutConstraint *constraintBottomPicker;
    BOOL m_isShowPicker;
    
    NSMutableArray * arrayTime;
    int     selectedIndexTime;
    NSMutableArray * arraySelectedIndexTime;
    
    DropDownListView * Dropobj;
}

@end
@implementation ProductTimeVC


-(void) viewDidLoad
{
    [super viewDidLoad];
    
    selectedIndexTime = 0;
    constraintBottomPicker.constant = -180.0f;
    m_isShowPicker = NO;
    

    if (_producteData != nil) {
        
        tfDiscountTagline.text = _producteData[@"DiscountedTagLing"];
        
        NSNumber* quantity = _producteData[@"QuantityRemaining"];
        if (quantity != nil && ![quantity isKindOfClass:[NSNull class]]) {
            tfQuantity.text = [NSString stringWithFormat:@"%d", [quantity intValue]];
        }

        
        NSNumber* price = _producteData[@"SpecialPrice"];
        if (price != nil && ![price isKindOfClass:[NSNull class]]) {
            tfPrice.text = [NSString stringWithFormat:@"%d", [price intValue]];
        }
    }
    
    
    arraySelectedIndexTime = [NSMutableArray new];
    
    [self getTimes];
}

- (void) getTimes
{
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetTimeDurationList.aspx?guid=%@",
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
                 arrayTime = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                 
                 [mPickerView reloadAllComponents];
                 
                 if (arrayTime != nil && arrayTime.count > 0) {
                     
                     if (_producteData != nil) {
                         
                         NSNumber* DecayDuration = _producteData[@"DecayDuration"];
                         if (DecayDuration != nil && ![DecayDuration isKindOfClass:[NSNull class]]) {
                             
                             selectedIndexTime = 0;
                             for (NSDictionary * dic in arrayTime) {
                                 if ([dic[@"Timeslot"] isEqualToNumber:DecayDuration]) {
                                     break;
                                 }
                                 selectedIndexTime ++;
                             }
                             
                         }

                     }
                     
                     if (selectedIndexTime >= arrayTime.count) {
                         selectedIndexTime = 0;
                     }
                     
                     tfDuration.text = arrayTime[selectedIndexTime][@"Text"];
                     
                 }
                 
             }
             
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [CB_AlertView hideAlert];
         }];
}
- (IBAction)onClickSave:(id)sender {
    
    NSString * discountTagline = tfDiscountTagline.text;
    if (discountTagline.length < 1) {
        [[iToast makeText:@"Please input Product Tagline"] show];
        return;
    }
    NSString * quantity = tfQuantity.text;
    if (quantity.length < 1) {
        [[iToast makeText:@"Please input Product Quantity"] show];
        return;
    }
    NSString * price = tfPrice.text;
    if (price.length < 1) {
        [[iToast makeText:@"Please input price"] show];
        return;
    }

    if (tfDuration.text.length < 1) {
        [[iToast makeText:@"Please input duration"] show];
        return;
    }
    
    
    NSIndexPath *obj = [arraySelectedIndexTime firstObject];
    int duration = [arrayTime[obj.row][@"Timeslot"] intValue];
    
    
    [super listSubviewsOfView:self.view];
    [self hidePicker];
    
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdateProductToTimeDecayingDeal.aspx?guid=%@&UserID=%@&ProductID=%@&SpecialTagLine=%@&Quantity=%@&SpecialPrice=%@&Duration=%d",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID],
                             _producteData[@"ID"],
                             discountTagline,
                             quantity,
                             price,
                             duration ]
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


- (void)showPicker {
    if (arrayTime == nil) {
        return;
    }
//    if (m_isShowPicker) {
//        return;
//    }
    
    
    [self.view removeGestureRecognizer:tapGesture];
    
    Dropobj = [[DropDownListView alloc] initWithTitle:@"DEAL RUNNING TIME" options:arrayTime indexData:arraySelectedIndexTime key:@"Text" xy:CGPointMake(50, 60) size:CGSizeMake(220, 300) isMultiple:NO];
    Dropobj.delegate = self;
    [Dropobj showInView:self.view animated:YES];
    
    m_isShowPicker = YES;
    
//    [UIView animateWithDuration:1.0
//                     animations:^{
//                         constraintBottomPicker.constant = 0;
//                     }
//                     completion:^(BOOL finished){
//                         m_isShowPicker = YES;
//                         
//                         if (selectedIndexTime != -1 && arrayTime.count > 0) {
//                             
//                             tfDuration.text = arrayTime[selectedIndexTime][@"Text"];
//                             
//                             [mPickerView selectRow:selectedIndexTime inComponent:0 animated:YES];
//                         }
//                     }];
}
- (void)hidePicker {
//    if (!m_isShowPicker) {
//        return;
//    }
    
    [self.view addGestureRecognizer:tapGesture];
    
    [Dropobj fadeOut];

//    [UIView animateWithDuration:1.0
//                     animations:^{
//                         constraintBottomPicker.constant = -180;
//                     }
//                     completion:^(BOOL finished){
//                         m_isShowPicker = NO;
//                     }];
}


- (void)DropDownListView:(DropDownListView *)dropdownListView indexlist:(NSMutableArray *)indexData {
    
    arraySelectedIndexTime = [indexData mutableCopy];
    
    NSString * strCategory = @"";
    
    int count = 0;
    for (NSIndexPath *obj in arraySelectedIndexTime) {

        strCategory = arrayTime[obj.row][@"Text"];
        
        count  ++;
    }
    
    tfDuration.text = strCategory;
    
    [self.view addGestureRecognizer:tapGesture];
}



#pragma mark -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
    
    if ([textField isEqual:tfDuration]) {
        
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
    if (arrayTime == NULL) {
        return 0;
    }
    return arrayTime.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString * title = arrayTime[row][@"Text"];
    return title;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedIndexTime = (int)row;
    tfDuration.text = arrayTime[row][@"Text"];
}

#pragma mark keyboard
- (void) hideKeyboard :(UIGestureRecognizer*) gesture{
    [super hideKeyboard:gesture];
    
    if (m_isShowPicker) {
        [self hidePicker];
    }
}
@end
