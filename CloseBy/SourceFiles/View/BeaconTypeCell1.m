//
//  BeaconTypeCell1.m
//  CloseBy
//

#import "BeaconTypeCell1.h"

@implementation BeaconTypeCell1

- (void)awakeFromNib {
    // Initialization code

    _viewSub.layer.cornerRadius = 10;
    _viewSub.backgroundColor = [UIColor clearColor];
    _viewSub.layer.borderColor = APP_COLOR.CGColor;
    _viewSub.layer.borderWidth = 1;
    
    _viewBeaconData.layer.cornerRadius = 10;
    _viewBeaconData.backgroundColor = [UIColor whiteColor];
    _viewBeaconData.layer.borderColor = [UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f].CGColor;
    _viewBeaconData.layer.borderWidth = 1;
    

    _ivBeaconImage.contentMode = UIViewContentModeScaleAspectFill;
    _ivBeaconImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
