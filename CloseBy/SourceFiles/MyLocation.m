//
//  MyLocation.m
//  BookingApp
//
//  Created by iGold on 1/14/15.
//  Copyright (c) 2015 Mark. All rights reserved.
//

#import "MyLocation.h"

#define FEQUAL(a,b)     (fabs((a) - (b)) < FLT_EPSILON)


static MyLocation * instance = nil;


@interface MyLocation ()
@property (strong, nonatomic) CLLocationManager *locManager;
@end


@implementation MyLocation

+ (MyLocation *)sharedInstance
{
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    
    return instance;
}

- (void) start
{
    self.locManager = [[CLLocationManager alloc] init];
    [self.locManager setDelegate:self];
    
    self.locManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locManager.distanceFilter = 400;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locManager requestAlwaysAuthorization];
    }
    
    [self.locManager startUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    if (!newLocation) {
        return;
    }

    if (self.curLocation == nil) {
        self.curLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];

        return;
    }
    
    CLLocationCoordinate2D oldCoordinate = self.curLocation.coordinate;
    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
    
    if (!FEQUAL(oldCoordinate.latitude, newCoordinate.latitude) || !FEQUAL(oldCoordinate.longitude, newCoordinate.longitude)) {
        NSLog(@"location didUpdateToLocation =====");
       
        self.curLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location fail : %@", error);
}

- (float) getCurLatitude
{
#ifdef DEBUG
    
    return -27.493858f;
    
#else
    
    if (self.curLocation == nil) {
        return 0.0f;
    }
    else {
        return self.curLocation.coordinate.latitude;
    }
    
#endif
    
}
- (float) getCurLongitude
{
#ifdef DEBUG
    
    return 153.042590f;
    
#else

    if (self.curLocation == nil) {
        return 0.0f;
    }
    else {
        return self.curLocation.coordinate.longitude;
    }
    
    
#endif

}

@end
