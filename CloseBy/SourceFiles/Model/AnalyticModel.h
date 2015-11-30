//
//  AnalyticModel.h
//  CloseBy
//
//  Created by arian on 12/30/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopProductModel.h"
#import "NewCustomerPercentModel.h"

@interface AnalyticModel : NSObject

@property (strong, nonatomic) AnalyticModel *productData;

@property (strong, nonatomic) NSString *Impressions;
@property (strong, nonatomic) NSString *Clicks;
@property (strong, nonatomic) NSString *CheckIns;

@property (strong, nonatomic) NSMutableArray *topProductArray;
@property (strong, nonatomic) NewCustomerPercentModel *nCustomerModel;

+(id)initWithJsonElement:(NSDictionary *)element;


@end
