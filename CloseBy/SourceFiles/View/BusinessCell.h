//
//  BusinessCell.h
//  CloseBy
//
//  Created by Denis Cossaks on 4/7/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lbBusinessName;
@property (weak, nonatomic) IBOutlet UILabel *lbBusinessAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbBusinessEmail;

@property (strong, nonatomic) IBOutlet UIImageView *ivLike;
@property (strong, nonatomic) IBOutlet UILabel *lbLikes;

@end
