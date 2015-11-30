//
//  DealListViewController.m
//  CloseBy
//
//  Created by iGold on 4/7/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "DealListViewController.h"

//#import "PintCollectionViewLayout.h"
#import "CHTCollectionViewWaterfallLayout.h"

#import "DealCollectionViewCell.h"

#import <Haneke.h>
#import "URBAlertView.h"

#import "ProfileViewController.h"
#import "MapViewController.h"
#import "InterestViewController.h"
#import "AppDelegate.h"

#define CELL_WIDTH  160.0f


#define  TAG_BTN_LIKE   1000
#define  TAG_BTN_MAP    2000
#define  TAG_VIEW_CONTENT 3000

typedef enum {
        BEACON = 0,
        GPS
}DETECTMODE;

@interface DealListViewController()<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDataSource, InterestViewControllerDelegate>
{
    IBOutlet UICollectionView *mCollectionView;
    
    
    NSMutableArray* dealAll;
    NSMutableArray* dealDataSource;

    NSInteger mCount;
    DETECTMODE mFlag;
    
    NSTimer * mTimer;
    
    int     m_limit;
    int     m_offset;
    
    NSMutableDictionary * heightDeal;
    
    CLBeacon * currentBeacon;
    
    BOOL bAPICalling;
    
}
@property (nonatomic, strong) NSString * selectedCategory;
@property (nonatomic, assign) BOOL _loading;

@end


@implementation DealListViewController

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Deals CloseBy";
    
    [self configureNavigationBar];
    
    
    mCollectionView.delegate = self;
    mCollectionView.dataSource = self;

    CHTCollectionViewWaterfallLayout * customLayout = (CHTCollectionViewWaterfallLayout*) mCollectionView.collectionViewLayout;
    customLayout.minimumColumnSpacing = 5.0;
    customLayout.minimumInteritemSpacing = 5.0f;
    customLayout.columnCount = 2;

    __weak DealListViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [mCollectionView addPullToRefreshWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startRefresh];
        }
        
    }];
    
    // setup infinite scrolling
    [mCollectionView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startMoreLoad];
        }
    }];
    
    m_offset = 0;
    m_limit = 10;
    
//    [self fetchDealList];

    mFlag = BEACON;
    
    // timer
    
    heightDeal = [[NSMutableDictionary alloc] init];
 
    currentBeacon = NULL;
    
//    [self startRefresh];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(handleTimer)
                                            userInfo:nil
                                             repeats:YES];
}
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (mTimer != nil) {
        [mTimer invalidate];
        mTimer = nil;
    }
    
}

- (void) handleTimer
{
    [self requestAPI:YES force:NO];
    
    if (dealDataSource == nil) {
        return;
    }
    
    int index = 0;
    for (NSDictionary* deal in dealDataSource) {
        
        if (![deal[@"DecayingSpecial"] isKindOfClass:[NSNull class]]
            && [deal[@"DecayingSpecial"] boolValue]) {
            
            DealCollectionViewCell* cell = (DealCollectionViewCell*)[mCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            cell.lbDecayDuration.text = [GlobalAPI getLeftTime:deal[@"DecayEndTime"]];
        }
        
        index ++;
    }
    
}

#pragma mark - Refresh & More Load
- (void)startRefresh {
    
    m_offset = 0;
    
    [self requestAPI:NO force:YES];
    
//    if (mFlag == BEACON) {
//        [self fetchDealList:BEACON autoRefresh:NO force:YES];
//    } else {
//        [self fetchDealList:GPS autoRefresh:NO force:YES];
//    }
}

- (void)startMoreLoad {

    if (m_offset < m_limit) {
        [self doneLoadingTableViewData];
        return;
    }

    [self requestAPI:NO force:YES];

//    if (mFlag == BEACON) {
//        [self fetchDealList:BEACON autoRefresh:NO force:YES];
//    } else {
//        [self fetchDealList:GPS autoRefresh:NO force:YES];
//    }
}
- (void) doneLoadingTableViewData
{
    [mCollectionView reloadData];
    
    [mCollectionView.pullToRefreshView stopAnimating];
    [mCollectionView.infiniteScrollingView stopAnimating];
    
    self._loading = NO;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"gotoprofile"]) {
        
        ProfileViewController * vc = segue.destinationViewController;
        vc.businessUserID = ((NSDictionary*)sender)[@"UserID"];
    }
    if ([segue.identifier isEqualToString:@"goto_interest"]) {
        
        InterestViewController * vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark Navigation
- (void)configureNavigationBar {
    
    UIButton * rightBarbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightBarbutton setAutoresizingMask:UIViewAutoresizingNone];
    [rightBarbutton setImage:[UIImage imageNamed:@"icon_category_filter.png"] forState:UIControlStateNormal];
    [rightBarbutton addTarget:self action:@selector(addCategory:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarbutton];
    self.navigationItem.rightBarButtonItem = buttonItem;
}
- (void) addCategory:(id) sender {
    
//    [self performSegueWithIdentifier:@"goto_interest" sender:self];
    
    InterestViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InterestViewController"];
    vc.delegate = self;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark GPS & Beacon
- (void) requestAPI:(BOOL) autoRefresh force:(BOOL) bForce
{
//    NSLog(@"selectedCategories = %@", _selectedCategory);
//    
//    if (self.selectedCategory != nil && self.selectedCategory.length > 0) {
//        return;
//    }
    
    DETECTMODE oldFlag = mFlag;
    
    AppDelegate * appDel =  (AppDelegate*) [UIApplication sharedApplication].delegate;
    BOOL isBeacon = [appDel isDetectedBeacon];
    if (isBeacon) {
        mFlag = BEACON;
        [self fetchDealList:BEACON autoRefresh:autoRefresh force:bForce];
    }
    else { // gps
        if (bForce) {
            [self fetchDealList:GPS autoRefresh:NO force:YES];
        }
        else {
            if (oldFlag == BEACON) {
                mCount = 0;
            }
            
            mFlag = GPS;
            
            if (mCount % 10 == 0) {
                [self fetchDealList:GPS autoRefresh:YES force:NO];
                mCount = 0;
            }
            
            mCount ++;
        }
    }
}


#pragma mark  -

- (void)fetchDealList:(DETECTMODE) flag autoRefresh:(BOOL) bAuto force:(BOOL) force{
    
    int offset = bAuto ? 0 : m_offset;
    int limit = m_limit;
    
    NSString *requestUrl;
    
    if (flag == BEACON) {
        AppDelegate * appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        
        if ([appDelegate isChangeBeacon:currentBeacon] || force || (dealAll==nil && appDelegate.activeBeacon!=nil)) {
            currentBeacon = appDelegate.activeBeacon;
            
            requestUrl = [[NSString stringWithFormat:@"%@/ReturnsDealswithActiveBeaconID.aspx?guid=%@&UserID=%@&BeaconUUID=%@&Major=%d&Minor=%d&fromrow=%d&limit=%d",
                           kServerURL,
                           kGUID,
                           [GlobalAPI loadLoginID],
                           appDelegate.activeBeacon.proximityUUID.UUIDString,
                           [appDelegate.activeBeacon.major unsignedIntValue],
                           [appDelegate.activeBeacon.minor unsignedIntValue],
                           offset,
                           limit
                           ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        }
        else {
            return;
        }
        
    }
    else { // GPS
        requestUrl = [[NSString stringWithFormat:@"%@/ReturnDealsWithGPS.aspx?guid=%@&UserID=%@&lat=%f&long=%f&fromrow=%d&limit=%d",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID],
                       [MyLocation sharedInstance].getCurLatitude,
                       [MyLocation sharedInstance].getCurLongitude,
                       offset,
                       limit
                       ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    }
    
    if (!bAuto) {
        [CB_AlertView showAlertOnView:self.view];
    }

    if (bAPICalling) {
        return;
    }
    
    bAPICalling = YES;
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              bAPICalling = NO;
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];
              
//              NSLog(@"json data = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {

                  NSMutableArray * result = responseJson[@"Data"][@"Products"];

                  if (result == nil || result.count < 1) {
                      NSString * msg = @"";
                      if (m_offset != 0) {
                          msg = @"No More Deals";
                          URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"NOTE"
                                                                                message:msg
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil, nil];
                          [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                              [alertView hideWithCompletionBlock:^{
                              }];
                          }];
                          [alertView show];
                      }

                  }
                  
                  
                  if (force) {
                      
                      if (result != nil && result.count > 0) {
                          if (dealAll == nil || m_offset == 0) {
                              dealAll = [[NSMutableArray alloc] initWithArray:result];
                          }
                          else {
                              [dealAll addObjectsFromArray:result];
                          }
                          
                          dealDataSource = [dealAll mutableCopy];
                          
                          m_offset += m_limit;
                          
                      }
                      
                      [self searchFilter:searchField.text];
                      
                      [self doneLoadingTableViewData];
                      
                  }
                  else if (bAuto) {
                      if (result != nil && result.count > 0) {
                          NSMutableDictionary * lastDeal = dealAll != nil ? [[dealAll firstObject] mutableCopy] : nil;
                          if (lastDeal != nil) {
                              [lastDeal removeObjectForKey:@"impressions"];
                              [lastDeal removeObjectForKey:@"clicks"];
                              [lastDeal removeObjectForKey:@"checkins"];
                          }
                          
                          
                          NSMutableDictionary * newDeal = [[result firstObject] mutableCopy];
                          if (newDeal != nil) {
                              [newDeal removeObjectForKey:@"impressions"];
                              [newDeal removeObjectForKey:@"clicks"];
                              [newDeal removeObjectForKey:@"checkins"];
                          }
                          
                          if (![lastDeal isEqualToDictionary:newDeal]) {
                              
                              dealAll = [[NSMutableArray alloc] initWithArray:result];
                              dealDataSource = [dealAll mutableCopy];
                              
                              [self searchFilter:searchField.text];
                              
                              [self doneLoadingTableViewData];
                              m_offset = 0;
                              m_offset += m_limit;
                          }
                          
                      }
                      
                  }
                  
                  
              }
              else {
//                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Fail"
//                                                                        message:responseJson[@"Message"]
//                                                              cancelButtonTitle:@"OK"
//                                                              otherButtonTitles:nil, nil];
//                  [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//                      [alertView hideWithCompletionBlock:^{
//                      }];
//                  }];
//                  [alertView show];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {

              bAPICalling = NO;
              
              [CB_AlertView hideAlert];
              
              if (!bAuto) {
                  [self doneLoadingTableViewData];
              }
              
          }];
}


#pragma mark UITextField Delegate
- (BOOL) textFieldShouldClear:(UITextField *)textField{
    [textField resignFirstResponder];
    
    dealDataSource = [dealAll mutableCopy];
    [mCollectionView reloadData];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* change = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (dealAll == nil) {
        return YES;
    }
    
    [self searchFilter:change];
    
    [mCollectionView reloadData];
    
    return YES;
}
- (void) searchFilter:(NSString*) change {
    dealDataSource = [[NSMutableArray alloc] init];
    
    if (change.length == 0) {
        dealDataSource = [dealAll mutableCopy];
    }
    else {
        for (NSDictionary * dic in dealAll) {
            NSString * productName = dic[@"ProductName"];
            NSString * businessName = dic[@"BusinessName"];
            NSString * categories = dic[@"DealSubCategories"];
            NSString * tagLine = dic[@"DiscountedTagLine"];
            NSString * description = dic[@"ProductDescription"];
            
            
            if ((productName != nil && ![productName isKindOfClass:[NSNull class]] && [productName.uppercaseString containsString:change.uppercaseString])
                || (businessName != nil && ![businessName isKindOfClass:[NSNull class]] && [businessName.uppercaseString containsString:change.uppercaseString])
                || (categories != nil && ![categories isKindOfClass:[NSNull class]] && [categories.uppercaseString containsString:change.uppercaseString])
                || (tagLine != nil && ![tagLine isKindOfClass:[NSNull class]] && [tagLine.uppercaseString containsString:change.uppercaseString])
                || (description != nil && ![description isKindOfClass:[NSNull class]] && [description.uppercaseString containsString:change.uppercaseString])) {
                
                [dealDataSource addObject:dic];
            }
        }
    }

}

- (IBAction)onClickSearchBtn:(id)sender {

}

- (void) onClickLike:(UIButton*) sender
{
    NSInteger tag = sender.tag - TAG_BTN_LIKE;
    
    NSMutableDictionary* deal = [dealDataSource[tag] mutableCopy];
    
//    if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
//
//        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"NOTE"
//                                                              message:@"This deal was already liked"
//                                                    cancelButtonTitle:@"OK"
//                                                    otherButtonTitles:nil, nil];
//        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//            [alertView hideWithCompletionBlock:^{
//                
//            }];
//        }];
//        [alertView show];
//        
//        return;
//    }
    
    
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/UserSaveDeal.aspx?guid=%@&UserID=%@&BusinessID=%@&DealID=%@",
                             kServerURL, kGUID, [GlobalAPI loadLoginID],
                             deal[@"BusinessID"],
                             deal[@"ID"]]
                            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  
                  NSInteger indexOfAll = [dealAll indexOfObject:deal];
                  
                  if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
                      deal[@"CurrentUserHasLiked"] = [NSNumber numberWithInt:0];
                      int likes = [deal[@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? 1 : [deal[@"NumberOfLikes"] intValue];
                      deal[@"NumberOfLikes"] = [NSNumber numberWithInt:likes - 1];
                  }
                  else {
                      deal[@"CurrentUserHasLiked"] = [NSNumber numberWithInt:1];
                      int likes = [deal[@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? 0 : [deal[@"NumberOfLikes"] intValue];
                      deal[@"NumberOfLikes"] = [NSNumber numberWithInt:likes + 1];
                  }
                  
                  [dealDataSource replaceObjectAtIndex:tag withObject:deal];
                  
                  if (indexOfAll > 0 && indexOfAll < dealAll.count) {
                      [dealAll replaceObjectAtIndex:indexOfAll withObject:deal];
                  }
                  
                  [mCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];

              }
              else {
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Fail"
                                                                        message:responseJson[@"Message"]
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                  [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                      [alertView hideWithCompletionBlock:^{
                      }];
                  }];
                  [alertView show];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [CB_AlertView hideAlert];
          }];

}
- (void) onClickMap:(UIButton*) sender
{
    int tag = (int) sender.tag - TAG_BTN_MAP;
    
    MapViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"MapViewController"];
    vc.selectedBusinessID = [dealDataSource[tag][@"BusinessID"] integerValue];
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
}
- (void) onTapCell:(UIGestureRecognizer* ) gesture
{
    NSInteger tag = gesture.view.tag - TAG_VIEW_CONTENT;
    
    [self performSegueWithIdentifier:@"gotoprofile" sender:dealDataSource[tag]];
}

//#pragma mark - UICollectionViewDelegateJSPintLayout
//
//- (CGFloat)columnWidthForCollectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
//{
//    return CELL_WIDTH;
//}
//
//- (NSUInteger)maximumNumberOfColumnsForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
//{
//    NSUInteger numColumns = 2;
//    
//    return numColumns;
//}
//
//- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath*)indexPath
//{
//    
//    int widthThumb = [dealDataSource[indexPath.item][@"ThumbWidth"] intValue];
//    int heightThumb = [dealDataSource[indexPath.item][@"ThumbHeight"] intValue];
//    
//    float height = heightThumb * CELL_WIDTH / widthThumb + 73;
//
//    return height;
//}


- (float) heightForAllText:(NSIndexPath*) indexPath {

    NSString * key = [NSString stringWithFormat:@"%d", indexPath.item];
    
    NSNumber * num = heightDeal[key];
    if (num != nil) {
        return [num floatValue];
    }
    
    float height = 0;
    float allheight = 0;
    NSDictionary * deal = dealDataSource[indexPath.item];

    NSString *string = deal[@"DiscountedTagLine"];
    
    UILabel * lbDeal = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    lbDeal.numberOfLines = 0;
    lbDeal.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:11.0];
    lbDeal.text = string;
    [lbDeal sizeToFit];
    height = lbDeal.frame.size.height;
    allheight += height;
    [heightDeal setValue:[NSNumber numberWithFloat:height] forKey:[NSString stringWithFormat:@"tag_%@", key]];
    
    string = deal[@"ProductName"];
    UILabel * lbName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    lbName.numberOfLines = 0;
    lbName.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:14.0];
    lbName.text = string;
    [lbName sizeToFit];
    height = lbName.frame.size.height;
    allheight += height;
    [heightDeal setValue:[NSNumber numberWithFloat:height] forKey:[NSString stringWithFormat:@"name_%@", key]];
    
    string = deal[@"ProductDescription"];
    UILabel * lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    lbDescription.numberOfLines = 0;
    lbDescription.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:11.0];
    lbDescription.text = string;
    [lbDescription sizeToFit];
    height = lbDescription.frame.size.height;
    allheight += height;
    [heightDeal setValue:[NSNumber numberWithFloat:height] forKey:[NSString stringWithFormat:@"description_%@", key]];
    
    string = deal[@"DealSubCategories"];
    UILabel * lbSub = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
    lbSub.numberOfLines = 0;
    lbSub.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:10.0];
    lbSub.text = string;
    [lbSub sizeToFit];
    height = lbSub.frame.size.height;
    allheight += height;
    [heightDeal setValue:[NSNumber numberWithFloat:height] forKey:[NSString stringWithFormat:@"sub_%@", key]];

    allheight += 8 + 6* 4;

    [heightDeal setValue:[NSNumber numberWithFloat:allheight] forKey:key];
    
    return allheight;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int widthThumb = [dealDataSource[indexPath.item][@"ThumbWidth"] isKindOfClass:[NSNull class]] ? 1 : [dealDataSource[indexPath.item][@"ThumbWidth"] intValue];
    int heightThumb = [dealDataSource[indexPath.item][@"ThumbHeight"] isKindOfClass:[NSNull class]] ? 1 : [dealDataSource[indexPath.item][@"ThumbHeight"] intValue];
    
    float imageHeight = heightThumb * CELL_WIDTH / widthThumb;

//    NSLog(@"row = %d, height = %f", indexPath.item, [self heightForAllText:indexPath]);
    
    float totalHeight = 5+ 40 + imageHeight + 30 + [self heightForAllText:indexPath] + 5;

    return CGSizeMake(CELL_WIDTH, totalHeight);
}

#pragma mark = UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (dealDataSource == nil) {
        return 0;
    }
    
    NSInteger count = [dealDataSource count];
    
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    DealCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DealCollectionViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
   
    [cell.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCell:)]];
    cell.contentView.tag = TAG_VIEW_CONTENT + indexPath.item;
    
    
    NSDictionary * deal = dealDataSource[indexPath.item];
    
//    NSLog(@"deal = %@", deal);
    
    cell.layer.cornerRadius = 2;
    cell.clipsToBounds = YES;
    cell.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f].CGColor;
    cell.layer.borderWidth = 1;

    
    
    
    cell.ivBusinessLogo.image = nil;
    cell.ivBusinessLogo.layer.cornerRadius = cell.ivBusinessLogo.frame.size.width/2;
    cell.ivBusinessLogo.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f].CGColor;
    cell.ivBusinessLogo.layer.borderWidth = 1;
    cell.ivBusinessLogo.clipsToBounds = YES;
    
    @try {
        NSString * url = [deal[@"SmallImageLogo"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivBusinessLogo hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    cell.lbBusinessName.text = ([deal[@"BusinessName"] isKindOfClass:[NSNull class]]) ? @"" : deal[@"BusinessName"];
    

    cell.lbLikes.hidden = NO;
    cell.btnLike.hidden = NO;
    
    cell.lbLikes.text = [deal[@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%d", [deal[@"NumberOfLikes"] intValue]] ;
    
    if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
        cell.btnLike.selected = YES;
    }
    else {
        cell.btnLike.selected = NO;
    }

//    if (![GlobalAPI isBusiness])
    {
        [cell.btnLike addTarget:self action:@selector(onClickLike:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnLike.tag = TAG_BTN_LIKE + indexPath.item;
    }

    
    
    cell.ivPhoto.image = nil;
    @try {
        //        cell.ivPicture.contentMode = UIViewContentModeScaleAspectFit;
        
        NSString * url = [deal[@"ThumbImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivPhoto hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }

    
    cell.lbOriginPrice.hidden = NO;
    cell.lbOriginPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? 0 : [deal[@"OrigionalPrice"] stringValue]];
    
    if (![deal[@"DecayingSpecial"] isKindOfClass:[NSNull class]]
        && [deal[@"DecayingSpecial"] boolValue]) {
        // decaying
        cell.lbOriginPrice.hidden = YES;
        
        cell.subDecayView.hidden = NO;
        cell.lbDecayOriginPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"OrigionalPrice"] stringValue]];
        cell.lbDecayingSpecialPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"SpecialPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"SpecialPrice"] stringValue]];
        
        cell.subDecayTimeView.hidden = NO;
        cell.lbDecayDuration.text = [GlobalAPI getLeftTime:deal[@"DecayEndTime"]];
    }
    else {
        cell.lbOriginPrice.hidden = NO;
        cell.subDecayView.hidden = YES;
        cell.subDecayTimeView.hidden = YES;
    }


    NSString * key = [NSString stringWithFormat:@"%lu", (long)indexPath.item];
    cell.constraintAllTextHeight.constant = [heightDeal[key] floatValue];
    
    cell.lbTagLine.text = deal[@"DiscountedTagLine"];
    cell.constraintTaglineHeight.constant = [heightDeal[[NSString stringWithFormat:@"tag_%@", key]] floatValue];
    
    cell.lbDealName.text = deal[@"ProductName"];
    cell.constraintNameHeight.constant = [heightDeal[[NSString stringWithFormat:@"name_%@", key]] floatValue];

    cell.lbDealDescription.text = deal[@"ProductDescription"];
    cell.constraintDescriptionHeight.constant = [heightDeal[[NSString stringWithFormat:@"description_%@", key]] floatValue];

    cell.lbDealSubCategory.text = deal[@"DealSubCategories"];
    cell.constraintSubHeight.constant = [heightDeal[[NSString stringWithFormat:@"sub_%@", key]] floatValue];

    
    [cell.btnMap addTarget:self action:@selector(onClickMap:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnMap.tag = TAG_BTN_MAP + indexPath.item;
    
    // discount time
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"gotoprofile" sender:dealDataSource[indexPath.item]];
}

#pragma mark Interest Delegate
- (void) chooseCategory:(NSString *)arrCategory
{
    _selectedCategory = arrCategory;
    NSLog(@"selectedCategories = %@", _selectedCategory);
    
    [self startRefresh];
}

@end
