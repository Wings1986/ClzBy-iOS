//
//  NewCustomerPercentage.h
//  CloseBy
//
//  Created by arian on 12/30/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewCustomerPercentModel : NSObject

@property (strong, nonatomic) NewCustomerPercentModel *productData;

@property (strong, nonatomic) NSString *NewCustomersPercentage;
@property (strong, nonatomic) NSString *ReturningCustomersPercentage;
@property (strong, nonatomic) NSString *NoOfNewCustomers;
@property (strong, nonatomic) NSString *NoOfReturningCustomers;

+(id)initWithJsonElement:(NSDictionary *)element;

@end
