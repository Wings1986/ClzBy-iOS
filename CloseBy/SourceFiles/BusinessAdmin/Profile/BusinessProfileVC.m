//
//  BusinessProfileVC.m
//  CloseBy
//
//  Created by iGold on 3/13/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BusinessProfileVC.h"

#import <Haneke.h>

@interface BusinessProfileVC()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UITextField *tfFullName;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
    IBOutlet UITextField *tfNumber;
    
    IBOutlet UIImageView *ivImage;
}

@end


@implementation BusinessProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Business Profile";
    

    ivImage.layer.cornerRadius = ivImage.frame.size.width/2;
    ivImage.layer.borderWidth = 1;
    ivImage.layer.borderColor = APP_COLOR.CGColor;
    ivImage.clipsToBounds = YES;
    
    [self getBusinessProfile];
}

- (void) getBusinessProfile
{
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/PersonalProfile.aspx?guid=%@&UserID=%@",
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
                 tfFullName.text = responseJson[@"Data"][@"FullName"];
                 tfEmail.text = responseJson[@"Data"][@"EmailAddress"];
                 tfPassword.text = responseJson[@"Data"][@"Password"];
                 tfNumber.text = responseJson[@"Data"][@"ContactNumber"];
                 
                 
                 @try {
                     NSString * url = [responseJson[@"Data"][@"BusinessLogoPath"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                     [ivImage hnk_setImageFromURL:[NSURL URLWithString:url]];
                 }
                 @catch (NSException *exception) {
                     NSLog(@"%@", exception.description);
                     [ivImage setImage:[UIImage imageNamed:@"logo_business.png"]];
                 }
                 @finally {
                 }
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

- (IBAction)onClickUpdate:(id)sender {
    
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
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/UpdatePersonalProfile.aspx", kServerURL]]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:kGUID forKey:@"guid"];
    [parameters setObject:[GlobalAPI loadLoginID] forKey:@"UserID"];
    [parameters setObject:fullName forKey:@"FullName"];
    [parameters setObject:email forKey:@"EmailAddress"];
    [parameters setObject:password forKey:@"Password"];
    [parameters setObject:contactNumber forKey:@"ContactNumber"];
    
    NSString *imageData = [GlobalAPI base64StringForImage:ivImage.image];
    if (imageData) {
        [parameters setObject:imageData forKey:@"BusinessLogo"];
    }
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *op = [manager POST:@"" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [CB_AlertView hideAlert];
        
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"response = %@", responseString);
        
        NSDictionary *responseJson = [responseString JSONValue];
        
        if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
            
            NSString * imageUrl = responseJson[@"BusinessLogoPathSmall"];
            
            [GlobalAPI storeUsername:fullName];
            [GlobalAPI storeUserImage:imageUrl];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notification_change_profile" object:imageUrl];
            
            [self performSegueWithIdentifier:@"gotobusinessaddress" sender:nil];
            
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [CB_AlertView hideAlert];
    }];
    [op start];
    
    
    
    
    
    
//    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdatePersonalProfile.aspx?guid=%@&UserID=%@&FullName=%@&EmailAddress=%@&Password=%@&ContactNumber=%@&BusinessLogo=%@",
//                                       kServerURL, kGUID,
//                             [GlobalAPI loadLoginID],
//                             fullName, email, password, contactNumber,
//                             [GlobalAPI base64StringForImage:ivImage.image]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    NSLog(@"request = %@", requestUrl);
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager GET:requestUrl
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             [CB_AlertView hideAlert];
//             
//             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//             NSDictionary *responseJson = [responseString JSONValue];
//             
//             NSLog(@"response = %@", responseJson);
//             
//             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
//             
//                 NSString * imageUrl = responseJson[@"BusinessLogoPathSmall"];
//                 
//                 [GlobalAPI storeUsername:fullName];
//                 [GlobalAPI storeUserImage:imageUrl];
//                 
//                 [[NSNotificationCenter defaultCenter] postNotificationName:@"notification_change_profile" object:imageUrl];
//                 
//                 [self performSegueWithIdentifier:@"gotobusinessaddress" sender:nil];
//             }
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             [CB_AlertView hideAlert];
//         }];
    
}
- (IBAction)onTapPhoto:(id)sender {
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Choose Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll", @"New Picture", nil];
    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // camera roll
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [imagePicker setAllowsEditing:YES];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if (buttonIndex == 1) {//new picture
        //        [self performSelector:@selector(showImagePicker:) withObject:[NSNumber numberWithInt:2] afterDelay:0.3];
        if( ![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            return;
        
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [imagePicker setShowsCameraControls:YES];
        [imagePicker setAllowsEditing:YES];
        
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    ivImage.image = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
