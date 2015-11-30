//
//  Merchant.h
//  CloseBy
//
//  Created by Arslan Raza on 16/01/2015.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Customer : NSObject <NSCoding>

@property (readwrite, assign) NSInteger customerID;
@property (readwrite, assign) NSInteger shopingcenterID;


@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *fbToken;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *bID;

@property (nonatomic, strong) NSString *businessName;
@property (nonatomic, strong) NSString *businessAddress;
@property (nonatomic, strong) NSString *shoppingCentre;

@property (readwrite, assign) BOOL isBusiness;
@property (readwrite, assign) BOOL hasCategories;


+ (id)createNewCustomerWithJSon:(NSDictionary*)element;

@end
