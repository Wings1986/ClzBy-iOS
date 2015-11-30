//
//  DealCollectionViewCell.m
//  CloseBy
//
//  Created by iGold on 4/7/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "DealCollectionViewCell.h"

@implementation DealCollectionViewCell

- (void) awakeFromNib
{
    self.lbTagLine.numberOfLines = self.lbDealName.numberOfLines = self.lbDealDescription.numberOfLines = self.lbDealSubCategory.numberOfLines = 0;
    
}

@end
