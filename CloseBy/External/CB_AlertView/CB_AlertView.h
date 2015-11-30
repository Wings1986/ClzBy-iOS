//
//  CB_AlertView.h
//  CB_AlertView
//
//  Created by Arslan Raza on 14/01/2015.
//  Copyright (c) 2015 arkTechs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AnimatedGIFImageSerialization.h"

@interface CB_AlertView: UIView {
    
}

@property (nonatomic, weak) IBOutlet UIView *backdrop;
@property (nonatomic, weak) IBOutlet UIImageView *loadingGif;

+ (CB_AlertView*)createAlert;
+ (CB_AlertView*)showAlertOnView:(UIView*)view;
+ (void)hideAlert;



@end

