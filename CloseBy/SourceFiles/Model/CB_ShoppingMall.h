//
//  CB_ShoppingMall.h
//  CloseBy
//
//  Created by Arslan Raza on 15/01/2015.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CB_ShoppingMall : NSObject

// sm = Shopping Mall
@property (readwrite, assign) NSInteger smID;
@property (nonatomic, strong) NSString *smName;

+(id)initWithJsonElement:(NSDictionary *)element;

@end
