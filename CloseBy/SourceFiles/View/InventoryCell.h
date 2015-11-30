//
//  InventoryCell.h
//  CloseBy
//
//  Created by iGold on 3/11/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *ivProductPicture;
@property (strong, nonatomic) IBOutlet UILabel *lbProductName;
@property (strong, nonatomic) IBOutlet UILabel *lbProductCategory;
@property (strong, nonatomic) IBOutlet UITextView *lbProductDescription;

@property (strong, nonatomic) IBOutlet UILabel *lbOriginPrice;
@property (strong, nonatomic) IBOutlet UIView *subDecayView;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayOriginPrice;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayingSpecialPrice;

@property (strong, nonatomic) IBOutlet UILabel *lbDiscountTagLine;
@property (strong, nonatomic) IBOutlet UILabel *lbRemainQuality;


@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UIButton *btnSetting;

@property (strong, nonatomic) IBOutlet UISwitch *swEnable;

@property (strong, nonatomic) IBOutlet UIView *subDecayTimeView;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayDuration;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintDecayViewHeight;

@end
