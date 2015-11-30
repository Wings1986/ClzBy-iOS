//
//  ProfileMapCollectionViewCell.h
//  CloseBy
//
//  Created by iGold on 8/21/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "BusinessAnnotation.h"

@interface ProfileMapCollectionViewCell : UICollectionViewCell<MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mMapView;

- (void) gotoMap:(NSDictionary*) dic;

@end
