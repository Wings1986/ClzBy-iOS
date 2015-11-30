//
//  BeaconTypeCell2.m
//  CloseBy
//

#import "BeaconTypeCell2.h"

@implementation BeaconTypeCell2

- (void)awakeFromNib {
    // Initialization code

    _viewBeaconData.backgroundColor = [UIColor whiteColor];
    _viewBeaconData.layer.borderColor = [UIColor grayColor].CGColor;
    _viewBeaconData.layer.borderWidth = 5;
    
    _thumbnailListView.dataSource = self;
    _thumbnailListView.delegate = self;

    arrImages = [[NSMutableArray alloc] init];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *action = (__bridge NSString *)context;
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)object;
    if ([action isEqualToString:@"ANSELECTED"])
    {
        BOOL annotationSelected = [[change valueForKey:@"new"] boolValue];
        if (annotationSelected)
        {
            BusinessAnnotation *pin = (BusinessAnnotation *)annotationView.annotation;
            UIImage *iconImage = pin.pinInfo[@"LogoImageSmall_image"];
            if ([iconImage isKindOfClass:[UIImage class]]) {
                [self performSelectorOnMainThread:@selector(addImageToAnnotationView:) withObject:annotationView waitUntilDone:NO];
            } else {
                [NSThread detachNewThreadSelector:@selector(getThumbImage:) toTarget:self withObject:annotationView];
            }
        }
        else
        {
            // Annotation deselected
        }
    }
}


- (void)getThumbImage:(MKAnnotationView *)annotationView
{
    @autoreleasepool {
        BusinessAnnotation *pin = annotationView.annotation;
        NSMutableDictionary *pinInfo = pin.pinInfo;
        if (pinInfo && ![pinInfo[@"LogoImageSmall_image"] isKindOfClass:[UIImage class]]) {
            NSString *imageUrl = [pinInfo[@"LogoImageSmall"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@", imageUrl);
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            UIImage *iconImg = [UIImage imageWithData:imageData];
            if (iconImg) {
                pinInfo[@"LogoImageSmall_image"] = iconImg;
                
                [self performSelectorOnMainThread:@selector(addImageToAnnotationView:) withObject:annotationView waitUntilDone:NO];
            } else {
                pinInfo[@"LogoImageSmall_image"] = [NSNull null];
            }
        }
    }
}

- (void) addImageToAnnotationView:(MKAnnotationView *)annotationView
{
    BusinessAnnotation *pin = annotationView.annotation;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImage *iconImg = pin.pinInfo[@"LogoImageSmall_image"];
    if ([iconImg isKindOfClass:[UIImage class]]) {
        imageView.image = iconImg;
    }
    imageView.backgroundColor = [UIColor clearColor];
    annotationView.leftCalloutAccessoryView = imageView;
}

- (void) showDeals:(NSDictionary*) dic
{
    businesDeals = [dic mutableCopy];
    
    if (businesDeals != nil && businesDeals.count > 0) {
        
        [arrImages removeAllObjects];
        
        for (NSDictionary * dic in businesDeals) {
            
            NSLog(@"businessDeal ============ 1.5");
            
            
            NSString * url = [dic[@"ProductPhoto"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *imageURL = [NSURL URLWithString:url];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSData *imageData = responseObject;
                
                UIImage *image = [UIImage imageWithData:imageData];
                
                [arrImages addObject:image];
                
                if (arrImages.count == 1) {
                    [self showDealDetail:0];
                }
                
                
                [_thumbnailListView reloadData];
                
                
                
            }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Image error: %@", error);
            }];
            [requestOperation start];
        }
    }
    else {
        _viewDeal.hidden = YES;
    }
}

- (void) showDealDetail:(NSInteger) index
{
    _ivChoose.image = arrImages[index];
    
    _lbDiscountTagLine.text = businesDeals[index][@"DiscountedTagLing"];
    _lbDealName.text = businesDeals[index][@"ProductName"];
    _lbProductDescription.text = businesDeals[index][@"ProductDescription"];
    
    if ([businesDeals[index][@"StandardSpecial"] boolValue]) {
        // standarspecial
        _lbOriginPrice.hidden = NO;
        _lbOriginPrice.text = [NSString stringWithFormat:@"$%@", [businesDeals[index][@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [businesDeals[index][@"OrigionalPrice"] stringValue]];
        _subDiscayPriceView.hidden = YES;
        
        _lbDiscayRemaining.hidden = YES;
    }
    else {
        _lbOriginPrice.hidden = YES;
        _lbDiscayOriginPrice.text = [NSString stringWithFormat:@"$%@", [businesDeals[index][@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [businesDeals[index][@"OrigionalPrice"] stringValue]];
        _lbDiscaySpecialPrice.text = [NSString stringWithFormat:@"$%@", [businesDeals[index][@"SpecialPrice"] isKindOfClass:[NSNull class]] ? @"0" : [businesDeals[index][@"SpecialPrice"] stringValue]];
        
        _lbDiscayRemaining.hidden = NO;
        //        lbDiscayRemaining.text = businesDeals[index][@"DecayDuration"];
    }
}

//=================================================================================
#pragma mark - ThumbnailListViewDataSource
//=================================================================================
- (NSInteger)numberOfItemsInThumbnailListView:(ThumbnailListView*)thumbnailListView
{
    return arrImages.count;
}

- (UIImage*)thumbnailListView:(ThumbnailListView*)thumbnailListView
                 imageAtIndex:(NSInteger)index
{
    return arrImages[index];
}

//=================================================================================
#pragma mark - ThumbnailListViewDelegate
//=================================================================================
- (void)thumbnailListView:(ThumbnailListView*)thumbnailListView
         didSelectAtIndex:(NSInteger)index
{
    
    [self showDealDetail:index];
}

//=================================================================================
#pragma mark - UIScrollViewDelegate
//=================================================================================
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if( decelerate == NO ){
        [_thumbnailListView autoAdjustScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_thumbnailListView autoAdjustScroll];
}

@end
