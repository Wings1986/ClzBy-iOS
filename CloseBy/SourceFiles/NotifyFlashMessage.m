//
//  NotifyFlashMessage.m
//  CloseBy
//
//  Created by iGold on 3/11/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "NotifyFlashMessage.h"

#import "AppDelegate.h"
#import "AddFlashMessageViewController.h"
#import "ProfileViewController.h"


#import <Haneke.h>
#import "SlideNavigationController.h"
#import "UIImage-Helpers.h"


@interface NotifyFlashMessage()
{
    
    IBOutlet UIImageView *ivBusinessLogo;
    IBOutlet UILabel *lbBusinessName;
    
    IBOutlet UIView *subView;
    IBOutlet UILabel *lbTitle;
    IBOutlet UILabel *lbTagline;
    IBOutlet UILabel *lbDescription;
    IBOutlet UIImageView *ivImage;
    IBOutlet UIImageView *ivBackImage;
    
    
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnFwd;
    
    IBOutlet NSLayoutConstraint *contraintTopHeight;
}
@end

@implementation NotifyFlashMessage

- (void) viewDidLoad
{
    [super viewDidLoad];

    contraintTopHeight.constant = 70.0f;
    if (_bMultiData) {
        contraintTopHeight.constant = 100.0; //70.0f;
    }
    
    [self configureNavigationBar];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_pageIndex == 0) {
        btnBack.hidden = YES;
    } else {
        btnBack.hidden = NO;
    }
    
    if (_pageIndex == _pageTotal -1) {
        btnFwd.hidden = YES;
    } else {
        btnFwd.hidden = NO;
    }
    
    [self setFlashBeaconData];
}

- (void) setFlashBeaconData
{
    NSLog(@"self.responseData = %@", self.responseData);
    
    subView.layer.cornerRadius = 15;
    subView.clipsToBounds = YES;
    subView.layer.borderColor = [UIColor colorWithRed:180.0f/255.0f green:180.0f/255.0f blue:180.0f/255.0f alpha:1.0f].CGColor;
    subView.layer.borderWidth = 1;
    
    
    lbTitle.text = self.responseData[@"MainTitle"];
    lbTagline.text = self.responseData[@"TagLine"];
    lbDescription.text = self.responseData[@"Description"];
    
    @try {
        ivBackImage.image = nil;
        ivImage.image = nil;
        
        NSString * url = [self.responseData[@"FlashImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ivImage hnk_setImageFromURL:[NSURL URLWithString:url] placeholder:nil success:^(UIImage *image) {
            
            // blur effect
            
            // jpeg quality image data
            float quality = .00001f;
            
            // intensity of blurred
            float blurred = .5f;

            NSData *imageData = UIImageJPEGRepresentation(image, quality);
            UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
            ivBackImage.image = blurredImage;

            ivImage.image = image;
            
        } failure:^(NSError *error) {
            
        }];

    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    // business info
    
    ivBusinessLogo.layer.cornerRadius = ivBusinessLogo.frame.size.width/2;
    ivBusinessLogo.clipsToBounds = YES;
    ivBusinessLogo.layer.borderColor = [UIColor whiteColor].CGColor;
    ivBusinessLogo.layer.borderWidth = 2;
    
    NSString * businessLogo = [self.responseData[@"BusinessLogo"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [ivBusinessLogo hnk_setImageFromURL:[NSURL URLWithString:businessLogo]];
    
    lbBusinessName.text = self.responseData[@"BusinessName"];

        

}

//- (void) getFlashBeaconData
//{
//    [CB_AlertView showAlertOnView:self.view];
//
//    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessBeaconData.aspx?guid=%@&BeaconUUID=%@&Major=%@&Minor=%@",
//                             kServerURL,
//                             kGUID,
//                             _beaconUUID,
//                             _beaconMajor,
//                             _beaconMinor] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    NSLog(@"request = %@", requestUrl);
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager GET:requestUrl
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             
//             [CB_AlertView hideAlert];
//             
//             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//             
//             notifyData = [responseString JSONValue];
//             
//             NSLog(@"response = %@", notifyData);
//
//             if (notifyData != nil) {
//                 
//                 if ([notifyData[@"Success"] isEqualToString:@"Success"]) {
//                     lbTitle.text = notifyData[@"Data"][@"MainTitle"];
//                     lbTagline.text = notifyData[@"Data"][@"TagLine"];
//                     lbDescription.text = notifyData[@"Data"][@"Description"];
//                     
//                     @try {
//                         NSString * url = [notifyData[@"Data"][@"FlashImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                         [ivImage hnk_setImageFromURL:[NSURL URLWithString:url]];
//                         
//                         ivImage.contentMode = UIViewContentModeScaleAspectFit;
//                     }
//                     @catch (NSException *exception) {
//                     }
//                     @finally {
//                     }
//                     //                 ivImage.image = [GlobalAPI dataFromBase64EncodedString:notifyData[@"FlashImage"]];
//                     
//                     return;
//   
//                 }
//             }
//             
//             URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Fail"
//                                                                   message:notifyData[@"Message"]
//                                                         cancelButtonTitle:@"OK"
//                                                         otherButtonTitles:nil, nil];
//             [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//                 [alertView hideWithCompletionBlock:^{
//                 }];
//             }];
//             [alertView show];
//             
//             
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             [CB_AlertView hideAlert];
//         }];
//    
//}


- (void)configureNavigationBar {

    if ([GlobalAPI isBusiness]) {
        UIButton * leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [leftButton setImage:[UIImage imageNamed:@"icon_edit.png"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }

    
    UIButton * rightBarbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBarbutton setImage:[UIImage imageNamed:@"icon_x.png"] forState:UIControlStateNormal];
    [rightBarbutton addTarget:self action:@selector(onClickClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarbutton];
    self.navigationItem.rightBarButtonItem = buttonItem;
}



- (void) onClickClose :(id) sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)onClickEdit:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        
        AddFlashMessageViewController *vc = (AddFlashMessageViewController*)[self.storyboard instantiateViewControllerWithIdentifier: @"AddFlashMessageViewController"];
        
        vc.m_bModalView = YES;
        vc.flashData = [[NSDictionary alloc] initWithDictionary:self.responseData];
        
        vc.beaconUUID = _beaconUUID;
        vc.beaconMajor = _beaconMajor;
        vc.beaconMinor = _beaconMinor;

        
//        AppDelegate * appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
//        [appDelegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
        
    }];

}

- (void) gotoProfile
{
    ProfileViewController *vc = (ProfileViewController*)[self.storyboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
    vc.businessUserID = self.responseData[@"BusinessProfile"][@"BusinessUserID"];
    
    if (![GlobalAPI isBusiness]) {
//        vc.responseData = self.responseData;
        vc.bShowEditButton = YES;
    }
    
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
}

- (IBAction)onTakeMeThere:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(takeMe:)]) {
        [self.delegate takeMe:_pageIndex];
        return;
    }

    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self gotoProfile];
        
    }];

}
- (IBAction)onClickBusinessPhone:(id)sender {
    
    NSString * BusinessContactNumber = self.responseData[@"BusinessContactNumber"];
    if (BusinessContactNumber == nil || BusinessContactNumber.length < 1) {
        return;
    }
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:BusinessContactNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)onClickBackward:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gotoBackward:)]) {
        [self.delegate gotoBackward:_pageIndex -1];
    }
}
- (IBAction)onClickForward:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gotoForward:)]) {
        [self.delegate gotoForward:_pageIndex +1];
    }
}

@end
