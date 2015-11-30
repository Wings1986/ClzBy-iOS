//
//  ProductModel.h
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductModel : NSObject

@property (strong, nonatomic) NSString *productId;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productPhoto;
@property (strong, nonatomic) NSString *businessId;
@property (strong, nonatomic) NSString *discountedTag;
@property (strong, nonatomic) NSString *posId;
@property (readwrite, assign) BOOL currentState;

@property (readwrite, assign) NSInteger catID;



@property (strong, nonatomic) UIImage *productImage;

+(id)initWithJsonElement:(NSDictionary *)element;

@end
