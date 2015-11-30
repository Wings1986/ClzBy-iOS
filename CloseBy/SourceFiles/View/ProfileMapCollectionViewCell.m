//
//  ProfileMapCollectionViewCell.m
//  CloseBy
//
//  Created by iGold on 8/21/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "ProfileMapCollectionViewCell.h"

@implementation ProfileMapCollectionViewCell

- (void) gotoMap:(NSDictionary*) dic
{
    [_mMapView removeAnnotations:_mMapView.annotations];  // remove any annotations that exist
    
    _mMapView.delegate = self;
    
    
    BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithPinInfo:[[NSMutableDictionary alloc] initWithDictionary:dic]];
    
    [_mMapView addAnnotation:annotation];
    [_mMapView selectAnnotation:annotation animated:YES];
    
    [_mMapView setShowsUserLocation:YES];
    
    [self performSelectorOnMainThread:@selector(fitToPinsRegion) withObject:nil waitUntilDone:NO];
}

- (void)fitToPinsRegion
{
    if ([_mMapView.annotations count] == 0) {
        return;
    }
    
    BusinessAnnotation *firstMark = [_mMapView.annotations objectAtIndex:0];
    
    CLLocationCoordinate2D topLeftCoord = firstMark.coordinate;
    CLLocationCoordinate2D bottomRightCoord = firstMark.coordinate;
    
    for (BusinessAnnotation *item in _mMapView.annotations) {
        if (![item isKindOfClass:[BusinessAnnotation class]]) {
            continue;
        }
        
        
        if (item.coordinate.latitude < topLeftCoord.latitude) {
            topLeftCoord.latitude = item.coordinate.latitude;
        }
        
        if (item.coordinate.longitude > topLeftCoord.longitude) {
            topLeftCoord.longitude = item.coordinate.longitude;
        }
        
        if (item.coordinate.latitude > bottomRightCoord.latitude) {
            bottomRightCoord.latitude = item.coordinate.latitude;
        }
        
        if (item.coordinate.longitude < bottomRightCoord.longitude) {
            bottomRightCoord.longitude = item.coordinate.longitude;
        }
    }
    
    MKCoordinateRegion region;
    
    region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude) / 2.0;
    region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude) / 2.0;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5; // Add a little extra space on the sides
    
    if (region.span.latitudeDelta < 0.05) {
        region.span.latitudeDelta = 0.05;
    }
    if (region.span.longitudeDelta < 0.05) {
        region.span.longitudeDelta = 0.05;
    }
    
    region = [_mMapView regionThatFits:region];
    [_mMapView setRegion:region animated:NO];
    
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our two custom annotations
    if ([annotation isKindOfClass:[BusinessAnnotation class]])   // for City of San Francisco
    {
        //        BusinessAnnotation *pinAnnotation = annotation;
        
        static NSString* SFAnnotationIdentifier = @"BusinessAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[_mMapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:SFAnnotationIdentifier];
            annotationView.canShowCallout = NO;
            
            UIImage *flagImage = [UIImage imageNamed:@"map_pin_icon.png"];
            
            CGRect resizeRect = CGRectMake(0, 0, 40, 40); // pinImage.size;
            
            annotationView.image = flagImage;
            annotationView.frame = resizeRect;
            annotationView.opaque = NO;
            
            
            //            UIImage *iconImage = pinAnnotation.pinInfo[@"LogoImageSmall_image"];
            //            if ([iconImage isKindOfClass:[UIImage class]]) {
            //                UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
            //                iconView.frame = CGRectMake(0, 0, 32, 32);
            //                annotationView.leftCalloutAccessoryView = iconView;
            //            } else {
            //                annotationView.leftCalloutAccessoryView = nil;
            //            }
            
            //            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            
            //            [annotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"ANSELECTED"];
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}


@end
