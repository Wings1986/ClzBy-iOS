//
//  MenuProfileCell.m
//  CloseBy
//

#import "MenuProfileCell.h"

@implementation MenuProfileCell

- (void)awakeFromNib {
    // Initialization code
    
    self.viewPic.layer.cornerRadius = self.viewPic.frame.size.width / 2;
    self.viewPic.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewPic.layer.borderWidth = 2;
    self.viewPic.clipsToBounds = YES;

    self.ivPic.layer.cornerRadius = self.ivPic.frame.size.width / 2;
    self.ivPic.clipsToBounds = YES;

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
