//
//  UIAlertView+Extras.m
//  CellSmart
//
//  Created by Arslan Raza on 25/09/2014.
//  Copyright (c) 2014 ArkTechs. All rights reserved.
//

#import "UIAlertView+Extras.h"

@implementation UIAlertView (Extras)

+ (UIAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message delegate:(id)alertDelegate cancelButton:(NSString*)cancelButton otherButtons:(NSString *)otherButtonTitles, ...  NS_REQUIRES_NIL_TERMINATION {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertDelegate cancelButtonTitle:cancelButton otherButtonTitles:otherButtonTitles, nil];
    //    for (NSString *str in otherButtonTitles) {
    //        [alert addButtonWithTitle:str];
    //    }
    if (otherButtonTitles) {
        va_list argumentList;
        va_start(argumentList, otherButtonTitles);          // Start scanning for arguments after firstObject.
        NSString *eachObject;
        while ((eachObject = va_arg(argumentList, NSString*))) // As many times as we can get an argument of type "id"
        {
            if (eachObject) {
                [alert addButtonWithTitle:eachObject];              // that isn't nil, add it to self's contents.
            }
            
        }
        va_end(argumentList);
    }
    
    
    [alert show];
    
    return alert;
}

@end
