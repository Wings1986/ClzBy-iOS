//
//  RoundButton.m
//  CloseBy
//
//  Created by iGold on 7/27/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

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
        [self initButton];
    }
    
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initButton];
    }
    
    return self;
}

- (void) initButton {
    
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = APP_COLOR.CGColor;
}

@end
