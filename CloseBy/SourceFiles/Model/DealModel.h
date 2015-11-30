//
//  DealModel.h
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductModel.h"

@interface DealModel : NSObject

@property (strong, nonatomic) ProductModel *productData;

@property (strong, nonatomic) NSString *businessName;
@property (strong, nonatomic) NSString *busAddrUserInput;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSString *busLogo;

@property (nonatomic, assign) NSIndexPath *indexPath;

+(id)initWithJsonElement:(NSDictionary *)element;
+ (id)initWithProductName:(NSString*)pName tagLine:(NSString*)pTag categoryName:(NSString*)category image:(UIImage*)pImage;
+ (id)initWithDealData:(NSDictionary*)dealData;

@end
