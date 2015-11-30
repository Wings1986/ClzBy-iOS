//
//  NewCustomerPercentage.m
//  CloseBy
//
//  Created by arian on 12/30/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "NewCustomerPercentModel.h"

@implementation NewCustomerPercentModel

+(id)initWithJsonElement:(NSDictionary *)element {
    NewCustomerPercentModel *exploreData = [[NewCustomerPercentModel alloc] init];
    exploreData.NewCustomersPercentage = [GlobalAPI getJsonElementString:element key:@"NewCustomersPercentage"];
    exploreData.ReturningCustomersPercentage = [GlobalAPI getJsonElementString:element key:@"ReturningCustomersPercentage"];
    exploreData.NoOfNewCustomers = [GlobalAPI getJsonElementString:element key:@"NoOfNewCustomers"];
    exploreData.NoOfReturningCustomers = [GlobalAPI getJsonElementString:element key:@"NoOfReturningCustomers"];
    
    return exploreData;
}

@end
