//
//  CB_ShoppingMall.m
//  CloseBy
//
//  Created by Arslan Raza on 15/01/2015.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "CB_ShoppingMall.h"

@implementation CB_ShoppingMall

+(id)initWithJsonElement:(NSDictionary *)element {
    
    CB_ShoppingMall *smObj = [[CB_ShoppingMall alloc] init];
    smObj.smID = [[GlobalAPI getJsonElementString:element key:@"ID"] integerValue];
    smObj.smName = [GlobalAPI getJsonElementString:element key:@"Name"];
    
    return smObj;
}


@end
