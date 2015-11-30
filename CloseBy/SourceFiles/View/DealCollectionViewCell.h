//
//  DealCollectionViewCell.h
//  CloseBy
//
//  Created by iGold on 4/7/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBSwitch.h"

@interface DealCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIView *viewParent;


@property (strong, nonatomic) IBOutlet UIImageView *ivBusinessLogo;
@property (strong, nonatomic) IBOutlet UILabel *lbBusinessName;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UILabel *lbLikes;

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lbOriginPrice;
@property (strong, nonatomic) IBOutlet UIView *subDecayView;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayOriginPrice;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayingSpecialPrice;


@property (strong, nonatomic) IBOutlet UILabel *lbTagLine;
@property (weak, nonatomic) IBOutlet UILabel *lbDealName;
@property (weak, nonatomic) IBOutlet UILabel *lbDealDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbDealSubCategory;

@property (strong, nonatomic) IBOutlet UIView *subDecayTimeView;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayDuration;

@property (weak, nonatomic) IBOutlet UIButton *btnMap;


// additional
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UIButton *btnSetting;

@property (strong, nonatomic) IBOutlet UISwitch *swEnable;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintAllTextHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintTaglineHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintNameHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintDescriptionHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintSubHeight;

@end
