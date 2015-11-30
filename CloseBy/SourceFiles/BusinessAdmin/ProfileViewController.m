//
//  ProfileViewController.m
//  CloseBy
//
//  Created by iGold on 3/8/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "ProfileViewController.h"


#import <Haneke.h>


#import "CHTCollectionViewWaterfallLayout.h"
#import "ProfileCollectionViewCell.h"
#import "ProfileMapCollectionViewCell.h"

#import "UIImage-Helpers.h"

#import <MapKit/MapKit.h>
#import "BusinessAnnotation.h"

#define CELL_WIDTH  160.0f
#define  TAG_VIEW_CONTENT 3000
#define  TAG_BTN_LIKE   1000

@interface ProfileViewController ()<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDataSource, MKMapViewDelegate>
{
    

    IBOutlet UIImageView *ivBusinessLogo;
    IBOutlet UILabel *lbBusinessName;

    IBOutlet UIView *viewAddress;
    IBOutlet UIImageView *ivBackAddress;
    IBOutlet UILabel *lbBusinessBusinessAddress;
    
    
    IBOutlet UIView *viewOpenHours;
    IBOutlet UIImageView *ivBackOpenHours;
    IBOutlet UILabel *startTimeMon;
    IBOutlet UILabel *endTimeMon;
    IBOutlet UILabel *startTimeTue;
    IBOutlet UILabel *endTimeTue;
    IBOutlet UILabel *startTimeWed;
    IBOutlet UILabel *endTimeWed;
    IBOutlet UILabel *startTimeThu;
    IBOutlet UILabel *endTimeThu;
    IBOutlet UILabel *startTimeFri;
    IBOutlet UILabel *endTimeFri;
    IBOutlet UILabel *startTimeSat;
    IBOutlet UILabel *endTimeSat;
    IBOutlet UILabel *startTimeSun;
    IBOutlet UILabel *endTimeSun;
    
    NSMutableArray * dealDataSource;
    
    IBOutlet UICollectionView *mCollectionView;

    NSDictionary * businessData;
    
    NSString * businessName;
    NSString * businessLogo;
    NSString * businessNumber;
    

    // popup
    
    IBOutlet UIView *viewPopup;
    IBOutlet UIImageView *ivBackPopup;
    IBOutlet UIImageView *ivBusinessLogoPop;
    IBOutlet UILabel *lbBusinessNamePop;
    IBOutlet UIButton *btnLikePop;
    IBOutlet UILabel *lbLikesPop;
    IBOutlet UILabel *lbDecayDurationPop;
    
    IBOutlet UIImageView *ivPhotoPop;
    IBOutlet UILabel *lbOriginPricePop;
    IBOutlet UIView *subDecayViewPop;
    IBOutlet UILabel *lbDecayOriginPricePop;
    IBOutlet UILabel *lbDecayingSpecialPricePop;
    
    
    IBOutlet UILabel *lbDealNamePop;
    IBOutlet UILabel *lbDealDescriptionPop;
    IBOutlet UILabel *lbDealCategoryPop;
    
    
    // map popup
    IBOutlet UIView *viewMap;
    IBOutlet MKMapView *mMapView;
    
    // menu panel
    IBOutlet UIView * viewMenu;
    IBOutlet UIButton* btnCategory;
}

@end

@implementation ProfileViewController

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    if (self.bShowBackButton)
        return NO;
    
    if (self.businessUserID == nil && self.responseData == nil) {
        return YES;
    }
    
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

- (void)viewDidLoad {
    
    self.skipSearch = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Profile";
    
    
    [self configureNavigationBar];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    dealDataSource = [NSMutableArray new];
    
    CHTCollectionViewWaterfallLayout * customLayout = (CHTCollectionViewWaterfallLayout*) mCollectionView.collectionViewLayout;
    customLayout.minimumColumnSpacing = 5.0;
    customLayout.minimumInteritemSpacing = 5.0f;
    customLayout.columnCount = 2;

    ivBusinessLogo.layer.cornerRadius = ivBusinessLogo.frame.size.width/2;
    ivBusinessLogo.layer.borderColor = [UIColor whiteColor].CGColor;
    ivBusinessLogo.layer.borderWidth = 2;
    ivBusinessLogo.clipsToBounds = YES;

    ivBusinessLogoPop.image = nil;
    ivBusinessLogoPop.layer.cornerRadius = ivBusinessLogoPop.frame.size.width/2;
    ivBusinessLogoPop.layer.borderColor = [UIColor whiteColor].CGColor;
    ivBusinessLogoPop.layer.borderWidth = 1;
    ivBusinessLogoPop.clipsToBounds = YES;
    
    
    [viewAddress addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAddress:)]];
    [viewOpenHours addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickOpenHour:)]];
    [viewPopup addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDetailPopup:)]];
    [viewMap addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickMap:)]];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getBusinessProfile];
}

- (void) setInterfaceValue:(NSDictionary*) dic
{
    businessData = [NSDictionary dictionaryWithDictionary:dic];
    
    // CATEGORY BUTTON
    NSString * category = dic[@"MainCategoryName"];
    [btnCategory setTitle:category forState:UIControlStateNormal];

    
    
    businessLogo = dic[@"SmallImage"];
    if (businessLogo != nil && ![businessLogo isKindOfClass:[NSNull class]]) {
        NSString * url = [businessLogo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ivBusinessLogo hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    
    businessName = dic[@"BusinessName"];
    lbBusinessName.text = businessName;
    businessNumber = dic[@"BusinessContactNumber"];
    lbBusinessBusinessAddress.text = (dic[@"BusinessAddress"] == nil || [dic[@"BusinessAddress"] isKindOfClass:[NSNull class]]) ? @"" : dic[@"BusinessAddress"];

    
    int count = 0;
    for (NSDictionary * openingHours in dic[@"OpeningHours"]) {
        NSString * startTime = openingHours[@"StartTime"];
        if (startTime == nil || [startTime isKindOfClass:[NSNull class]]) {
            startTime = @"00:00";
        }
        NSString * endTime = openingHours[@"EndTime"];
        if (endTime == nil || [endTime isKindOfClass:[NSNull class]]) {
            endTime = @"00:00";
        }
        
        startTimeMon.text = startTime;
        endTimeMon.text = endTime;
        
        switch (count) {
            case 0:
            {
//                if ([startTime isEqualToString:@"00:00"]) {
//                    startTimeMon.text = @"Closed";
//                    endTimeMon.hidden = YES;
//                } else {
//                    startTimeMon.text = startTime;
//                    endTimeMon.text = endTime;
//                }
                startTimeMon.text = startTime;
                endTimeMon.text = endTime;
                break;
            }
            case 1:
            {
//                if ([startTime isEqualToString:@"00:00"]) {
//                    startTimeTue.text = @"Closed";
//                    endTimeTue.hidden = YES;
//                } else {
//                    startTimeTue.text = startTime;
//                    endTimeTue.text = endTime;
//                }
                startTimeTue.text = startTime;
                endTimeTue.text = endTime;
                break;
            }
            case 2:
            {
//                if ([startTime isEqualToString:@"00:00"]) {
//                    startTimeWed.text = @"Closed";
//                    endTimeWed.hidden = YES;
//                } else {
//                    startTimeWed.text = startTime;
//                    endTimeWed.text = endTime;
//                }
                startTimeWed.text = startTime;
                endTimeWed.text = endTime;
                break;
            }
            case 3:
            {
//                if ([startTime isEqualToString:@"00:00"]) {
//                    startTimeThu.text = @"Closed";
//                    endTimeThu.hidden = YES;
//                } else {
//                    startTimeThu.text = startTime;
//                    endTimeThu.text = endTime;
//                }
                startTimeThu.text = startTime;
                endTimeThu.text = endTime;
                break;
            }
            case 4:
            {
//                if ([startTime isEqualToString:@"00:00"]) {
//                    startTimeFri.text = @"Closed";
//                    endTimeFri.hidden = YES;
//                } else {
//                    startTimeFri.text = startTime;
//                    endTimeFri.text = endTime;
//                }
                startTimeFri.text = startTime;
                endTimeFri.text = endTime;
                break;
            }
            case 5:
            {
//                if ([startTime isEqualToString:@"00:00"]) {
//                    startTimeSat.text = @"Closed";
//                    endTimeSat.hidden = YES;
//                } else {
//                    startTimeSat.text = startTime;
//                    endTimeSat.text = endTime;
//                }
                startTimeSat.text = startTime;
                endTimeSat.text = endTime;
                break;
            }
            case 6:
            {
//                if ([startTime isEqualToString:@"00:00"]) {
//                    startTimeSun.text = @"Closed";
//                    endTimeSun.hidden = YES;
//                } else {
//                    startTimeSun.text = startTime;
//                    endTimeSun.text = endTime;
//                }
                startTimeSun.text = startTime;
                endTimeSun.text = endTime;
                break;
            }
        }
        
        count ++;
    }

    // map
//    [self gotoMap:dic];
    

    // thumb
    dealDataSource = dic[@"BusinessDeals"];
    [mCollectionView reloadData];

//    [self showDeals];

    
}

//- (void) dealloc
//{
//    for (id <MKAnnotation> annotation in mMapView.annotations)
//    {
//        // remove all observers, delegates and other outward pointers.
//        [[mMapView viewForAnnotation:annotation] removeObserver: self forKeyPath: @"selected"];
//    }
//}
/*
- (void) gotoMap:(NSDictionary*) dic
{
    [mMapView removeAnnotations:mMapView.annotations];  // remove any annotations that exist
    
    [mMapView setUserInteractionEnabled:YES];
    
    
    BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithPinInfo:[[NSMutableDictionary alloc] initWithDictionary:dic]];
    
    [mMapView addAnnotation:annotation];
    [mMapView selectAnnotation:annotation animated:YES];
    
    [mMapView setShowsUserLocation:YES];
    
    [self performSelectorOnMainThread:@selector(fitToPinsRegion) withObject:nil waitUntilDone:NO];
}

- (void)fitToPinsRegion
{
    if ([mMapView.annotations count] == 0) {
        return;
    }
    
    BusinessAnnotation *firstMark = [mMapView.annotations objectAtIndex:0];
    
    CLLocationCoordinate2D topLeftCoord = firstMark.coordinate;
    CLLocationCoordinate2D bottomRightCoord = firstMark.coordinate;
    
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
//            
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
        if (annotationView == nil)
            return;
        
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
    if (annotationView == nil) {
        return;
    }
    
    BusinessAnnotation *pin = annotationView.annotation;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImage *iconImg = pin.pinInfo[@"LogoImageSmall_image"];
    if ([iconImg isKindOfClass:[UIImage class]]) {
        imageView.image = iconImg;
    }
    imageView.backgroundColor = [UIColor clearColor];
    annotationView.leftCalloutAccessoryView = imageView;
}
*/

- (void) getBusinessProfile
{
    NSString *requestUrl;
    
    if (self.responseData != nil) { // notification
        NSLog(@"self.responseData = %@", self.responseData);
        
        [self setInterfaceValue:self.responseData[@"BusinessProfile"]];
        
        return;
    }
    else if (self.businessUserID == nil) { // business
        requestUrl = [[NSString stringWithFormat:@"%@/GetCompleteBusinessProfile.aspx?guid=%@&UserID=%@",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else { // customer side
        requestUrl = [[NSString stringWithFormat:@"%@/GetCompleteBusinessProfileForCustomer.aspx?guid=%@&CustomerUserID=%@&BusinessUserID=%@&lat=%f&long=%f",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID],
                       self.businessUserID,
                       [MyLocation sharedInstance].getCurLatitude,
                       [MyLocation sharedInstance].getCurLongitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSLog(@"request = %@", requestUrl);
    
    [CB_AlertView showAlertOnView:self.view];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [CB_AlertView hideAlert];
             
             NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             NSDictionary * responseJson = [responseString JSONValue];
             
             NSLog(@"response = %@", responseJson);
             
             if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {

                 
                 [self setInterfaceValue:responseJson[@"Data"]];
                 
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)configureNavigationBar {
    
    if (self.bShowBackButton == YES) {
        UIButton * rightBarbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [rightBarbutton setAutoresizingMask:UIViewAutoresizingNone];
        [rightBarbutton setImage:[UIImage imageNamed:@"icon_x.png"] forState:UIControlStateNormal];
        [rightBarbutton addTarget:self action:@selector(onClickClose:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarbutton];
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
    
    if (self.bShowEditButton == YES) {
        UIButton * rightBarbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [rightBarbutton setAutoresizingMask:UIViewAutoresizingNone];
        [rightBarbutton setImage:[UIImage imageNamed:@"icon_edit.png"] forState:UIControlStateNormal];
        [rightBarbutton addTarget:self action:@selector(editProfile) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarbutton];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
}

- (void) onClickClose :(id) sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) editProfile
{
    [self performSegueWithIdentifier:@"gotoprofileedit" sender:nil];
}

/*
- (void) showDeals
{
    if (businesDeals != nil && businesDeals.count > 0) {

        NSLog(@"businessDeal ============ 1");
        
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
                
                
                [thumbnailListView reloadData];

                

            }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Image error: %@", error);
            }];
            [requestOperation start];
            
        }
        
    }
    else {
        viewDeal.hidden = YES;
    }

}

- (void) showDealDetail:(NSInteger) index
{
    ivChoose.image = arrImages[index];
    
    lbDiscountTagLine.text = businesDeals[index][@"DiscountedTagLing"];
    lbDealName.text = businesDeals[index][@"ProductName"];
    lbProductDescription.text = businesDeals[index][@"ProductDescription"];
 
    if ([businesDeals[index][@"StandardSpecial"] boolValue]) {
        // standarspecial
        lbOriginPrice.hidden = NO;
        lbOriginPrice.text = [NSString stringWithFormat:@"$%d", [businesDeals[index][@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? 0 : [businesDeals[index][@"OrigionalPrice"] intValue]];
        subDiscayPriceView.hidden = YES;
        
        lbDiscayRemaining.hidden = YES;
    }
    else {
        lbOriginPrice.hidden = YES;
        lbDiscayOriginPrice.text = [NSString stringWithFormat:@"$%d", [businesDeals[index][@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? 0 : [businesDeals[index][@"OrigionalPrice"] intValue]];
        lbDiscaySpecialPrice.text = [NSString stringWithFormat:@"$%d", [businesDeals[index][@"SpecialPrice"] isKindOfClass:[NSNull class]] ? 0 : [businesDeals[index][@"SpecialPrice"] intValue]];
        
        lbDiscayRemaining.hidden = NO;
        lbDiscayRemaining.text = [GlobalAPI getLeftTime:businesDeals[index][@"DecayEndTme"]];

    }
}

//=================================================================================
#pragma mark - ThumbnailListViewDataSource
//=================================================================================
- (NSInteger)numberOfItemsInThumbnailListView:(ThumbnailListView*)thumbnailListView
{
    NSLog(@"%s, %lu",__func__, arrImages.count);
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
    NSLog(@"%s",__func__);
    if( decelerate == NO ){
        [thumbnailListView autoAdjustScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%s",__func__);
    [thumbnailListView autoAdjustScroll];
}
*/


#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        int widthThumb = [dealDataSource[indexPath.item][@"ThumbWidth"] isKindOfClass:[NSNull class]] ? 1 : [dealDataSource[indexPath.item][@"ThumbWidth"] intValue];
        int heightThumb = [dealDataSource[indexPath.item][@"ThumbHeight"] isKindOfClass:[NSNull class]] ? 1 : [dealDataSource[indexPath.item][@"ThumbHeight"] intValue];
        
        float imageHeight = heightThumb * CELL_WIDTH / widthThumb;
        
        float totalHeight = 40+ imageHeight + 30 + 71;
        
        return CGSizeMake(CELL_WIDTH, totalHeight);
    }
    else
        return CGSizeMake(320, 150);
}

#pragma mark = UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        if (dealDataSource == nil) {
            return 0;
        }
        
        NSInteger count = [dealDataSource count];
        
        return count;
    }
    else {
        if (businessData == nil) {
            return 0;
        }
        return 1;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        ProfileCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionViewCell" forIndexPath:indexPath];
        
        [cell.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCell:)]];
        cell.contentView.tag = TAG_VIEW_CONTENT + indexPath.item;
        
        
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
        cell.lbDealDescription.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:11];
        cell.lbDealDescription.textColor = [UIColor colorWithRed:76.0/255.0f green:76.0/255.0f blue:76.0/255.0f alpha:1.0];;
        
        
        cell.lbLikes.text = [deal[@"TotalDealLikes"] isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%d", [deal[@"TotalDealLikes"] intValue]] ;
        
        if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
            cell.btnLike.selected = YES;
        }
        else {
            cell.btnLike.selected = NO;
        }

        if (self.businessUserID != nil || self.responseData != nil) {
            [cell.btnLike addTarget:self action:@selector(onClickLike:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnLike.tag = TAG_BTN_LIKE + indexPath.item;
        }
        
        return cell;
    }
    else {
        ProfileMapCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileMapCollectionViewCell" forIndexPath:indexPath];
        
//        if (cell == nil)
        {
            [cell gotoMap:businessData];
        }
        
        return cell;
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if (kind == UICollectionElementKindSectionFooter) {
        ProfileMapCollectionViewCell *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ProfileMapCollectionViewCell" forIndexPath:indexPath];
        
        [footerview gotoMap:businessData];
        
        return footerview;
    }
    
    return nil;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self showDetailPopup:dealDataSource[indexPath.item]];
//}
- (void) onTapCell:(UIGestureRecognizer* ) gesture
{
    NSInteger tag = gesture.view.tag - TAG_VIEW_CONTENT;
    [self showDetailPopup:dealDataSource[tag] index:tag];
}

- (void) onClickLikePop:(NSMutableDictionary*) deal index:(NSInteger)index
{
    [self requestLike:deal index:index callback:^(BOOL sucess) {
        
    }];
}
- (void) onClickLike:(UIButton*) sender
{
    NSInteger tag = sender.tag - TAG_BTN_LIKE;
    
    NSMutableDictionary* deal = [dealDataSource[tag] mutableCopy];
    
    [self requestLike:deal index:tag callback:^(BOOL sucess) {
        if (viewPopup.hidden == NO) {
            [self setDetailPopup:dealDataSource[tag] index:tag];
        }
    }];
   
}
- (void) requestLike:(NSMutableDictionary*) deal index:(NSInteger) tag  callback: (void (^)(BOOL sucess)) complete
{
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UserSaveDeal.aspx?guid=%@&UserID=%@&BusinessID=%@&DealID=%@",
                             kServerURL, kGUID, [GlobalAPI loadLoginID],
                             deal[@"BusinessID"],
                             deal[@"ID"]]
                            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    
    [manager POST:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  
                  if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
                      deal[@"CurrentUserHasLiked"] = [NSNumber numberWithInt:0];
                      int likes = [deal[@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? 1 : [deal[@"NumberOfLikes"] intValue];
                      deal[@"NumberOfLikes"] = [NSNumber numberWithInt:likes - 1];
                  }
                  else {
                      deal[@"CurrentUserHasLiked"] = [NSNumber numberWithInt:1];
                      int likes = [deal[@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? 0 : [deal[@"NumberOfLikes"] intValue];
                      deal[@"NumberOfLikes"] = [NSNumber numberWithInt:likes + 1];
                  }
                  
                  [dealDataSource replaceObjectAtIndex:tag withObject:deal];
                  
                  [mCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];
                  
                  if (complete != nil) {
                      complete(YES);
                  }
                  
              }
              else {
                  if (complete != nil) {
                      complete(NO);
                  }
                  
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
              if (complete != nil) {
                  complete(NO);
              }

              
              [CB_AlertView hideAlert];
          }];
}

#pragma mark - button event
- (IBAction)onClickPhone:(id)sender {
    if (businessNumber.length < 1)
        return;
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:businessNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (UIImage*) capture {
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    [mCollectionView.layer renderInContext:context];
    [self.view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (IBAction)onClickAddress:(id)sender {
    
    if (viewAddress.hidden == YES) { // show

        float quality = .00001f;
        float blurred = .5f;
        
        NSData *imageData = UIImageJPEGRepresentation([self capture], quality);
        UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
        
        ivBackAddress.image = blurredImage;
        
        viewAddress.hidden = NO;
        viewAddress.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewAddress.alpha = 1.0;
            viewOpenHours.alpha = 0.0;
            viewMap.alpha = 0.0;
            viewPopup.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewAddress.hidden = NO;
            viewOpenHours.hidden = YES;
            viewMap.hidden = YES;
            viewPopup.hidden = YES;
        }];
    }
    else { // hide
        viewAddress.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewAddress.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewAddress.hidden = YES;
        }];
    }
    
}
- (IBAction)onClickRetail:(id)sender {
    if (viewAddress.hidden == NO) {
        viewAddress.hidden = YES;
    }
    if (viewOpenHours.hidden == NO) {
        viewOpenHours.hidden = YES;
    }
    if (viewMap.hidden == NO) {
        viewMap.hidden = YES;
    }
    if (viewPopup.hidden == NO) {
        viewPopup.hidden = YES;
    }
}
- (IBAction)onClickOpenHour:(id)sender {
    
    if (viewOpenHours.hidden == YES) { // show

        float quality = .00001f;
        float blurred = .5f;
        

        NSData *imageData = UIImageJPEGRepresentation([self capture], quality);
        UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
        
        ivBackOpenHours.image = blurredImage;

        viewOpenHours.hidden = NO;
        viewOpenHours.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewOpenHours.alpha = 1.0;
            viewAddress.alpha = 0.0;
            viewMap.alpha = 0.0;
            viewPopup.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewOpenHours.hidden = NO;
            viewAddress.hidden = YES;
            viewMap.hidden = YES;
            viewPopup.hidden = YES;
        }];
    }
    else { // hide

        viewOpenHours.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewOpenHours.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewOpenHours.hidden = YES;
        }];
    }
}


- (void) setDetailPopup:(NSDictionary*) deal index:(NSInteger) index {
    @try {
        NSString * url = [businessLogo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ivBusinessLogoPop hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    lbBusinessNamePop.text = businessName;
    
    
    ivPhotoPop.contentMode = UIViewContentModeScaleAspectFill;
    ivPhotoPop.clipsToBounds = YES;
    ivPhotoPop.image = nil;
    @try {
        NSString * url = [deal[@"ThumbImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ivPhotoPop hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    
    lbOriginPricePop.hidden = NO;
    lbOriginPricePop.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? 0 : [deal[@"OrigionalPrice"] stringValue]];
    
    if (![deal[@"DecayingSpecial"] isKindOfClass:[NSNull class]]
        && [deal[@"DecayingSpecial"] boolValue]) {
        // decaying
        lbOriginPricePop.hidden = YES;
        
        subDecayViewPop.hidden = NO;
        lbDecayOriginPricePop.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"OrigionalPrice"] stringValue]];
        lbDecayingSpecialPricePop.text = [NSString stringWithFormat:@"$%@", [deal[@"SpecialPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"SpecialPrice"] stringValue]];
        
        lbDecayDurationPop.hidden = NO;
        lbDecayDurationPop.text = [GlobalAPI getLeftTime:deal[@"DecayEndTime"]];
    }
    else {
        lbOriginPricePop.hidden = NO;
        subDecayViewPop.hidden = YES;
        lbDecayDurationPop.hidden = YES;
    }
    
    lbDealNamePop.text = deal[@"ProductName"];
    lbDealDescriptionPop.text = deal[@"ProductDescription"];
    
    
    lbLikesPop.text = [deal[@"TotalDealLikes"] isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%d", [deal[@"TotalDealLikes"] intValue]] ;
    
    if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
        btnLikePop.selected = YES;
    }
    else {
        btnLikePop.selected = NO;
    }
    
    if (self.businessUserID != nil || self.responseData != nil) {
        [btnLikePop addTarget:self action:@selector(onClickLike:) forControlEvents:UIControlEventTouchUpInside];
        btnLikePop.tag = TAG_BTN_LIKE + index;
    }
    
}
- (void) showDetailPopup:(NSDictionary*) deal index:(NSInteger) index {
    
    if (viewPopup.hidden == YES) { // show
        
        // setup interface
        
        [self setDetailPopup:deal index:index];

        
        ///////////////////////
        
        float quality = .00001f;
        float blurred = .5f;
        
        
        NSData *imageData = UIImageJPEGRepresentation([self capture], quality);
        UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
        
        ivBackPopup.image = blurredImage;
        
        viewPopup.hidden = NO;
        viewPopup.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewPopup.alpha = 1.0;
            viewAddress.alpha = 0.0;
            viewMap.alpha = 0.0;
            viewOpenHours.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewPopup.hidden = NO;
            viewAddress.hidden = YES;
            viewMap.hidden = YES;
            viewOpenHours.hidden = YES;
        }];
    }
    else { // hide
       
    }
    
}
- (void) hideDetailPopup:(UIGestureRecognizer *) sender {
    if (viewPopup.hidden == NO) {
        viewPopup.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewPopup.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewPopup.hidden = YES;
        }];
    }
}
- (IBAction)onClickMap:(id)sender {
    
    if (viewMap.hidden == YES) { // show
        
        [self gotoMap:businessData];
        
        viewMap.hidden = NO;
        viewMap.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewMap.alpha = 1.0;
            viewAddress.alpha = 0.0;
            viewOpenHours.alpha = 0.0;
            viewPopup.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewMap.hidden = NO;
            viewOpenHours.hidden = YES;
            viewAddress.hidden = YES;
            viewPopup.hidden = YES;
        }];
    }
    else { // hide
        
        viewMap.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            viewMap.alpha = 0.0;
        } completion:^(BOOL finished) {
            viewMap.hidden = YES;
        }];
    }
    
}

- (void) gotoMap:(NSDictionary*) dic
{
    [mMapView removeAnnotations:mMapView.annotations];  // remove any annotations that exist
    
    mMapView.delegate = self;
    
    
    BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithPinInfo:[[NSMutableDictionary alloc] initWithDictionary:dic]];
    
    [mMapView addAnnotation:annotation];
    [mMapView selectAnnotation:annotation animated:YES];
    
    [mMapView setShowsUserLocation:YES];
    
    [self setDirections:dic];
    
//    [self performSelectorOnMainThread:@selector(fitToPinsRegion:) withObject:nil waitUntilDone:NO];
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
    
    region = [mMapView regionThatFits:region];
    [mMapView setRegion:region animated:NO];
    
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
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mMapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:SFAnnotationIdentifier];
            annotationView.canShowCallout = NO;
            
            UIImage *flagImage = [UIImage imageNamed:@"map_pin_icon.png"];
            
            CGRect resizeRect = CGRectMake(0, 0, 30, 30); // pinImage.size;
            
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
                 CLLocation * endPos = [[CLLocation alloc] initWithLatitude:[targetPinInfo[@"latitude"] floatValue] longitude:[targetPinInfo[@"longitude"] floatValue]];
                 
                 [self performSelectorOnMainThread:@selector(fitToPinsRegion:) withObject:@{@"start":startPos, @"end":endPos} waitUntilDone:NO];
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error = %@", error.description);
         }];
    
}


#pragma mark -- menu panel
- (void) showMenuPanel {
    
    if (!viewMenu.hidden) {
        return;
    }
    
    viewMenu.alpha = 0;
    viewMenu.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        viewMenu.alpha = 1.0f;
    }];
}
- (void) hideMenuPanel {

    if (viewMenu.hidden) {
        return;
    }
    
    viewMenu.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        viewMenu.alpha = 0;
    } completion:^(BOOL finished) {
        viewMenu.hidden = YES;
    }];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint pos = [scrollView.panGestureRecognizer velocityInView:scrollView];
    float yVelocity = pos.y;
    
    if (yVelocity > 0 && viewMenu.hidden == NO) {
        [self hideMenuPanel];
    }
    else if (yVelocity < 0 && viewMenu.hidden == YES) {
        [self showMenuPanel];
    }
}


@end
