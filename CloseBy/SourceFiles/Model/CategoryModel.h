//
//  CategoryModel.h
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryModel : NSObject

@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *categoryName;
@property (readwrite, assign) BOOL isSelected;

+(id)initWithJsonElement:(NSDictionary *)element;

@end
