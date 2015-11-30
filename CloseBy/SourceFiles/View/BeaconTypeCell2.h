//
//  BeaconTypeCell2.h
//  CloseBy
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "ThumbnailListView.h"

#import "BusinessAnnotation.h"


@interface BeaconTypeCell2 : UITableViewCell <ThumbnailListViewDataSource, ThumbnailListViewDelegate, MKMapViewDelegate>
{
    NSMutableArray * businesDeals;
    NSMutableArray * arrImages;
}

- (void) removeMap;
- (void) gotoMap:(NSDictionary*) dic;
- (void) showDeals:(NSDictionary*) dic;


@property (strong, nonatomic) IBOutlet UISwitch *chBeaconEnable;

@property (strong, nonatomic) IBOutlet UIButton *btnTest;
@property (strong, nonatomic) IBOutlet UIButton *btnEditType;


@property (strong, nonatomic) IBOutlet UIView *viewBeaconData;
@property (strong, nonatomic) IBOutlet UIImageView *ivBusinessLogo;
@property (strong, nonatomic) IBOutlet UILabel *lbBusinessName;
@property (strong, nonatomic) IBOutlet UILabel *lbBusinessContactNumber;
@property (strong, nonatomic) IBOutlet UILabel *lbBusinessBusinessAddress;
@property (strong, nonatomic) IBOutlet UILabel *lbMainCategoryName;

@property (strong, nonatomic) IBOutlet UIButton *btnCheckedIn;
@property (strong, nonatomic) IBOutlet UILabel *lbLikes;
@property (strong, nonatomic) IBOutlet UIImageView *ivLike;


@property (strong, nonatomic) IBOutlet UILabel *startTimeMon;
@property (strong, nonatomic) IBOutlet UILabel *endTimeMon;
@property (strong, nonatomic) IBOutlet UILabel *startTimeTue;
@property (strong, nonatomic) IBOutlet UILabel *endTimeTue;
@property (strong, nonatomic) IBOutlet UILabel *startTimeWed;
@property (strong, nonatomic) IBOutlet UILabel *endTimeWed;
@property (strong, nonatomic) IBOutlet UILabel *startTimeThu;
@property (strong, nonatomic) IBOutlet UILabel *endTimeThu;
@property (strong, nonatomic) IBOutlet UILabel *startTimeFri;
@property (strong, nonatomic) IBOutlet UILabel *endTimeFri;
@property (strong, nonatomic) IBOutlet UILabel *startTimeSat;
@property (strong, nonatomic) IBOutlet UILabel *endTimeSat;
@property (strong, nonatomic) IBOutlet UILabel *startTimeSun;
@property (strong, nonatomic) IBOutlet UILabel *endTimeSun;


@property (strong, nonatomic) IBOutlet MKMapView *mMapView;


@property (strong, nonatomic) IBOutlet ThumbnailListView* thumbnailListView;
@property (strong, nonatomic) IBOutlet UIImageView *ivChoose;

@property (strong, nonatomic) IBOutlet UILabel *lbDiscountTagLine;

@property (strong, nonatomic) IBOutlet UILabel *lbOriginPrice;
@property (strong, nonatomic) IBOutlet UIView *subDiscayPriceView;
@property (strong, nonatomic) IBOutlet UILabel *lbDiscayOriginPrice;
@property (strong, nonatomic) IBOutlet UILabel *lbDiscaySpecialPrice;

@property (strong, nonatomic) IBOutlet UILabel *lbDiscayRemaining;

@property (strong, nonatomic) IBOutlet UILabel *lbDealName;
@property (strong, nonatomic) IBOutlet UILabel *lbProductDescription;

@property (strong, nonatomic) IBOutlet UIView *viewDeal;

@end
