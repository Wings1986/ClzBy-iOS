//
//  AddFlashMessageViewController.m
//  CloseBy
//
//  Created by iGold on 3/11/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "AddFlashMessageViewController.h"

#import <Haneke.h>
#import "SlideNavigationController.h"


@interface AddFlashMessageViewController()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    
    IBOutlet UITextField *tfMainTitle;
    IBOutlet UITextField *tfTagLine;
    IBOutlet UITextField *tfDescription;
    IBOutlet UIImageView * ivImage;
}
@end


@implementation AddFlashMessageViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Flash Special";

    if (_m_bModalView) {
        
        UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBack.frame = CGRectMake(0, 0, 30, 30);
        [btnBack setImage:[UIImage imageNamed:@"circle_back_btn.png"] forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchUpInside];
        
//        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"<"
//                                                                       style:UIBarButtonItemStyleBordered
//                                                                      target:self
//                                                                      action:@selector(handleBack:)];
        UIBarButtonItem * backBar = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
        
        self.navigationItem.leftBarButtonItem = backBar;
    }
    
    if (_flashData != nil) {
   
        tfMainTitle.text = _flashData[@"MainTitle"];
        tfTagLine.text = _flashData[@"TagLine"];
        tfDescription.text = _flashData[@"Description"];
        
        @try {
            NSString * url = [_flashData[@"FlashImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [ivImage hnk_setImageFromURL:[NSURL URLWithString:url]];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
//        ivImage.image = [GlobalAPI dataFromBase64EncodedString:_flashData[@"FlashImage"]];
        
    }
    else {
        self.title = @"Add Flash Message";
        
        [self getFlashBeaconData];
    }
}

- (void) handleBack:(id)sender
{
    // pop to root view controller
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"BeaconsViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];

}

- (void) getFlashBeaconData
{
    [CB_AlertView showAlertOnView:self.view];
    
    NSLog(@"uuid = %@ major = %@, minor = %@", _beaconUUID, _beaconMajor, _beaconMinor);

    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessBeaconData.aspx?guid=%@&BeaconUUID=%@&Major=%@&Minor=%@",
                             kServerURL,
                             kGUID,
                             _beaconUUID,
                             _beaconMajor,
                             _beaconMinor                             
                             ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             [CB_AlertView hideAlert];
             
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             NSDictionary * notifyData = [responseString JSONValue];
             
             NSLog(@"response = %@", notifyData);
             
             if (notifyData != nil) {
                 
                 if ([notifyData[@"Success"] isEqualToString:@"Success"]) {
                     
                     self.title = @"Update Flash Message";
                     
                     tfMainTitle.text = notifyData[@"Data"][@"MainTitle"];
                     tfTagLine.text = notifyData[@"Data"][@"TagLine"];
                     tfDescription.text = notifyData[@"Data"][@"Description"];
                     
                     @try {
                         NSString * url = [notifyData[@"Data"][@"FlashImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                         [ivImage hnk_setImageFromURL:[NSURL URLWithString:url]];
                     }
                     @catch (NSException *exception) {
                         NSLog(@"%@", exception.description);
                     }
                     @finally {
                     }
                     
                     return;
                     
                 }
             }
             
             URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Fail"
                                                                   message:notifyData[@"Message"]
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
             [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                 [alertView hideWithCompletionBlock:^{
                     [self.navigationController popViewControllerAnimated:YES];
                 }];
             }];
             [alertView show];
             
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [CB_AlertView hideAlert];
         }];
    
}



- (IBAction)onClickSave:(id)sender {
    NSString * mainTitle = tfMainTitle.text;
    NSString * tagLine = tfTagLine.text;
    NSString * description = tfDescription.text;
    
    if (mainTitle.length < 1) {
        [[iToast makeText:@"Please input main title"] show];
        return;
    }
    if (tagLine.length < 1) {
        [[iToast makeText:@"Please input tag line"] show];
        return;
    }
    if (description.length < 1) {
        [[iToast makeText:@"Please input description"] show];
        return;
    }
    if (ivImage.image == nil) {
        [[iToast makeText:@"Please choose photo"] show];
        return;
    }

    
    [CB_AlertView showAlertOnView:self.view];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/UpdateBusinessBeaconFlashMessage.aspx", kServerURL]]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:kGUID forKey:@"guid"];
    [parameters setObject:[GlobalAPI loadLoginID] forKey:@"UserID"];
    [parameters setObject:_beaconUUID forKey:@"BeaconUUID"];
    [parameters setObject:_beaconMajor forKey:@"Major"];
    [parameters setObject:_beaconMinor forKey:@"Minor"];
    
    
    [parameters setObject:@"2" forKey:@"BeaconTypeID"];
    
    [parameters setObject:mainTitle forKey:@"MainTitle"];
    [parameters setObject:tagLine forKey:@"TagLine"];
    [parameters setObject:description forKey:@"Description"];
    
    NSString *imageData = [GlobalAPI base64StringForImage:ivImage.image];
    if (imageData) {
        [parameters setObject:imageData forKey:@"FlashImage"];
    }

    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *op = [manager POST:@"" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [CB_AlertView hideAlert];
        
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary * responseJson = [responseString JSONValue];
        
        NSLog(@"response = %@", responseJson);
        
        if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
            
            [self handleBack:nil];
//            if (!_m_bModalView) {
//                UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"BeaconsViewController"];
//                [self.navigationController popToViewController:vc animated:YES];
//            }
//            else {
//                [self handleBack:nil];
//            }
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
}

- (IBAction)onChoosePhoto:(id)sender {
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

- (void) showImagePicker:(NSNumber*) opt
{
    if ([opt intValue] == 1) { // roll
        
    }
    else { // camera

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
