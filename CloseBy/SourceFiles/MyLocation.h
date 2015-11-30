//
//  MyLocation.h
//  BookingApp
//
//  Created by iGold on 1/14/15.
//  Copyright (c) 2015 Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface MyLocation : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocation *curLocation;

+ (MyLocation *) sharedInstance;
- (void) start;

- (float) getCurLatitude;
- (float) getCurLongitude;

@end
