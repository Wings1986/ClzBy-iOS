//
//  AddFlashMessageViewController.h
//  CloseBy
//
//  Created by iGold on 3/11/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BaseViewController.h"

@interface AddFlashMessageViewController : BaseViewController

@property (nonatomic, strong) NSString * beaconUUID;
@property (nonatomic, strong) NSString * beaconMajor;
@property (nonatomic, strong) NSString * beaconMinor;


@property (nonatomic, strong) NSDictionary * flashData;
@property (nonatomic, assign) BOOL m_bModalView;

@end
