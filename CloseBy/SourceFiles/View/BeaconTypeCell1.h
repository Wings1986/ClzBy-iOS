//
//  BeaconTypeCell1.h
//  CloseBy
//

#import <UIKit/UIKit.h>


@interface BeaconTypeCell1 : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *chBeaconEnable;

@property (strong, nonatomic) IBOutlet UIButton *btnTest;
@property (strong, nonatomic) IBOutlet UIButton *btnEditType;
@property (strong, nonatomic) IBOutlet UIButton *btnEditMessage;

@property (strong, nonatomic) IBOutlet UIView *viewSub;

@property (strong, nonatomic) IBOutlet UIView *viewBeaconData;
@property (strong, nonatomic) IBOutlet UILabel *lbBeaconTitle;
@property (strong, nonatomic) IBOutlet UILabel *lbBeaconTagline;
@property (strong, nonatomic) IBOutlet UILabel *lbBeaconDescription;
@property (strong, nonatomic) IBOutlet UIImageView *ivBeaconImage;

@end
