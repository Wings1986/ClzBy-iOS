//
//  ProductTableViewCell.m
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "UIImageView+AFNetworking.h"

#define kGreenColor [UIColor colorWithRed:144/255.0 green: 202/255.0 blue: 119/255.0 alpha: 1.0]
#define kBlueColor [UIColor colorWithRed:129/255.0 green: 198/255.0 blue: 221/255.0 alpha: 1.0]
#define kYellowColor [UIColor colorWithRed:233/255.0 green: 182/255.0 blue: 77/255.0 alpha: 1.0]
#define kOrangeColor [UIColor colorWithRed:288/255.0 green: 135/255.0 blue: 67/255.0 alpha: 1.0]
#define kRedColor [UIColor colorWithRed:158/255.0 green: 59/255.0 blue: 51/255.0 alpha: 1.0]

@implementation ProductTableViewCell

@synthesize delegate = _delegate;

- (void)awakeFromNib {
    // Initialization code
    [KLSwitch class];
    
//    [self.switchButton setOnTintColor: kBlueColor];
    
}

//@property (weak, nonatomic) IBOutlet UIView *discountedTagBackground;
//@property (weak, nonatomic) IBOutlet UILabel *discountedTagLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *productLogoView;
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
//@property (weak, nonatomic) IBOutlet UILabel *productTypeLabel;

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)setData:(DealModel *)modelData {
    [self.layer setCornerRadius:7.0];
    self.cellData = modelData;
    
    self.titleLabel.text = modelData.productData.productName;
    
    [self.toggleButton setTitle:self.cellData.productData.currentState?@"ON":@"OFF" forState:UIControlStateNormal];
    [self.switchButton setOn:self.cellData.productData.currentState];
    
//    [self.productImageView setImageWithURL:[NSURL URLWithString:modelData.productData.productPhoto] placeholderImage:[UIImage imageNamed:@"postphoto_placeholder"]];
    
    if (self.cellData.productData.productImage) {
        
        [self.productImageView setImage:self.cellData.productData.productImage];
        
    } else {
        
        [self.productImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:modelData.productData.productPhoto]] placeholderImage:[UIImage imageNamed:@"postphoto_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            image = [self imageWithImage:image scaledToWidth:self.productImageView.frame.size.width];
            self.cellData.productData.productImage = image;//self.productImageView.image;
            [self.productImageView setImage:image];
            //        NSLog(@"Updated Image Data");
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    
    }
    
    self.dateLabel.text = modelData.businessName;
    self.productTypeLabel.text = modelData.categoryName;
    
    [self.productLogoView setImageWithURL:[NSURL URLWithString:modelData.busLogo] placeholderImage:[UIImage imageNamed:@"logo_shopping"]];
    
    UIFont *discountedTagFont = [UIFont fontWithName:@"kalinga" size:14];
    self.discountedTagLabel.text = modelData.productData.discountedTag;
    self.discountedTagLabel.font = discountedTagFont;
    CGSize textSize =[modelData.productData.discountedTag sizeWithFont:discountedTagFont
                                 forWidth:320.0f
                            lineBreakMode:NSLineBreakByTruncatingTail];
    
    int newWidth = textSize.width + 20;
    
    self.discountedBackWidth.constant = newWidth;
    self.discountedLabelWidth.constant = newWidth;
    
    UIFont *productTypeFont = [UIFont fontWithName:@"kalinga" size:15];
    self.productTypeLabel.text = modelData.categoryName;
    self.productTypeLabel.font = productTypeFont;
    CGSize categorySize =[modelData.categoryName sizeWithFont:productTypeFont
                                                     forWidth:320.0f
                                                lineBreakMode:NSLineBreakByTruncatingTail];
    int newCategoryWidth = categorySize.width + 20;
    
    self.categoryBackWidth.constant = newCategoryWidth;
    self.categoryLabelWidth.constant = newCategoryWidth;
    [self layoutSubviews];
}

- (IBAction)editPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(productTableViewCell:didTapAtIndexPath:)]) {
        [self.delegate productTableViewCell:self didTapAtIndexPath:self.indexPath];
    }
}

- (IBAction)togglePressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(productTableViewCell:changedToggleStatus:atIndexPath:)]) {
        [self.delegate productTableViewCell:self changedToggleStatus:!self.cellData.productData.currentState atIndexPath:self.indexPath];
    }
}

- (IBAction)switchValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(productTableViewCell:changedToggleStatus:atIndexPath:)]) {
        [self.delegate productTableViewCell:self changedToggleStatus:!self.cellData.productData.currentState atIndexPath:self.indexPath];
    }
}

@end
