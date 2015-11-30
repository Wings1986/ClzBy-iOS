//
//  TopProductModel.m
//  CloseBy
//
//  Created by arian on 12/30/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "TopProductModel.h"

@implementation TopProductModel

+(id)initWithJsonElement:(NSDictionary *)element {
    TopProductModel *exploreData = [[TopProductModel alloc] init];
    exploreData.productid = [GlobalAPI getJsonElementString:element key:@"productid"];
    exploreData.productname = [GlobalAPI getJsonElementString:element key:@"productname"];
    exploreData.cnt = [GlobalAPI getJsonElementString:element key:@"cnt"];
    
    
    return exploreData;
}

@end
