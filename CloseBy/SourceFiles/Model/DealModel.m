//
//  DealModel.m
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "DealModel.h"

@implementation DealModel

+(id)initWithJsonElement:(NSDictionary *)element {
    DealModel *exploreData = [[DealModel alloc] init];
    exploreData.businessName = [GlobalAPI getJsonElementString:element key:@"BusinessName"];
    exploreData.busAddrUserInput = [GlobalAPI getJsonElementString:element key:@"BusinessAddressUserInput"];
    exploreData.categoryName = [GlobalAPI getJsonElementString:element key:@"CategoryName"];
    exploreData.busLogo = [GlobalAPI getJsonElementString:element key:@"LogoImage"];
    
    NSDictionary *productDetail = [element objectForKey:@"Deals"];
    if (!productDetail) {
        productDetail = [element objectForKey:@"Deal"];
    }
    exploreData.productData = [ProductModel initWithJsonElement:productDetail];
    
    return exploreData;
}

+ (id)initWithProductName:(NSString*)pName tagLine:(NSString*)pTag categoryName:(NSString*)category image:(UIImage*)pImage {
    
    DealModel *exploreData = [[DealModel alloc] init];
    
    exploreData.productData = [[ProductModel alloc] init];
    exploreData.productData.productName = pName;
    exploreData.productData.discountedTag = pTag;
    exploreData.productData.productImage = pImage;
    exploreData.categoryName = category;
    
    return exploreData;
    
}

+ (id)initWithDealData:(NSDictionary*)dealData {
    DealModel *exploreData = [[DealModel alloc] init];
    exploreData.businessName = [dealData objectForKey:@"BusinessName"];
    exploreData.categoryName = [dealData objectForKey:@"MainCategoryID"];
    
    return exploreData;
}

@end
