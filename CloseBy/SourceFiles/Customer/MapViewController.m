//
//  MapViewController.m
//  CloseBy
//
//  Created by iGold on 2/23/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

#import "BusinessAnnotation.h"
#import "ProfileViewController.h"


@interface MapViewController ()<MKMapViewDelegate>
{
    
    IBOutlet MKMapView *mMapView;
    IBOutlet UIButton *btnDirections;
    
    
    NSMutableArray * arrayBusiness;
    
    NSMutableDictionary * m_targetPinInfo;
}
@end

@implementation MapViewController

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    btnDirections.hidden = YES;
    
    [self fetchBusinessList];
    
//    MKMapTypeStandard = 0,
//    MKMapTypeSatellite,
//    MKMapTypeHybrid
//    mMapView.mapType = MKMapTypeHybrid;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"gotoprofile"]) {
        
        ProfileViewController * vc = segue.destinationViewController;
        vc.businessUserID = sender;
    }
    
}

- (void)fetchBusinessList {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessesWithinRange.aspx?guid=%@&UserID=%@&userlat=%f&userlong=%f&range=%d&fromrow=0&limit=100",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID],
                             [MyLocation sharedInstance].getCurLatitude,
                             [MyLocation sharedInstance].getCurLongitude,
                             500] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];
              
              NSLog(@"responseJson = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  arrayBusiness = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"][@"BusinessListing"]];
                  

                  [self gotoMap];
              }
              else {
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Fail"
                                                                        message:responseJson[@"Message"]
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
              [CB_AlertView hideAlert];
          }];
}

- (void) gotoMap
{
    [mMapView removeAnnotations:mMapView.annotations];  // remove any annotations that exist
    
    [mMapView setUserInteractionEnabled:YES];
    
    for (NSDictionary * dic in arrayBusiness) {
        BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithPinInfo:[[NSMutableDictionary alloc] initWithDictionary:dic]];
        
        [mMapView addAnnotation:annotation];
        
        if (self.selectedBusinessID == [dic[@"ID"] integerValue]) {
            [mMapView selectAnnotation:annotation animated:YES];
        }
    }
    
    [mMapView setShowsUserLocation:YES];
    
    [self performSelectorOnMainThread:@selector(fitToPinsRegion:) withObject:nil waitUntilDone:NO];
}

- (void)fitToPinsRegion:(NSDictionary*) obj
{
    if ([mMapView.annotations count] == 0) {
        return;
    }

    
    CLLocationCoordinate2D topLeftCoord, bottomRightCoord;

    
    if (obj == nil) {
        
        BusinessAnnotation *firstMark = [mMapView.annotations objectAtIndex:0];
        
        topLeftCoord = firstMark.coordinate;
        bottomRightCoord = firstMark.coordinate;
        
        
        for (BusinessAnnotation *item in mMapView.annotations) {
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
    }
    else {
        topLeftCoord = ((CLLocation*)obj[@"start"]).coordinate;
        bottomRightCoord = ((CLLocation*)obj[@"end"]).coordinate;
    }
    
    
    
    // include user location
//    if ([MyLocation sharedInstance].curLocation != nil)
//    {
//        topLeftCoord.latitude = fmin(topLeftCoord.latitude, [[MyLocation sharedInstance] getCurLatitude]);
//        topLeftCoord.longitude = fmax(topLeftCoord.longitude, [[MyLocation sharedInstance] getCurLongitude]);
//        
//        bottomRightCoord.latitude = fmax(bottomRightCoord.latitude, [[MyLocation sharedInstance] getCurLatitude]);
//        bottomRightCoord.longitude = fmin(bottomRightCoord.longitude, [[MyLocation sharedInstance] getCurLongitude]);
//    }
    
    MKCoordinateRegion region;
    
    region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude) / 2.0;
    region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude) / 2.0;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5; // Add a little extra space on the sides
    
    if (region.span.latitudeDelta < 0.01) {
        region.span.latitudeDelta = 0.01;
    }
    if (region.span.longitudeDelta < 0.01) {
        region.span.longitudeDelta = 0.01;
    }
    
    region = [mMapView regionThatFits:region];
    [mMapView setRegion:region animated:YES];
    
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our two custom annotations
    if ([annotation isKindOfClass:[BusinessAnnotation class]])   // for City of San Francisco
    {
        BusinessAnnotation *pinAnnotation = annotation;

        static NSString* SFAnnotationIdentifier = @"BusinessAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mMapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:SFAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            
            UIImage *flagImage = [UIImage imageNamed:@"map_pin_icon.png"];
            
//            CGRect resizeRect;
//            
//            resizeRect.size = flagImage.size;
//            CGSize maxSize = CGRectInset(self.view.bounds,
//                                         [MapViewController annotationPadding],
//                                         [MapViewController annotationPadding]).size;
//            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [MapViewController calloutHeight];
//            if (resizeRect.size.width > maxSize.width)
//                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
//            if (resizeRect.size.height > maxSize.height)
//                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
//            
//            resizeRect.origin = (CGPoint){0.0f, 0.0f};
//            UIGraphicsBeginImageContext(resizeRect.size);
//            [flagImage drawInRect:resizeRect];
//            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
            
            CGRect resizeRect = CGRectMake(0, 0, 30, 30); // pinImage.size;
//            CGSize maxSize = CGRectInset(mMapView.bounds, 10, 10).size;
//            if (resizeRect.size.width > maxSize.width)
//                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
//            if (resizeRect.size.height > maxSize.height)
//                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
//            
//            UIGraphicsBeginImageContext(resizeRect.size);
//            [flagImage drawInRect:resizeRect];
//            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();

            
            
            annotationView.image = flagImage;
            annotationView.frame = resizeRect;
            annotationView.opaque = NO;
            
//            UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFIcon.png"]];
//            annotationView.leftCalloutAccessoryView = sfIconView;

//            UIImage *iconImage = pinAnnotation.pinInfo[@"LogoImageSmall_image"];
//            if ([iconImage isKindOfClass:[UIImage class]]) {
//                UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
//                iconView.frame = CGRectMake(0, 0, 32, 32);
//                annotationView.leftCalloutAccessoryView = iconView;
//            } else {
//                annotationView.leftCalloutAccessoryView = nil;
//            }
            annotationView.leftCalloutAccessoryView = nil;
            
            
            
//            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//            [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
//            rightButton.tag = [m_mapView.annotations indexOfObject:annotation];
//            annotationView.rightCalloutAccessoryView = rightButton;
//            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [infoButton setImage:[UIImage imageNamed:@"icon_map_popover.png"] forState:UIControlStateNormal];
            [infoButton setFrame:CGRectMake(0, 0, 30, 30)];
//            [infoButton setFrame:CGRectMake(0, 0, CGRectGetWidth(infoButton.frame)+10, CGRectGetHeight(infoButton.frame))];
//            [infoButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
            [annotationView setRightCalloutAccessoryView:infoButton];
            
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



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    BusinessAnnotation* annotation = view.annotation;
    
    [self performSegueWithIdentifier:@"gotoprofile" sender:annotation.pinInfo[@"UserID"]];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    btnDirections.hidden = NO;
    
    if ([view.annotation isKindOfClass:[BusinessAnnotation class]]) {
        BusinessAnnotation *pinAnnotation = (BusinessAnnotation*)view.annotation;
        m_targetPinInfo = [pinAnnotation.pinInfo mutableCopy];
        
        // set image in left
        __weak MKAnnotationView *weakView = view;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *imageUrl = [m_targetPinInfo[@"LogoImageSmall"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            UIImage *iconImg = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                UIImageView *imgView = [[UIImageView alloc] initWithImage:iconImg];
                imgView.frame = CGRectMake(0, 0, 32, 32);
                weakView.leftCalloutAccessoryView = imgView;
            });
        });
    }
        
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    btnDirections.hidden = YES;
    m_targetPinInfo = NULL;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {

    
    if ([overlay isKindOfClass:MKPolyline.class]) {
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        lineView.strokeColor = [UIColor colorWithRed:0/255.0f green:163.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
        lineView.lineWidth = 3;
        
        return lineView;
    }
    return nil;
}

- (IBAction)onClickDirections:(id)sender {
    if (m_targetPinInfo == nil) {
        return;
    }
    
    if ([MyLocation sharedInstance].curLocation == nil) {
        return;
    }
    
    
    NSString * startLocation = [NSString stringWithFormat:@"%f,%f", [[MyLocation sharedInstance] getCurLatitude], [[MyLocation sharedInstance] getCurLongitude]];
    NSString * endLocation = [NSString stringWithFormat:@"%f,%f", [m_targetPinInfo[@"latitude"] floatValue], [m_targetPinInfo[@"longitude"] floatValue]];

    
    NSString * requestUrl = @"https://maps.googleapis.com/maps/api/directions/json";
    
    NSDictionary * param = @{
                             @"origin":startLocation,
                             @"destination":endLocation,
                             @"sensor":@"false",
                             };

    NSLog(@"param = %@", param);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager GET:requestUrl
       parameters:param
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSDictionary *responseJson = (NSDictionary*) responseObject;
              
              NSLog(@"responseJson = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"status"] isEqualToString:@"OK"]) {
                  
                  for (MKPolyline *overlayItem in mMapView.overlays) {
                      if ([overlayItem isKindOfClass:[MKPolyline class]]) {
                          [mMapView removeOverlay:overlayItem];
                      }
                  }
              
                  NSArray * arrRoute = responseJson[@"routes"][0][@"legs"][0][@"steps"];

                  if (arrRoute == nil) {
                      return;
                  }
                  
                  CLLocationCoordinate2D *pointArr = malloc(sizeof(CLLocationCoordinate2D) * [arrRoute count]);
                  for (int idx = 0; idx < [arrRoute count]; idx++) {
                      pointArr[idx] = CLLocationCoordinate2DMake([arrRoute[idx][@"end_location"][@"lat"] doubleValue], [arrRoute[idx][@"end_location"][@"lng"] doubleValue]);
                  }
                  
                  [mMapView addOverlay:[MKPolyline polylineWithCoordinates:pointArr count:[arrRoute count]]];
                  
                  free(pointArr);

                  
                  CLLocation * startPos = [[CLLocation alloc] initWithLatitude:[[MyLocation sharedInstance] getCurLatitude] longitude:[[MyLocation sharedInstance] getCurLongitude]];
                  CLLocation * endPos = [[CLLocation alloc] initWithLatitude:[m_targetPinInfo[@"latitude"] floatValue] longitude:[m_targetPinInfo[@"longitude"] floatValue]];

                  [self performSelectorOnMainThread:@selector(fitToPinsRegion:) withObject:@{@"start":startPos, @"end":endPos} waitUntilDone:NO];
                  
                  
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@""
                                                                        message:@"Do you want to open in map app?"
                                                              cancelButtonTitle:@"YES"
                                                              otherButtonTitles:@"NO", nil];
                  [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                      [alertView hideWithCompletionBlock:^{
                          
                          if (buttonIndex == 0) { // NO
                              dispatch_async(dispatch_get_main_queue(),^{
                                  
                                  [self gotoNativeMap:CLLocationCoordinate2DMake([m_targetPinInfo[@"latitude"] floatValue], [m_targetPinInfo[@"longitude"] floatValue])];
                                  
                              });
                          }
                          
                      }];
                  }];
                  [alertView show];
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error = %@", error.description);
          }];

}

- (void) gotoNativeMap:(CLLocationCoordinate2D) latlng {
    
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: latlng addressDictionary: nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
//    destination.name = @"Name Here!";
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
}
@end
