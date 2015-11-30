//
//  SearchModel.m
//  CloseBy
//
//  Created by Arslan Raza on 06/02/2015.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "SearchModel.h"

@implementation SearchModel

+ (id)newSearchModelWithQuery:(NSString*)q type:(NSInteger)t {
    SearchModel *model = [[SearchModel alloc] init];
    model.query = q;
    model.type = t;
    
    return model;
}

@end
