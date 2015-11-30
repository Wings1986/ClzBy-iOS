//
//  CB_AlertView.m
//  CB_AlertView
//
//  Created by Arslan Raza on 14/01/2015.
//  Copyright (c) 2015 arkTechs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CB_AlertView.h"

#define kALPHA_VALUE    0.5f
#define kANIM_TIME      0.3f


@interface CB_AlertView () {
    BOOL _isVisible;
}

@end


@implementation CB_AlertView

static CB_AlertView *_sharedView = nil;


#pragma mark - Private Methods

- (void)fadeIn {

    if (!_isVisible) {
        _isVisible = YES;
        [UIView animateWithDuration:kANIM_TIME animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

- (void)fadeOut {
    
    if (_isVisible) {
        _isVisible = NO;
        [UIView animateWithDuration:kANIM_TIME animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    
}


#pragma mark - Class Methods

- (id)init {
    
    if (( self = [super init] )) {
        
    }
    
    return self;
}

+ (CB_AlertView*)getSharedView {
    
    if (!_sharedView) {
        _sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CB_AlertView" owner:self options:nil] objectAtIndex:0];
        
        _sharedView.loadingGif.image = [UIImage imageNamed:@"clzby.gif"];
    }
    
    return _sharedView;
    
}

+ (CB_AlertView*)createAlert {
    CB_AlertView *aView = [[[NSBundle mainBundle] loadNibNamed:@"CB_AlertView" owner:self options:nil] objectAtIndex:0];
    if (aView) {
        
    }
    return aView;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (( self = [super initWithCoder:aDecoder])) {
        NSLog(@"CoverView InitWithCoder called");
        _isVisible = NO;
        
        
        
        

    }
    return self;
}

#pragma mark - Public Methods

+ (id)createAlertForView:(UIView*)parentView {
    CB_AlertView *alertView = [CB_AlertView getSharedView];
    
    if (alertView) {
        
        if (alertView.superview) {
            [alertView removeFromSuperview];
        }
        alertView.backdrop.backgroundColor = [UIColor blackColor];
        alertView.backdrop.alpha = kALPHA_VALUE;
        
        alertView.frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height);
        [parentView addSubview:alertView];
        
        alertView.alpha = 0.0f;
        
        [alertView fadeIn];
    }
    
    return alertView;
}

+ (CB_AlertView*)showAlertOnView:(UIView*)parentView {
    
        
    CB_AlertView *alertView = [CB_AlertView getSharedView];
    
    if (alertView) {
        
        if (alertView.superview) {
            [alertView removeFromSuperview];
        }
        alertView.backdrop.backgroundColor = [UIColor blackColor];
        alertView.backdrop.alpha = kALPHA_VALUE;
        
        alertView.frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height);
        [parentView addSubview:alertView];
        
        alertView.alpha = 0.0f;
        
        [alertView fadeIn];
    }
    
    return alertView;
    
}

+ (void)hideAlert {
    [_sharedView fadeOut];
}




@end
