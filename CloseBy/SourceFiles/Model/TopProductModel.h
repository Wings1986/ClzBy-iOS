//
//  TopProductModel.h
//  CloseBy
//
//  Created by arian on 12/30/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopProductModel : NSObject

@property (strong, nonatomic) TopProductModel *productData;

@property (strong, nonatomic) NSString *productid;
@property (strong, nonatomic) NSString *productname;
@property (strong, nonatomic) NSString *cnt;

+(id)initWithJsonElement:(NSDictionary *)element;

@end
