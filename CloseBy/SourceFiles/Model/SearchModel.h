//
//  SearchModel.h
//  CloseBy
//
//  Created by Arslan Raza on 06/02/2015.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchModel : NSObject

@property (nonatomic, strong) NSString *query;
@property (readwrite, assign) NSInteger type;

+ (id)newSearchModelWithQuery:(NSString*)q type:(NSInteger)t;

@end
