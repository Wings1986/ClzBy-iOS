//
//  ProfileCollectionViewCell.h
//  CloseBy
//
//  Created by iGold on 4/7/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCollectionViewCell : UICollectionViewCell


@property (strong, nonatomic) IBOutlet UIImageView *ivBusinessLogo;
@property (strong, nonatomic) IBOutlet UILabel *lbBusinessName;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UILabel *lbLikes;

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lbOriginPrice;
@property (strong, nonatomic) IBOutlet UIView *subDecayView;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayOriginPrice;
@property (strong, nonatomic) IBOutlet UILabel *lbDecayingSpecialPrice;


@property (weak, nonatomic) IBOutlet UILabel *lbDealName;
@property (weak, nonatomic) IBOutlet UITextView *lbDealDescription;

@property (strong, nonatomic) IBOutlet UILabel *lbDecayDuration;


@end
