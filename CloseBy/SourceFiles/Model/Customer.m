//
//  Merchant.m
//  CloseBy
//
//  Created by Arslan Raza on 16/01/2015.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "Customer.h"

@implementation Customer

#pragma mark - Private Methods

#pragma mark - Life Cycle Methods

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.customerID = [decoder decodeIntegerForKey:@"customerID"];
    self.shopingcenterID = [decoder decodeIntegerForKey:@"shopingcenterid"];
    self.fullName = [decoder decodeObjectForKey:@"fullName"];
    self.fbToken = [decoder decodeObjectForKey:@"fbToken"];
    self.email = [decoder decodeObjectForKey:@"email"];
    self.country = [decoder decodeObjectForKey:@"country"];
    self.bID = [decoder decodeObjectForKey:@"bID"];
    
    self.businessName = [decoder decodeObjectForKey:@"businessName"];
    self.businessAddress = [decoder decodeObjectForKey:@"businessAddress"];
    self.shoppingCentre = [decoder decodeObjectForKey:@"shoppingCentre"];
    
    self.isBusiness = [decoder decodeBoolForKey:@"isBusiness"];
    self.hasCategories = [decoder decodeBoolForKey:@"hasCategories"];
    
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.customerID forKey:@"customerID"];
    [encoder encodeInteger:self.shopingcenterID forKey:@"shopingcenterid"];
    [encoder encodeObject:self.fullName forKey:@"fullName"];
    [encoder encodeObject:self.fbToken forKey:@"fbToken"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.country forKey:@"country"];
    [encoder encodeObject:self.bID forKey:@"bID"];
    
    [encoder encodeObject:self.businessName forKey:@"businessName"];
    [encoder encodeObject:self.businessAddress forKey:@"businessAddress"];
    [encoder encodeObject:self.shoppingCentre forKey:@"shoppingCentre"];
    
    [encoder encodeBool:self.isBusiness forKey:@"isBusiness"];
    [encoder encodeBool:self.hasCategories forKey:@"hasCategories"];
}

- (id)init {
    if (( self = [super init] )) {
        
    }
    return self;
}

+ (id)createNewCustomerWithJSon:(NSDictionary*)element {
    
    Customer *newCustomer = [[Customer alloc] init];
    if (newCustomer) {
        
        newCustomer.customerID = [[GlobalAPI getJsonElementString:element key:@"FullName"] integerValue];
        newCustomer.shopingcenterID = [[GlobalAPI getJsonElementString:element key:@"shopingcenterid"] integerValue];
        newCustomer.fullName = [GlobalAPI getJsonElementString:element key:@"FullName"];
        newCustomer.fbToken = [GlobalAPI getJsonElementString:element key:@"FACEBOOKID"];
        newCustomer.email = [GlobalAPI getJsonElementString:element key:@"email"];
        newCustomer.country = [GlobalAPI getJsonElementString:element key:@"country"];
        
        newCustomer.isBusiness = [[GlobalAPI getJsonElementString:element key:@"isBusiness"] boolValue];
        newCustomer.hasCategories = [[GlobalAPI getJsonElementString:element key:@"hasCategories"] boolValue];
        
        newCustomer.businessName = [GlobalAPI getJsonElementString:element key:@"BusinessName"];
        newCustomer.businessAddress = [GlobalAPI getJsonElementString:element key:@"BusinessAddress"];
        newCustomer.shoppingCentre = [GlobalAPI getJsonElementString:element key:@"ShoppingCenterName"];
        
    }
    
    return newCustomer;
    
    return nil;
}


#pragma mark - Public Methods



@end
