//
//  GlobalAPI.h
//  DeliverIt
//
//  Created by arian on 11/30/14.
//  Copyright (c) 2014 cameron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Customer.h"

@interface GlobalAPI : NSObject

+(NSString *)getStringFromSeconds:(int)diff;
+ (NSString *)getJsonElementString:(NSDictionary *)data key:(NSString *)key;
+ (void)showAlertView:(NSString *)alertTitle message:(NSString *)message;
+(BOOL) NSStringIsValidEmail:(NSString *)checkString;


+ (void)setCurrentBID:(NSString *)value;
+ (NSString *)getCurrentBID;

+ (void)setCustomerEmail:(NSString *)value;
+ (NSString *)getCustomerEmail;

+ (void)setAnonymousCustomerId:(NSString *)value;
+ (NSString *)getAnonymousCustomerId;

+ (void)setAnonymousStatus:(BOOL)value;
+ (BOOL)getAnonymousStatus;

+ (void)setCurrentCID:(NSString *)value;
+ (NSString *)getCurrentCID;

+ (NSString*)getDeviceHash;

+ (void)setAlertDisplayStatus:(BOOL)value;
+ (BOOL)getAlertStatus;

+ (void)setMerchantLogin:(BOOL)value;
+ (BOOL)getMerchantLogin;

+ (void)setCurrentCustomer:(Customer*)customer;
+ (Customer*)getCurrentCustomer;

+ (NSString*)getNewDeviceToken;
+ (void)saveNewDeviceToken:(NSString*)deviceToken;

+ (NSString*)getOldDeviceToken;
+ (void)saveOldDeviceToken:(NSString*)deviceToken;

+ (BOOL)getRemeberMe;
+ (void)setRememberMe:(BOOL)shouldRemember;

+ (void)setMerchantEmail:(NSString*)email password:(NSString*)password;
+ (NSString*)getMerchantEmail;
+ (NSString*)getMerchantPassword;


+(UIImage *)dataFromBase64EncodedString:(NSString *)string64;
+ (NSString *)base64StringForImage:(UIImage*)image;


+ (void) storeLoginID:(NSString*)userID;
+ (NSString*) loadLoginID;

+ (void) storeUserType:(BOOL) isBusiness;
+ (BOOL) isBusiness;

+ (void) storeUsername:(NSString*)userName;
+ (NSString*) loadUsername;
//+ (void) storeUserImage:(UIImage*) image;
//+ (UIImage*) loadUserImage;
+ (void) storeUserImage:(NSString*) imageURL;
+ (NSString*) loadUserImage;


+ (NSString*) getLeftTime:(NSString* ) strEndTime;

@end
