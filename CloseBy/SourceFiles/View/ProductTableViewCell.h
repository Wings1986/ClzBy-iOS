//
//  ProductTableViewCell.h
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DealModel.h"
#import "KLSwitch.h"

@protocol ProductTableViewDelegate;


#pragma mark - ProductTableViewCell

@interface ProductTableViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *discountedTagBackground;
@property (weak, nonatomic) IBOutlet UILabel *discountedTagLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIImageView *productLogoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *productTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@property (readwrite, assign) BOOL toggleStatus;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountedLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountedBackWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categoryLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categoryBackWidth;

@property (nonatomic, strong) DealModel* cellData;
@property (nonatomic, strong) NSIndexPath* indexPath;

@property (nonatomic, assign) id<ProductTableViewDelegate> delegate;

- (void)setData:(DealModel *)modelData;
- (IBAction)editPressed:(id)sender;
- (IBAction)togglePressed:(id)sender;
- (IBAction)switchValueChanged:(id)sender;

@end

#pragma mark - ProductTableViewDelegate

@protocol ProductTableViewDelegate <NSObject>

- (void)productTableViewCell:(ProductTableViewCell*)cell didTapAtIndexPath:(NSIndexPath*)indexPath;
- (void)productTableViewCell:(ProductTableViewCell*)cell changedToggleStatus:(BOOL)status atIndexPath:(NSIndexPath*)indexPath;

@end
