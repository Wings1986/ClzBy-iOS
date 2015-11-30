//
//  ProductModel.m
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "ProductModel.h"

@implementation ProductModel

+(id)initWithJsonElement:(NSDictionary *)element {
    ProductModel *exploreData = [[ProductModel alloc] init];
    exploreData.productId = [GlobalAPI getJsonElementString:element key:@"ID"];
    exploreData.productName = [GlobalAPI getJsonElementString:element key:@"ProductName"];
    exploreData.productPhoto = [GlobalAPI getJsonElementString:element key:@"ProductPhoto"];
    exploreData.businessId = [GlobalAPI getJsonElementString:element key:@"BusinessID"];
    exploreData.discountedTag = [GlobalAPI getJsonElementString:element key:@"DiscountedTagLine"];
    exploreData.posId = [GlobalAPI getJsonElementString:element key:@"POS_ID"];
    exploreData.currentState = [[GlobalAPI getJsonElementString:element key:@"CurrentState"] boolValue];
    exploreData.catID = [[GlobalAPI getJsonElementString:element key:@"CatID"] integerValue];
    
    return exploreData;
}

@end
