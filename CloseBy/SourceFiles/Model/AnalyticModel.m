//
//  AnalyticModel.m
//  CloseBy
//
//  Created by arian on 12/30/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "AnalyticModel.h"

@implementation AnalyticModel

+(id)initWithJsonElement:(NSDictionary *)element {
    AnalyticModel *exploreData = [[AnalyticModel alloc] init];
    exploreData.Impressions = [GlobalAPI getJsonElementString:element key:@"Impressions"];
    exploreData.Clicks = [GlobalAPI getJsonElementString:element key:@"Clicks"];
    exploreData.CheckIns = [GlobalAPI getJsonElementString:element key:@"CheckIns"];
    
    exploreData.topProductArray = [NSMutableArray array];
    NSArray *productDetail = [element objectForKey:@"TopProducts"];
    for (NSDictionary *element in productDetail) {
        [exploreData.topProductArray addObject:[TopProductModel initWithJsonElement:element]];
    }
    
    NSDictionary *nCustomerPercentData = [element objectForKey:@"NewVsReturning"];
    exploreData.nCustomerModel = [NewCustomerPercentModel initWithJsonElement:nCustomerPercentData];
    
    return exploreData;
}

@end
