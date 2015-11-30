//
//  GlobalAPI.m
//  DeliverIt
//
//  Created by arian on 11/30/14.
//  Copyright (c) 2014 cameron. All rights reserved.
//

#import "GlobalAPI.h"
#import "SSKeychain.h"

@implementation GlobalAPI

#define         BID_StoreKey                    @"BIDKey"
#define         CID_StoreKey                    @"CIDKey"
#define         userID_StoreKey                 @"userIDKey"
#define         CustomerEmail_StoreKey          @"customerEmailKey"
#define         AnonymousCustomer_StoreKey      @"anonymousEmailKey"
#define         ACustomer_StoreKey              @"setAnonymousStatus"
#define         kAlert_Status                   @"SettingsAlertStatus"
#define         kMerchant_Login                 @"Merchant_Login"
#define         kKey_Customer                   @"current_customer"
#define         kKEY_NEW_DEVICE_TOKEN           @"new_device_token"
#define         kKEY_OLD_DEVICE_TOKEN           @"old_device_token"
#define         kKEY_REMEBER_ME                 @"remember_me"
#define         kKEY_MERCHANT_EMAIL             @"merchant_email"
#define         kKEY_MERCHANT_PASSWORD          @"merchant_password"

#define         kLoginID                        @"user_login_id"
#define         kUserType                       @"user_type"
#define         kUserImage                      @"user_image"
#define         kUserName                       @"user_name"


+(NSString *)getStringFromSeconds:(int)diff {
    int sec = diff;//INFO: time in seconds
    
    int a_sec = 1;
    int a_min = a_sec * 60;
    int an_hour = a_min * 60;
    int a_day = an_hour * 24;
    int a_month = a_day * 30;
    int a_year = a_day * 365;
    
    NSString *text = @"";
    if (sec >= a_year)
    {
        int years = floor(sec / a_year);
        text = [NSString stringWithFormat:@"%d year%@ ", years, years > 0 ? @"s" : @""];
        sec = sec - (years * a_year);
    }
    
    if (sec >= a_month)
    {
        int months = floor(sec / a_month);
        text = [NSString stringWithFormat:@"%@%d month%@ ", text, months, months > 0 ? @"s" : @""];
        sec = sec - (months * a_month);
        
    }
    
    if (sec >= a_day)
    {
        int days = floor(sec / a_day);
        text = [NSString stringWithFormat:@"%@%d day%@ ", text, days, days > 0 ? @"s" : @""];
        
        sec = sec - (days * a_day);
    }
    
    if (sec >= an_hour)
    {
        int hours = floor(sec / an_hour);
        text = [NSString stringWithFormat:@"%@%d hour%@ ", text, hours, hours > 0 ? @"s" : @""];
        
        sec = sec - (hours * an_hour);
    }
    
    if (sec >= a_min)
    {
        int minutes = floor(sec / a_min);
        text = [NSString stringWithFormat:@"%@%d minute%@ ", text, minutes, minutes > 0 ? @"s" : @""];
        
        sec = sec - (minutes * a_min);
    }
    
//    if (sec >= a_sec)
//    {
//        int seconds = floor(sec / a_sec);
//        text = [NSString stringWithFormat:@"%@%d second%@", text, seconds, seconds > 0 ? @"s" : @""];
//    }
    return text;
}

+ (NSString *)getJsonElementString:(NSDictionary *)data key:(NSString *)key {
    NSString *value = [NSString stringWithFormat:@"%@", [data valueForKey:key]];
    if (value == (id)[NSNull null] || value == nil || [value length] == 0) {
        value = @"";
    }
    return value;
}

+ (void)showAlertView:(NSString *)alertTitle message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

+(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (void)setCurrentBID:(NSString *)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:BID_StoreKey];
    [defaults synchronize];
}

+ (NSString *)getCurrentBID {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* ret = [defaults valueForKey:BID_StoreKey];
    return ret;
}

+ (void)setCurrentCID:(NSString *)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:CID_StoreKey];
    [defaults synchronize];
}

+ (NSString *)getCurrentCID {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* ret = [defaults valueForKey:CID_StoreKey];
    return ret;
}

+ (void)setCustomerEmail:(NSString *)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:CustomerEmail_StoreKey];
    [defaults synchronize];
}

+ (NSString *)getCustomerEmail {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* ret = [defaults valueForKey:CustomerEmail_StoreKey];
    if (!ret) {
        ret = [GlobalAPI getAnonymousCustomerId];
    }
    return ret;
}

+ (void)setAnonymousCustomerId:(NSString *)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:AnonymousCustomer_StoreKey];
    [defaults synchronize];
}

+ (NSString *)getAnonymousCustomerId {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* ret = [defaults valueForKey:AnonymousCustomer_StoreKey];
    return ret;
}

+ (void)setAnonymousStatus:(BOOL)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:ACustomer_StoreKey];
    [defaults synchronize];
}

+ (BOOL)getAnonymousStatus {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL ret = [defaults boolForKey:ACustomer_StoreKey];
    return ret;
}

+ (NSString*)getDeviceHash {
    
    NSString *currentSavedUUID = [SSKeychain passwordForService:kKEY_DEVICE_HASH account:kKEY_ACCOUNT];
    
    // Check if UUID was previously saved.
    if(currentSavedUUID) {
        return currentSavedUUID;
    } else {
        // Create a new UUID for this device and save in keychain
        NSString *uuidString = [[NSUUID UUID] UUIDString];
        [SSKeychain setPassword:uuidString forService:kKEY_DEVICE_HASH account:kKEY_ACCOUNT];
        return uuidString;
    }
}

+ (void)setAlertDisplayStatus:(BOOL)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:kAlert_Status];
    [defaults synchronize];
}

+ (BOOL)getAlertStatus {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL ret = [defaults boolForKey:kAlert_Status];
    return ret;
}

+ (void)setMerchantLogin:(BOOL)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:kMerchant_Login];
    [defaults synchronize];
}
+ (BOOL)getMerchantLogin {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL ret = [defaults boolForKey:kMerchant_Login];
    return ret;
}

+ (void)setCurrentCustomer:(Customer*)customer {
    if (customer) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:customer];
         NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:kKey_Customer];
        [defaults synchronize];
    }
}

+ (Customer*)getCurrentCustomer {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kKey_Customer];
    Customer *customer = [NSKeyedUnarchiver unarchiveObjectWithData:data];

   return  customer;
}

+ (NSString*)getNewDeviceToken {
    return [SSKeychain passwordForService:kKEY_NEW_DEVICE_TOKEN account:kKEY_ACCOUNT];
}

+ (void)saveNewDeviceToken:(NSString*)deviceToken {
    [SSKeychain setPassword:deviceToken forService:kKEY_NEW_DEVICE_TOKEN account:kKEY_ACCOUNT];
   
    
}

+ (NSString*)getOldDeviceToken {
    return [SSKeychain passwordForService:kKEY_OLD_DEVICE_TOKEN account:kKEY_ACCOUNT];
}

+ (void)saveOldDeviceToken:(NSString*)deviceToken {
    
    
    NSString *savedDeviceToken = [SSKeychain passwordForService:kKEY_OLD_DEVICE_TOKEN account:kKEY_ACCOUNT];
    
    if(savedDeviceToken) {
        
        if ([savedDeviceToken isEqualToString:deviceToken]) {
            NSLog(@"Same Token Already Exists in keychain");
            
        } else {
            NSLog(@"Token does not match. Should update keychain and server");
            [SSKeychain setPassword:deviceToken forService:kKEY_OLD_DEVICE_TOKEN account:kKEY_ACCOUNT];
            [self saveNewDeviceToken:deviceToken];
        }
        
    } else {
        NSLog(@"Token does not exists. Saving for First time");
        [SSKeychain setPassword:deviceToken forService:kKEY_OLD_DEVICE_TOKEN account:kKEY_ACCOUNT];
        [self saveNewDeviceToken:deviceToken];
        
    }
}

+ (BOOL)getRemeberMe {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL ret = [defaults boolForKey:kKEY_REMEBER_ME];
    return ret;
}
+ (void)setRememberMe:(BOOL)value {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:kKEY_REMEBER_ME];
    [defaults synchronize];
}

+ (void)setMerchantEmail:(NSString*)email password:(NSString*)password {
    [SSKeychain setPassword:email forService:kKEY_MERCHANT_EMAIL account:kKEY_ACCOUNT];
    [SSKeychain setPassword:password forService:kKEY_MERCHANT_PASSWORD account:kKEY_ACCOUNT];
}

+ (NSString*)getMerchantEmail {
    return [SSKeychain passwordForService:kKEY_MERCHANT_EMAIL account:kKEY_ACCOUNT];
}

+ (NSString*)getMerchantPassword {
    return [SSKeychain passwordForService:kKEY_MERCHANT_PASSWORD account:kKEY_ACCOUNT];
}


#pragma mark - Base64 String to Image
+(UIImage *)dataFromBase64EncodedString:(NSString *)string64{
    if (string64.length > 0) {
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:string64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
        //initiate image from data
        
        UIImage *captcha_image = [[UIImage alloc] initWithData:data];
        
        return captcha_image;
    }
    return nil;
}
+ (NSString *)base64StringForImage:(UIImage*)image {
    if (image) {
        return [UIImageJPEGRepresentation(image, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }
    return nil;
}


#pragma mark -Login ID 
+ (void) storeLoginID:(NSString*)userID {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:userID forKey:kLoginID];
    [defaults synchronize];
}

+ (NSString*) loadLoginID {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLoginID];
}
+ (void) storeUserType:(BOOL) isBusiness {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:isBusiness forKey:kUserType];
    [defaults synchronize];
}

+ (BOOL) isBusiness {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kUserType];
}

+ (void) storeUsername:(NSString*)userName {
    if (userName == nil || [userName isKindOfClass:[NSNull class]])
        return;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:kUserName];
    [defaults synchronize];
}

+ (NSString*) loadUsername {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kUserName];
}

//+ (void) storeUserImage:(UIImage*) image
//{
//    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//    if (image == nil) {
//        [defaults removeObjectForKey:kUserImage];
//    }
//    else {
//        [defaults setObject:UIImagePNGRepresentation(image) forKey:kUserImage];
//    }
//    [defaults synchronize];
//}
//+ (UIImage*) loadUserImage
//{
//    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//    NSData* imageData = [defaults objectForKey:kUserImage];
//    if (imageData == nil) {
//        return nil;
//    }
//    return [UIImage imageWithData:imageData];
//}
+ (void) storeUserImage:(NSString*) imageURL
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (imageURL == nil || imageURL.length < 1) {
        [defaults removeObjectForKey:kUserImage];
    }
    else {
        [defaults setObject:imageURL forKey:kUserImage];
    }
    [defaults synchronize];
}
+ (NSString*) loadUserImage
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* imageUrl = [defaults objectForKey:kUserImage];
    if (imageUrl == nil || imageUrl.length < 1) {
        return nil;
    }
    return imageUrl;
}



+ (NSString*) getLeftTime:(NSString* ) strEndTime
{
    //  "1900-01-01T00:00:00",
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    
    NSDate *endDate = [f dateFromString:strEndTime];
    
    NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:[NSDate date]];
    
    int SECONDS = 60;
    int SECONDS_IN_HOUR = 60*SECONDS;
//    int SECONDS_IN_DAY = 24*SECONDS_IN_HOUR;
    
//    int days = distanceBetweenDates / SECONDS_IN_DAY;
//    int hours = ((int)distanceBetweenDates % SECONDS_IN_DAY) / SECONDS_IN_HOUR;
    int hours = (int)distanceBetweenDates / SECONDS_IN_HOUR;
    int minutes = ((int)distanceBetweenDates % SECONDS_IN_HOUR) / SECONDS;
    int sec = ((int)distanceBetweenDates % SECONDS_IN_HOUR) % SECONDS;
    
    NSString *result = @"";
//    if (days > 0) {
//        result = [result stringByAppendingString:[NSString stringWithFormat:@"%d days", days]];
//    }
//    if (hours > 0) {
//        result = [result stringByAppendingString:[NSString stringWithFormat:@" %d hours", hours]];
//    }
//    if (minutes > 0) {
//        result = [result stringByAppendingString:[NSString stringWithFormat:@" %d minutes left", minutes]];
//    }
    if (hours <= 0 && minutes <= 0 && sec <=0) {
        return @"Expired";
    }
    
    result = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, sec];
    
    return result;
}

@end
