//
//  UIAlertView+Extras.h
//  CellSmart
//
//  Created by Arslan Raza on 25/09/2014.
//  Copyright (c) 2014 ArkTechs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Extras)

+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message delegate:(id)alertDelegate cancelButton:(NSString*)cancelButton otherButtons:(NSString *)otherButtonTitles, ...;

@end
