//
//  CustomTextField.m
//  Lucid Dream
//
//  Created by Oleg on 7/20/15.
//  Copyright (c) 2015 Accetturo. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

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
    
    UIColor * placeHolderColor = [UIColor colorWithRed:171.0f/255.0f green:180.0f/255.0f blue:181.0f/255.0f alpha:1.0];
    [self setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    
//    self.backgroundColor = [UIColor colorWithRed:37.0f/255.0f green:94.0f/255.0f blue:120.0f/255.0f alpha:1.0];
//    
//    self.layer.borderColor = [UIColor clearColor].CGColor;
//    self.layer.borderWidth = 1;
//    self.layer.cornerRadius = 5;
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
