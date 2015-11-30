//
//  NotifyFlashMessage.h
//  CloseBy
//
//  Created by iGold on 3/11/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BaseViewController.h"


@protocol NotifyFlashMessageDelegate <NSObject>

- (void) gotoBackward:(NSUInteger)page;
- (void) gotoForward:(NSUInteger)page;
- (void) takeMe:(NSUInteger)page;
@end


@interface NotifyFlashMessage : UIViewController

@property (nonatomic, strong) NSString* beaconUUID;
@property (nonatomic, strong) NSString* beaconMajor;
@property (nonatomic, strong) NSString* beaconMinor;

@property (nonatomic, strong) NSDictionary* responseData;

@property (nonatomic, assign) BOOL bMultiData;

@property NSUInteger pageIndex;
@property NSUInteger pageTotal;
@property (nonatomic, strong) id<NotifyFlashMessageDelegate> delegate;

@end
