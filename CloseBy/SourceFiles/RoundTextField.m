//
//  RoundTextField.m
//  CloseBy
//
//  Created by iGold on 7/27/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "RoundTextField.h"

@implementation RoundTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initTextField];
    }
    
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initTextField];
    }
    
    return self;
}

- (void) initTextField {
    
    UIColor * placeHolderColor = [UIColor colorWithRed:169.0f/255.0f green:169.0f/255.0f blue:169.0f/255.0f alpha:1.0];
    [self setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    
    self.layer.borderColor = APP_COLOR.CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = self.frame.size.height / 2;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset( bounds , 10 , 10 );
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset( bounds , 10 , 10 );
}


@end
