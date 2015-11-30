//
//  AppDelegate.h
//  CloseBy
//
//  Created by daniel on 12/15/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import <EstimoteSDK/EstimoteSDK.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;

- (void) gotoHomeScreen:(BOOL) signup;
- (void) logOut;


#pragma mark - RSSI
@property (nonatomic, strong) CLBeacon *activeBeacon;

- (BOOL) isChangeBeacon:(CLBeacon*) beacon;

- (BOOL) isDetectedBeacon;
- (void) checkRSSI;

#pragma mark - Beacon
- (void) setupBeaconBusiness:(NSDictionary *) beaconData;
- (BOOL) checkBeacon:(NSDictionary*) dic;


@end

