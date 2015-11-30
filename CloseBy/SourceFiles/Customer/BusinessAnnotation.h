//
//  BusinessAnnotation.h
//  CloseBy
//
//  Created by iGold on 4/14/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface BusinessAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSMutableDictionary *pinInfo;

- (id)initWithPinInfo:(NSMutableDictionary *)pinDic;

@end
