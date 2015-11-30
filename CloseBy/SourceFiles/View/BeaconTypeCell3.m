//
//  BeaconTypeCell3.m
//  CloseBy
//

#import "BeaconTypeCell3.h"

#import <Haneke.h>

#define CELL_WIDTH  100.0f

@implementation BeaconTypeCell3

- (void)awakeFromNib {
    // Initialization code

    _viewBeaconData.layer.cornerRadius = 10;
    _viewBeaconData.backgroundColor = [UIColor whiteColor];
    _viewBeaconData.layer.borderColor = APP_COLOR.CGColor;
    _viewBeaconData.layer.borderWidth = 1;
    
    _ivBusinessLogo.layer.cornerRadius = _ivBusinessLogo.frame.size.width/2;
    _ivBusinessLogo.layer.borderColor = [UIColor whiteColor].CGColor;
    _ivBusinessLogo.layer.borderWidth = 2;
    _ivBusinessLogo.clipsToBounds = YES;

    
    
    CHTCollectionViewWaterfallLayout * customLayout = (CHTCollectionViewWaterfallLayout*) self.mCollectionView.collectionViewLayout;
    customLayout.minimumColumnSpacing = 2.0;
    customLayout.minimumInteritemSpacing = 2.0f;
    customLayout.columnCount = 2;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//- (void) dealloc
//{
//    for (id <MKAnnotation> annotation in _mMapView.annotations)
//    {
//        // remove all observers, delegates and other outward pointers.
//        [[_mMapView viewForAnnotation:annotation] removeObserver: self forKeyPath: @"selected"];
//    }
//}
//- (void) removeMap
//{
//    for (id <MKAnnotation> annotation in _mMapView.annotations)
//    {
//        // remove all observers, delegates and other outward pointers.
//        [[_mMapView viewForAnnotation:annotation] removeObserver: self forKeyPath: @"selected"];
//    }
//}

- (void) setBusinessName:(NSString *) name logo:(NSString*) logoUrl
{
    businessName = name;
    businessLogo = logoUrl;
}
- (void) gotoMap:(NSDictionary*) dic
{
    [_mMapView removeAnnotations:_mMapView.annotations];  // remove any annotations that exist
    
    _mMapView.delegate = self;
    
    
    BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithPinInfo:[[NSMutableDictionary alloc] initWithDictionary:dic]];
    
    [_mMapView addAnnotation:annotation];
    [_mMapView selectAnnotation:annotation animated:YES];
    
    [_mMapView setShowsUserLocation:YES];
    
    [self setDirections:dic];
//    [self performSelectorOnMainThread:@selector(fitToPinsRegion:) withObject:nil waitUntilDone:NO];
}

- (void)fitToPinsRegion:(NSDictionary*) obj
{
    if ([_mMapView.annotations count] == 0) {
        return;
    }
    
    CLLocationCoordinate2D topLeftCoord, bottomRightCoord;
    
    
    if (obj == nil) {
        
        BusinessAnnotation *firstMark = [_mMapView.annotations objectAtIndex:0];
        
        topLeftCoord = firstMark.coordinate;
        bottomRightCoord = firstMark.coordinate;
        
        
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
    }
    else {
        topLeftCoord = ((CLLocation*)obj[@"start"]).coordinate;
        bottomRightCoord = ((CLLocation*)obj[@"end"]).coordinate;
    }
    
    MKCoordinateRegion region;
    
    region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude) / 2.0;
    region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude) / 2.0;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    if (region.span.latitudeDelta < 0.01) {
        region.span.latitudeDelta = 0.01;
    }
    if (region.span.longitudeDelta < 0.01) {
        region.span.longitudeDelta = 0.01;
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
            
            CGRect resizeRect = CGRectMake(0, 0, 20, 20); // pinImage.size;
            
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    
    if ([overlay isKindOfClass:MKPolyline.class]) {
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        lineView.strokeColor = APP_COLOR;
        lineView.lineWidth = 3;
        
        return lineView;
    }
    return nil;
}

- (void) setDirections:(NSDictionary*) targetPinInfo {
    if (targetPinInfo == nil) {
        return;
    }
    
    if ([MyLocation sharedInstance].curLocation == nil) {
        return;
    }
    
    
    NSString * startLocation = [NSString stringWithFormat:@"%f,%f", [[MyLocation sharedInstance] getCurLatitude], [[MyLocation sharedInstance] getCurLongitude]];
    NSString * endLocation = [NSString stringWithFormat:@"%f,%f", [targetPinInfo[@"latitude"] floatValue], [targetPinInfo[@"longitude"] floatValue]];
    
    
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
                 
                 for (MKPolyline *overlayItem in _mMapView.overlays) {
                     if ([overlayItem isKindOfClass:[MKPolyline class]]) {
                         [_mMapView removeOverlay:overlayItem];
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
                 
                 [_mMapView addOverlay:[MKPolyline polylineWithCoordinates:pointArr count:[arrRoute count]]];
                 
                 free(pointArr);
                 
                 
                 CLLocation * startPos = [[CLLocation alloc] initWithLatitude:[[MyLocation sharedInstance] getCurLatitude] longitude:[[MyLocation sharedInstance] getCurLongitude]];
                 CLLocation * endPos = [[CLLocation alloc] initWithLatitude:[targetPinInfo[@"latitude"] floatValue] longitude:[targetPinInfo[@"longitude"] floatValue]];
                 
                 [self performSelectorOnMainThread:@selector(fitToPinsRegion:) withObject:@{@"start":startPos, @"end":endPos} waitUntilDone:NO];
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error = %@", error.description);
         }];
    
}


- (void) showDeals:(NSDictionary*) dic
{
    dealDataSource = [dic mutableCopy];
    [self.mCollectionView reloadData];
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int widthThumb = [dealDataSource[indexPath.item][@"ThumbWidth"] isKindOfClass:[NSNull class]] ? 1 : [dealDataSource[indexPath.item][@"ThumbWidth"] intValue];
    int heightThumb = [dealDataSource[indexPath.item][@"ThumbHeight"] isKindOfClass:[NSNull class]] ? 1 : [dealDataSource[indexPath.item][@"ThumbHeight"] intValue];
    
    float imageHeight = heightThumb * CELL_WIDTH / widthThumb;
    
    float totalHeight = 40+ imageHeight + 30 + 71;
    
    return CGSizeMake(CELL_WIDTH, totalHeight);
}

#pragma mark = UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (dealDataSource == nil) {
        return 0;
    }
    
    NSInteger count = [dealDataSource count];
    
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    ProfileCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionViewCell" forIndexPath:indexPath];
    
    
    NSDictionary * deal = dealDataSource[indexPath.item];
    
    cell.layer.cornerRadius = 2;
    cell.clipsToBounds = YES;
    cell.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f].CGColor;
    cell.layer.borderWidth = 1;
    
    
    
    cell.ivBusinessLogo.image = nil;
    cell.ivBusinessLogo.layer.cornerRadius = cell.ivBusinessLogo.frame.size.width/2;
    cell.ivBusinessLogo.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.ivBusinessLogo.layer.borderWidth = 1;
    cell.ivBusinessLogo.clipsToBounds = YES;
    
    @try {
        NSString * url = [businessLogo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivBusinessLogo hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    cell.lbBusinessName.text = businessName;
    
    
    cell.ivPhoto.contentMode = UIViewContentModeScaleToFill;
    cell.ivPhoto.image = nil;
    @try {
        NSString * url = [deal[@"ThumbImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivPhoto hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    
    cell.lbOriginPrice.hidden = NO;
    cell.lbOriginPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"OrigionalPrice"] stringValue]];
    
    if (![deal[@"DecayingSpecial"] isKindOfClass:[NSNull class]]
        && [deal[@"DecayingSpecial"] boolValue]) {
        // decaying
        cell.lbOriginPrice.hidden = YES;
        
        cell.subDecayView.hidden = NO;
        cell.lbDecayOriginPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"OrigionalPrice"] stringValue]];
        cell.lbDecayingSpecialPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"SpecialPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"SpecialPrice"] stringValue]];
        
        cell.lbDecayDuration.hidden = NO;
        cell.lbDecayDuration.text = [GlobalAPI getLeftTime:deal[@"DecayEndTime"]];
    }
    else {
        cell.lbOriginPrice.hidden = NO;
        cell.subDecayView.hidden = YES;
        cell.lbDecayDuration.hidden = YES;
    }
    
    cell.lbDealName.text = deal[@"ProductName"];

    cell.lbDealDescription.text = deal[@"ProductDescription"];
    cell.lbDealDescription.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:8];
    cell.lbDealDescription.textColor = [UIColor colorWithRed:76.0/255.0f green:76.0/255.0f blue:76.0/255.0f alpha:1.0];;

    
    cell.lbLikes.text = [deal[@"TotalDealLikes"] isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%d", [deal[@"TotalDealLikes"] intValue]] ;

    if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
        cell.btnLike.selected = YES;
    }
    else {
        cell.btnLike.selected = NO;
    }
    
    //    if (![GlobalAPI isBusiness]) {
    //        [cell.btnLike addTarget:self action:@selector(onClickLike:) forControlEvents:UIControlEventTouchUpInside];
    //        cell.btnLike.tag = TAG_BTN_LIKE + indexPath.item;
    //    }
    
    return cell;
}


@end
