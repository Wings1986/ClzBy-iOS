//
//  LoginBaseViewController.m
//  CloseBy
//
//  Created by iGold on 3/2/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "LoginBaseViewController.h"

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation LoginBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 
- (void) requestLogin:(NSString*) email pwd:(NSString*) password
{
    [CB_AlertView showAlertOnView:self.view];
    NSString *requestCategoriesUrl = [NSString stringWithFormat:@"%@/ManualLogin.aspx?guid=%@&email=%@&password=%@"
                                      , kServerURL
                                      , kGUID
                                      , email
                                      , password
                                      ];
    
    NSLog(@"Login request = %@", requestCategoriesUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestCategoriesUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              
              NSDictionary *responseJson = [responseString JSONValue];
              
              NSLog(@"response = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  [GlobalAPI storeLoginID:responseJson[@"Data"][@"UserID"]];
                  [GlobalAPI storeUsername:responseJson[@"Data"][@"FullName"]];
                  [GlobalAPI storeUserType:[responseJson[@"Data"][@"IsBusiness"] boolValue]];
                  
                  
                  AppDelegate* delegate = [UIApplication sharedApplication].delegate;
                  [delegate gotoHomeScreen:NO];
              }
              else {
                  NSString * message = responseJson[@"message"];
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Login Fail"
                                                                        message:message
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
              //              [MBProgressHUD hideHUDForView:self.view animated:YES];
              [CB_AlertView hideAlert];
          }];
}

- (void) requestSkip
{
    [CB_AlertView showAlertOnView:self.view];
    NSString *requestCategoriesUrl = [NSString stringWithFormat:@"%@/SkipUser.aspx?guid=%@&Deviceid=%@"
                                      , kServerURL
                                      , kGUID
                                      , [self getMacAddress]
                                      ];
    
    NSLog(@"Login request = %@", requestCategoriesUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestCategoriesUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              
              NSDictionary *responseJson = [responseString JSONValue];
              
              NSLog(@"response = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  [GlobalAPI storeLoginID:responseJson[@"Data"][@"UserID"]];
                  [GlobalAPI storeUserType:[responseJson[@"Data"][@"IsBusiness"] boolValue]];
                  
                  
                  AppDelegate* delegate = [UIApplication sharedApplication].delegate;
                  [delegate gotoHomeScreen:NO];
              }
              else {
                  NSString * message = responseJson[@"message"];
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Login Fail"
                                                                        message:message
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
              //              [MBProgressHUD hideHUDForView:self.view animated:YES];
              [CB_AlertView hideAlert];
          }];
}


- (void) loginFacebook
{
    
    //    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends", @"user_birthday",@"manage_pages",@"publish_actions",@"publish_stream",@"photo_upload",nil];
    
    
    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", nil];
    
    if (FBSession.activeSession.state != FBSessionStateOpen) {
        
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          
//                                          [FBShareController sessionStateChanged:session state:state error:error];
                                          
                                          if (!error && state == FBSessionStateOpen) {
//                                              NSArray *permissiones = [FBSession activeSession].permissions;
//                                              for (NSString *permission in permissiones) {
//                                                  
//                                                  if ([permission isEqualToString:@"publish_actions"]) {
//                                                      
//                                                  }
//                                              }
                                              
                                              [self sendRequests];
                                          }
                                      }];
    } else {
        [self sendRequests];
    }
}

- (void)sendRequests
{
    
    NSDictionary * params = nil;
    
    [FBRequestConnection startWithGraphPath:@"/me"
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection * connect, id result, NSError* err) {
                              
                              NSLog(@"result = %@", result);
                              
                              [self loginWithData:result];
                              
                          }];
}

- (void) loginWithData:(NSDictionary*)result
{
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString * email = [result objectForKey:@"email"];
    NSString * password = @"123456";

    NSString *fbAccessToken = [FBSession activeSession].accessTokenData.accessToken;
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/AddUser.aspx?guid=%@&email=%@&password=%@&facebookid=%@&DeviceID=%@",
                            kServerURL,
                            kGUID,
                            email,
                            password,
                            fbAccessToken,
                            [self getMacAddress]];
    
    NSLog(@"Login request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              
              NSDictionary *responseJson = [responseString JSONValue];
              
              NSLog(@"response = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  [GlobalAPI storeLoginID:responseJson[@"Data"][@"UserID"]];
                  [GlobalAPI storeUserType:[responseJson[@"Data"][@"IsBusiness"] boolValue]];
                  [GlobalAPI storeUsername:responseJson[@"Data"][@"FullName"]];
                  
                  AppDelegate* delegate = [UIApplication sharedApplication].delegate;
                  [delegate gotoHomeScreen:NO];
              }
              else {
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Facebook Login Fail"
                                                                        message:@""
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
              //              [MBProgressHUD hideHUDForView:self.view animated:YES];
              [CB_AlertView hideAlert];
          }];
}

- (void) sendEmail
{
    NSString *subject = @"Support";
    
    NSArray* emails = @[@"support@clzby.com"
                         ];
    
    if(![MFMailComposeViewController canSendMail]){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please configure your mail settings to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:subject];
    [mc setToRecipients:emails];
    
    [self presentViewController:mc animated:YES completion:nil];

}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(NSString *)getMacAddress
{
/*
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        NSLog(@"Mac Address: %@", macAddressString);
        
        // Release the buffer memory
        free(msgBuffer);
        
        return macAddressString;
    }
    
    // Error...
    NSLog(@"Error: %@", errorFlag);
    
    return errorFlag;
*/
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return @"";
}
@end
