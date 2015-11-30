//
//  BusinessAnnotation.m
//  CloseBy
//
//  Created by iGold on 4/14/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BusinessAnnotation.h"

@implementation BusinessAnnotation

- (id)initWithPinInfo:(NSMutableDictionary *)pinDic
{
    if ((self = [super init])) {
        self.pinInfo = pinDic;
        
        double lat = [pinDic[@"Latitude"] doubleValue];
        double lng = [pinDic[@"Longitude"] doubleValue];
        if (lat == 0) {
            lat = [pinDic[@"latitude"] doubleValue];
        }
        if (lng == 0) {
            lng = [pinDic[@"longitude"] doubleValue];
        }
        
        self.coordinate = CLLocationCoordinate2DMake(lat, lng);
        self.title = [pinDic objectForKey:@"BusinessName"];
        self.subtitle = [pinDic objectForKey:@"BusinessEmailAddress"];
    }
    
    return self;
}


@end
