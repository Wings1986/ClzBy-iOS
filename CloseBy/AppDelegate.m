//
//  AppDelegate.m
//  CloseBy
//
//  Created by daniel on 12/15/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "AppDelegate.h"
#import "CRToast.h"

#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"
#import "RootViewController.h"
#import "NotifyFlashMessage.h"
#import "ProfileViewController.h"



@interface AppDelegate ()<ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSArray *beaconsArray;

@property (nonatomic, strong) NSDictionary* businessTestBeacon;
@property (nonatomic, strong) NSMutableArray *detectedBeaconList;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0f/255.0f green:163.0f/255.0f blue:232.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,
      nil]];
    

    NSLog(@"ESTAppDelegate: APP ID and APP TOKEN are required to connect to your beacons and make Estimote API calls.");
    [ESTCloudManager setupAppID:nil andAppToken:nil];
    
    // Estimote Analytics allows you to log activity related to monitoring mechanism.
    // At the current stage it is possible to log all enter/exit events when monitoring
    // Particular beacons (Proximity UUID, Major, Minor values needs to be provided).
    
    NSLog(@"ESTAppDelegate: Analytics are turned OFF by defaults. You can enable them changing flag");
    [ESTCloudManager enableMonitoringAnalytics:NO];
    [ESTCloudManager enableGPSPositioningForAnalytics:NO];
    
    
    [FBLoginView class];
    [FBProfilePictureView class];
    
    // locatin enable
    [[MyLocation sharedInstance] start];
    
    // push notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

    // local notification
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        
    }
    
    
    if ([GlobalAPI loadLoginID] != nil && [GlobalAPI loadLoginID].length > 0)
    {
        [self gotoHomeScreen:NO];
    }
    
    return YES;
}

- (void) gotoHomeScreen:(BOOL) signup
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    SlideNavigationController *navController = (SlideNavigationController*)[mainStoryboard
                                                                            instantiateViewControllerWithIdentifier: @"SlideNavigationController"];
    
    if ([GlobalAPI isBusiness]) {
        
        UIViewController * vc;
        if (signup) { // profile
            ProfileViewController* vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ProfileViewController"];
            vc.bShowEditButton = YES;
        
            [navController popToRootAndSwitchToViewController:vc
                                        withSlideOutAnimation:YES
                                                andCompletion:nil];

        } else { // inventory
            vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"InventoryViewController"];

            [navController popToRootAndSwitchToViewController:vc
                                        withSlideOutAnimation:YES
                                                andCompletion:nil];

        }
        

    }
    
    LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
    
    
    navController.leftMenu = leftMenu;
    navController.rightMenu = NULL;
    //    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    //    [SlideNavigationController sharedInstance].rightMenu = NULL;
    
    //    // Creating a custom bar button for right menu
    //    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    [button setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    //    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleRightMenu) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //    [SlideNavigationController sharedInstance].rightBarButtonItem = rightBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];

    
#if TARGET_IPHONE_SIMULATOR
    
#else
    
    [self setupBeacon];
    
#endif
    

    self.window.rootViewController = navController;
    
}
- (void) logOut {
    [GlobalAPI storeLoginID:@""];
    [GlobalAPI storeUserType:NO];
    [GlobalAPI storeUserImage:nil];
    [GlobalAPI storeUsername:@""];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    RootViewController * rootViewController = (RootViewController* ) [mainStoryboard
                                                                      instantiateViewControllerWithIdentifier: @"RootViewController"];
    
    self.window.rootViewController = rootViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
//        [self openActiveSessionWithPermissions:nil allowLoginUI:NO];
//    }
    
    [FBAppCall handleDidBecomeActive];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI{
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      // Create a NSDictionary object and set the parameter values.
                                      NSDictionary *sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                        session, @"session",
                                                                        [NSNumber numberWithInteger:status], @"state",
                                                                        error, @"error",
                                                                        nil];
                                      
                                      // Create a new notification, add the sessionStateInfo dictionary to it and post it.
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionStateChangeNotification"
                                                                                          object:nil
                                                                                        userInfo:sessionStateInfo];
                                      
                                  }];
}
/*
#pragma mark - PushNotification Methods

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSLog(@"Final Token: %@", hexToken);
//    [UIAlertView showAlertWithTitle:@"Token" message:hexToken delegate:nil cancelButton:@"Ok" otherButtons:nil];
    [GlobalAPI saveOldDeviceToken:hexToken];
    
    
    
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (NSDictionary*)optionsWithMessage:(NSString*)message {
    
    NSMutableDictionary *options = [@{
                                      kCRToastNotificationTypeKey: @(CRToastTypeNavigationBar),
                                      kCRToastTextKey : message,
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor blueColor],
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                                      } mutableCopy];
    
    options[kCRToastInteractionRespondersKey] = @[[CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                                                                  automaticallyDismiss:YES
                                                                                                                 block:^(CRToastInteractionType interactionType){
                                                                                                                     NSLog(@"Dismissed with %@ interaction", NSStringFromCRToastInteractionType(interactionType));
                                                                                                                 }]];
    
    return options;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    //    [self addMessageFromRemoteNotification:userInfo updateUI:YES];
    
    if ([GlobalAPI getMerchantLogin]) {
        
        [CRToastManager showNotificationWithOptions:[self optionsWithMessage:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]]
                                     apperanceBlock:^(void) {
                                         NSLog(@"Appeared");
                                     }
                                    completionBlock:^(void) {
                                        NSLog(@"Completed");
                                    }];

//        [AGPushNoteView showWithNotificationMessage:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]];
//        
//        [AGPushNoteView setMessageAction:^(NSString *message) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PUSH"
//                                                                    message:message
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"Close"
//                                                          otherButtonTitles:nil];
//                    [alert show];
//            [self openStoreEventControllerWithNotificationInfo:userInfo];
//        }];

    }
}
*/

#pragma mark - Beacon
- (void) setupBeacon
{
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.returnAllRangedBeaconsAtOnce = YES;
    
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"ClosebyRegion"];
    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */

    [self startRangingBeacons];
}

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self startRangingBeacons];
}

-(void)startRangingBeacons
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.beaconManager requestAlwaysAuthorization];
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

#pragma mark beacon delegate

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
//    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Ranging error"
//                                                        message:error.localizedDescription
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//    
//    [errorView show];
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
//    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
//                                                        message:error.localizedDescription
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//    
//    [errorView show];
}


- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
//    static long count = 0;
//    NSLog(@"beacon count: %lu", count++);
//    
//    for (ESTBeacon * estBeacon in beacons) {
//        NSLog(@"detected beacon major = %lu, proximity = %ld, distance = %f",
//              (unsigned long)[estBeacon.major unsignedIntegerValue],
//              (long)estBeacon.proximity,
//              [estBeacon.distance floatValue]);
//    }
    
    
//    if ([GlobalAPI isBusiness]) {
//        self.beaconsArray = nil;
//        return;
//    }
    
    
    if (![GlobalAPI isBusiness] && ([GlobalAPI loadLoginID] != NULL && [GlobalAPI loadLoginID].length > 0)) {
        
        [self checkEnterExitBeaconsforCustomer:beacons];
        
    }
    
    if (beacons.count == 0) {
        self.beaconsArray = nil;
        return;
    }
    
    _beaconsArray = beacons;

    
    [self checkRSSI];

    
/*
    if (beacons.count != 0) {
        
        ESTBeacon *firstBeacon = [beacons firstObject];
        
        if ((self.beacon == nil && firstBeacon != nil)
            || ![firstBeacon.major isEqualToNumber:self.beacon.major]
            || ![firstBeacon.minor isEqualToNumber:self.beacon.minor]) {
            
            self.beacon = firstBeacon;
            
                    ESTBeaconManager *beaconManager = [[ESTBeaconManager alloc] init];
                    beaconManager.delegate = self;
            
            
            NSLog(@"UUID = %@", self.beacon.proximityUUID);
            NSLog(@"major = %d", [self.beacon.major unsignedIntValue]);
            NSLog(@"minor = %d", [self.beacon.minor unsignedIntValue]);
            
                    ESTBeaconRegion * beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.beacon.proximityUUID
                                                                                 major:[self.beacon.major unsignedIntValue]
                                                                                 minor:[self.beacon.minor unsignedIntValue]
                                                                            identifier:@"RegionIdentifier"
                                                                               secured:self.beacon.isSecured];
            
                    beaconRegion.notifyOnEntry = YES;
                    beaconRegion.notifyOnExit = YES;
            
                    [beaconManager startMonitoringForRegion:self.beaconRegion];
            
        }
        
    }
*/
    
}

//- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
//{
//    self.beaconsArray = beacons;
//    
//}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region
{
    NSLog(@"Enter region notification");
    
    [self checkBeacon:_businessTestBeacon];
    
//    if ([self checkBeacon:_beaconData]) {
//        UILocalNotification *notification = [UILocalNotification new];
//        notification.alertBody = @"Beacon notificaton";
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//    }
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region
{
    NSLog(@"Exit region notification");
    
//    NSArray * beacons =  [ESTBeaconManager recentlyCachedBeacons];
//    for (ESTBeaconVO * beaconVO in beacons) {
//        [self postExitRegionRequest:beaconVO.UUID major:beaconVO.major minor:beaconVO.minor];
//    }
    
//    UILocalNotification *notification = [UILocalNotification new];
//    notification.alertBody = @"Exit region notification";
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark 

- (void) setupBeaconBusiness:(NSDictionary *) beaconData
{
    // click test beacon for business
    
    _businessTestBeacon = beaconData;
    
    
    
    NSString* beaconUUID = beaconData[@"BeaconUUID"]; //@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"; //beaconData[@"BeaconUUID"];
    
    ESTBeaconManager *beaconManager = [[ESTBeaconManager alloc] init];
    beaconManager.delegate = self;
    

    NSUUID * uuid = [[NSUUID UUID] initWithUUIDString:beaconUUID];
    CLBeaconMajorValue major = [beaconData[@"Major"] intValue];
    CLBeaconMinorValue minor = [beaconData[@"Minor"] intValue];
    CLBeaconRegion * beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                              major:major
                                                                              minor:minor
                                                                         identifier:@"RegionIdentifier"];
    
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    
    [beaconManager startMonitoringForRegion:beaconRegion];
}

#pragma mark beacon web service
- (BOOL) checkBeacon:(NSDictionary*) dic
{
    
    [CB_AlertView showAlertOnView:self.window];
    
    NSString *requestUrl;
    
    if ([GlobalAPI isBusiness]) {
        requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessBeaconData.aspx?guid=%@&BeaconUUID=%@&Major=%@&Minor=%@",
                       kServerURL,
                       kGUID,
                       dic[@"BeaconUUID"],
                       dic[@"Major"],
                       dic[@"Minor"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else {
        requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessBeaconData.aspx?guid=%@&BeaconUUID=%@&Major=%@&Minor=%@&UserID=%@",
                       kServerURL,
                       kGUID,
                       dic[@"BeaconUUID"],
                       dic[@"Major"],
                       dic[@"Minor"],
                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [CB_AlertView hideAlert];
             
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSDictionary *responseJson = [responseString JSONValue];
             
             NSLog(@"json data = %@", responseJson);
             
             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                 
                 NSString* beaconType = responseJson[@"BeaconType"];
                 
                 
                 if ([beaconType isEqualToString:@"1"]) { // notification profile
                     
                     UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                     
                     ProfileViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
                     vc.responseData = responseJson;
                     vc.bShowBackButton = YES;
                     
                     if ([GlobalAPI isBusiness]) {
                         vc.bShowEditButton = YES;
                     }
                     
                     UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
                     nav.navigationBar.translucent = NO;
                     [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
                     
                 }
                 
                 else if ([beaconType isEqualToString:@"2"]) { // notification flash message
                     
                     UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                     
                     NotifyFlashMessage *vc = (NotifyFlashMessage*)[mainStoryboard instantiateViewControllerWithIdentifier: @"NotifyFlashMessage"];
                     vc.beaconUUID = dic[@"BeaconUUID"];
                     vc.beaconMajor = dic[@"Major"];
                     vc.beaconMinor = dic[@"Minor"];
                     
                     vc.responseData = responseJson[@"Data"];
                     
                     UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
                     [nav.toolbar setTranslucent:NO];
                     [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
                     
                 }
                 else {
                     
                 }
                 
                 
                 // local notification
                 UILocalNotification *notification = [UILocalNotification new];
                 notification.alertBody = @"Beacon notificaton";
                 notification.soundName = UILocalNotificationDefaultSoundName;
                 [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                 
                 
             }
             else {
                 
//                 URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"New Beacon Detected"
//                                                                       message:responseJson[@"Message"]
//                                                             cancelButtonTitle:@"OK"
//                                                             otherButtonTitles:nil, nil];
//                 [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//
//                     [alertView hideWithCompletionBlock:^{
//                     }];
//                 }];
//                 [alertView show];
             }
             
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [CB_AlertView hideAlert];
         }];
    
    
    return NO;
}


- (NSArray*) getAllBeacons
{
    __block NSArray *arrayServerBeacons = nil;
    
    [CB_AlertView showAlertOnView:self.window];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessBeacons.aspx?guid=%@&UserID=%@",
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
             
             NSLog(@"json data = %@", responseJson);
             
             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                 arrayServerBeacons = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
             }
             else {
                 arrayServerBeacons = nil;
             }
             
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [CB_AlertView hideAlert];
         }];
    
    return arrayServerBeacons;
}

- (void) postExitRegionRequest:(NSString*) uuid major:(NSNumber*) major minor:(NSNumber*) minor
{
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/ExitBeaconRegion.aspx?guid=%@&BeaconUUID=%@&Major=%lu&Minor=%lu&UserID=%@&ExitUserLat=%f&ExitUserLong=%f",
                             kServerURL,
                             kGUID,
                             uuid,
                             (unsigned long)[major unsignedIntegerValue],
                             (unsigned long)[minor unsignedIntegerValue],
                             [GlobalAPI loadLoginID],
                             [MyLocation sharedInstance].getCurLatitude,
                             [MyLocation sharedInstance].getCurLongitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSDictionary *responseJson = [responseString JSONValue];
             
             NSLog(@"json data = %@", responseJson);
             
             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
             }
             
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [CB_AlertView hideAlert];
         }];
}

#pragma mark RSSI

- (void) checkEnterExitBeaconsforCustomer:(NSArray*) beacons
{
    
    NSMutableArray * arrayEnterBeacon = [NSMutableArray new];
    NSMutableArray * arrayExitBeacon = [NSMutableArray new];
    
    if (_detectedBeaconList == nil) {
        arrayEnterBeacon = [beacons mutableCopy];
    }
    else {
        
        // enter
        for (CLBeacon * beacon in beacons) {

            BOOL bExist = NO;

            for (CLBeacon * oldBeacon in _detectedBeaconList) {
                
                if ([oldBeacon.proximityUUID.UUIDString isEqualToString:beacon.proximityUUID.UUIDString]
                    && [oldBeacon.major isEqualToNumber:beacon.major]
                    && [oldBeacon.minor isEqualToNumber:beacon.minor]) {

                    bExist = YES;
                    break;
                }
            
            }
            
            if (!bExist) {
                [arrayEnterBeacon addObject:beacon];
            }
            
        }
        
        // exit
        for (CLBeacon * oldBeacon in _detectedBeaconList) {
            
            BOOL bExist = NO;
            
            for (CLBeacon * beacon in beacons) {
                
                if ([oldBeacon.proximityUUID.UUIDString isEqualToString:beacon.proximityUUID.UUIDString]
                    && [oldBeacon.major isEqualToNumber:beacon.major]
                    && [oldBeacon.minor isEqualToNumber:beacon.minor]) {
                    
                    bExist = YES;
                    break;
                }
                
            }
            
            if (!bExist) {
                [arrayExitBeacon addObject:oldBeacon];
            }
            
        }

    }
    
    
    
    for (CLBeacon * beacon in arrayEnterBeacon) {
        
        [self checkBeacon:@{
                            @"BeaconUUID": beacon.proximityUUID.UUIDString,
                            @"Major": [NSString stringWithFormat:@"%d", beacon.major.intValue],
                            @"Minor": [NSString stringWithFormat:@"%d", beacon.minor.intValue],
                            }];
    }
    for (CLBeacon * beacon in arrayExitBeacon) {
        
        [self postExitRegionRequest:beacon.proximityUUID.UUIDString
                              major:beacon.major
                              minor:beacon.minor];
        
    }
    
    
    _detectedBeaconList = [[NSMutableArray alloc] initWithArray:beacons];
    
    
    
}

#pragma mark - buffering setup
NSMutableArray * arryBuffer;
#define MAX_CACHE_BUFFER 10
- (CLBeacon*) bestMatching:(CLBeacon*) newBeacon
{
    
    if (arryBuffer == nil) {
        arryBuffer = [NSMutableArray new];
    }
    [arryBuffer addObject:newBeacon];
    
    if (arryBuffer.count > MAX_CACHE_BUFFER) {
        [arryBuffer removeObjectAtIndex:0];
    }
    
    NSMutableArray* sortArray = [NSMutableArray new];
    for (CLBeacon * cacheBeacon in arryBuffer) {

        BOOL isExist = NO;
        for (NSMutableDictionary* dic in sortArray) {
//            NSLog(@"%@", dic);
            if ([dic[@"UUID"] isEqualToString:cacheBeacon.proximityUUID.UUIDString]
                && [dic[@"Major"] isEqualToNumber:cacheBeacon.major]
                && [dic[@"Minor"] isEqualToNumber:cacheBeacon.minor]) {
                
                dic[@"Count"] = [NSNumber numberWithInt:[dic[@"Count"] intValue] + 1];
                isExist = YES;
                break;
            }
        }
        if (isExist == NO) {
            NSMutableDictionary * dic = [NSMutableDictionary new];
            dic[@"Count"]  = [NSNumber numberWithInt:1];
            dic[@"UUID"] = cacheBeacon.proximityUUID.UUIDString;
            dic[@"Major"] = cacheBeacon.major;
            dic[@"Minor"] = cacheBeacon.minor;
            dic[@"Beacon"] = cacheBeacon;
            
            [sortArray addObject:dic];
        }
    }
    
    [sortArray sortUsingComparator:^NSComparisonResult(NSDictionary * obj1, NSDictionary *obj2) {
     
        if ([obj1[@"Count"] intValue] > [obj2[@"Count"] intValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else if ([obj1[@"Count"] intValue] < [obj2[@"Count"] intValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else {
            return (NSComparisonResult)NSOrderedSame;
        }
            
    }];
    
    
    return [sortArray firstObject][@"Beacon"];
}

- (BOOL) isDetectedBeacon
{
    if (_beaconsArray == nil || _beaconsArray.count < 1) {
        return NO;
    }
    return YES;
}
- (void) checkRSSI
{

    CLBeacon * nearBeacon = _beaconsArray.firstObject;
    for (CLBeacon * beacon in _beaconsArray) {
        if (beacon.accuracy <= 0)
            continue;
        
        if (nearBeacon.accuracy > beacon.accuracy) {
            nearBeacon = beacon;
        }
    }
    
//    NSLog(@"near beacon major = %lu, proximity = %ld, distance = %f",
//          (unsigned long)[nearBeacon.major unsignedIntegerValue],
//          (long)nearBeacon.proximity,
//          nearBeacon.accuracy);

    CLBeacon * bestBeacon = [self bestMatching:nearBeacon];

//    NSLog(@"best beacon major = %lu, proximity = %ld, distance = %f",
//          (unsigned long)[bestBeacon.major unsignedIntegerValue],
//          (long)bestBeacon.proximity,
//          bestBeacon.accuracy);
    

    _activeBeacon = bestBeacon;
    

}
- (BOOL) isChangeBeacon:(CLBeacon*) beacon
{
    BOOL bChangedBeacon = NO;
    
    if (_activeBeacon != nil) {
        if ([beacon.proximityUUID.UUIDString isEqualToString:_activeBeacon.proximityUUID.UUIDString]
            && [beacon.major isEqualToNumber:_activeBeacon.major]
            && [beacon.minor isEqualToNumber:_activeBeacon.minor]) {
            bChangedBeacon = NO;
        }
        else {
            bChangedBeacon = YES;
        }
    }
    else {
        bChangedBeacon = YES;
    }
    
    return bChangedBeacon;
}


@end
