//
//  UICustomLabel.m
//  CloseBy
//
//  Created by arian on 12/23/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "UICustomLabel.h"

@implementation UICustomLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setFont:[UIFont fontWithName:@"kalinga" size:12.0]];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setFont:[UIFont fontWithName:@"kalinga" size:12.0]];
    }
    return self;
}

-(void)setFontSize:(int)size {
    [self setFont:[UIFont fontWithName:@"kalinga" size:size]];
}

@end
