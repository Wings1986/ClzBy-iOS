//
//  CategoryModel.m
//  CloseBy
//
//  Created by arian on 12/18/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "CategoryModel.h"

@implementation CategoryModel

+(id)initWithJsonElement:(NSDictionary *)element {
    CategoryModel *exploreData = [[CategoryModel alloc] init];
    exploreData.categoryId = [element objectForKey:@"ID"];
    exploreData.categoryName = [element objectForKey:@"CategoryName"];
    NSString *selected = [element objectForKey:@"selected"];
    if (selected) {
        // Key Exists
        if ([selected isEqualToString:@"true"]) {
            exploreData.isSelected = YES;
        }
    }
    
    return exploreData;
}

@end
