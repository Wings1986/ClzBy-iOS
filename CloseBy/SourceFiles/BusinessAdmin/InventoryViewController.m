//
//  InventoryViewController.m
//  CloseBy
//
//  Created by iGold on 3/11/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "InventoryViewController.h"

//#import "InventoryCell.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "DealCollectionViewCell.h"


#import <Haneke.h>
#import "URBAlertView.h"


#import "MerchantAddProductViewController.h"
#import "ProductSpecialVC.h"
#import "ProductTimeVC.h"
#import "MapViewController.h"



#define TAG_INVENTORY_ENABLE    1000
#define TAG_INVENTORY_EDIT      2000
#define TAG_INVENTORY_DELETE    3000
#define TAG_INVENTORY_SETTING   4000
#define  TAG_BTN_MAP            5000

#define CELL_WIDTH  160.0f


@interface InventoryViewController()<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDataSource>
{
    
    IBOutlet UITextField *mSearchField;
    IBOutlet UICollectionView *mCollectionView;
    
    NSMutableArray * arrayInventory;
    NSMutableArray* dealDataSource;
    
    NSMutableDictionary * heightDeal;
}
@end


@implementation InventoryViewController

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
    
    self.title = @"Merchant Inventory";
    
    [self configureNavigationBar];
    
    mCollectionView.delegate = self;
    mCollectionView.dataSource = self;
    
    CHTCollectionViewWaterfallLayout * customLayout = (CHTCollectionViewWaterfallLayout*) mCollectionView.collectionViewLayout;
    customLayout.minimumColumnSpacing = 2.0;
    customLayout.minimumInteritemSpacing = 2.0f;
    customLayout.columnCount = 2;
    
    // timer
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(handleTimer)
                                   userInfo:nil
                                    repeats:YES];


    heightDeal = [[NSMutableDictionary alloc] init];
}

- (void) handleTimer
{
    if (dealDataSource == nil) {
        return;
    }
    
    int index = 0;
    for (NSDictionary* deal in dealDataSource) {
        
        if ((![deal[@"CurrentState"] isKindOfClass:[NSNull class]] && [deal[@"CurrentState"] intValue])
            && (![deal[@"DecayingSpecial"] isKindOfClass:[NSNull class]] && [deal[@"DecayingSpecial"] boolValue])) {
            
            DealCollectionViewCell* cell = (DealCollectionViewCell*)[mCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            cell.lbDecayDuration.text = [GlobalAPI getLeftTime:deal[@"DecayEndTime"]];
        }
        
        index ++;
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchProductList];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"gotoAddproduct"]) {
        
        if (sender == nil) { // add product
            
        }
        else {
            MerchantAddProductViewController * vc = segue.destinationViewController;
            vc.productData = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*) sender];
        }
    }
    
    if ([segue.identifier isEqualToString:@"gototimedecay"]) {

        ProductTimeVC * vc = segue.destinationViewController;
        vc.producteData = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*) sender];
    }

    if ([segue.identifier isEqualToString:@"gotospecial"]) {
        
        ProductSpecialVC * vc = segue.destinationViewController;
        vc.producteData = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*) sender];
    }

}

- (void)configureNavigationBar {
    
    UIButton * rightBarbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightBarbutton setAutoresizingMask:UIViewAutoresizingNone];
    [rightBarbutton setImage:[UIImage imageNamed:@"button_add.png"] forState:UIControlStateNormal];
    [rightBarbutton addTarget:self action:@selector(addProduct) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarbutton];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void) changeProductEnable:(UISwitch*) sender {
    int tag = (int)sender.tag - TAG_INVENTORY_ENABLE;
    
    NSMutableDictionary* product = [dealDataSource[tag] mutableCopy];
    
    int nOldStatus = [product[@"CurrentState"] intValue];
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/EnableDisableDeal.aspx?guid=%@&UserID=%@&ProductID=%@&State=%d",
                             kServerURL, kGUID,
                             [GlobalAPI loadLoginID],
                             product[@"ID"],
                             nOldStatus == 0 ? 1 : 0 ]
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

              NSLog(@"json data = %@", responseJson);

              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {

                  
                  NSDictionary * data = responseJson[@"Data"];
                  NSInteger indexOfAll = [arrayInventory indexOfObject:product];
                  
                  [dealDataSource replaceObjectAtIndex:tag withObject:data];
                  
                  if (indexOfAll > 0 && indexOfAll < arrayInventory.count)
                      [arrayInventory replaceObjectAtIndex:indexOfAll withObject:data];
                  
                   [mCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];
                  
//                  arrayInventory = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
//                  dealDataSource = [arrayInventory mutableCopy];
//                  
//                  [self searchFilter:searchField.text];
                  
//                  [mCollectionView reloadData];
                  
                  
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Success"
                                                                        message:responseJson[@"Message"]
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                  [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                      [alertView hideWithCompletionBlock:^{
                      }];
                  }];
                  [alertView show];
              }
              else {
                  [mCollectionView reloadData];
                  
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
- (void) addProduct {
    [self performSegueWithIdentifier:@"gotoAddproduct" sender:nil];
}

- (void) onClickEdit:(UIButton*) sender
{
    int tag = (int) sender.tag - TAG_INVENTORY_EDIT;
    
    [self performSegueWithIdentifier:@"gotoAddproduct" sender:dealDataSource[tag]];
}
- (void) onClickDelete:(UIButton*) sender
{
    int tag = (int) sender.tag - TAG_INVENTORY_DELETE;
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"NOTE"
                                                          message:@"Are you sure you want to delete this product?"
                                                cancelButtonTitle:@"YES"
                                                otherButtonTitles:@"NO", nil];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView hideWithCompletionBlock:^{
            // stub
            if (buttonIndex == 0) { // yes
                dispatch_async(dispatch_get_main_queue(),^{
                    
                    [CB_AlertView showAlertOnView:self.view];
                    
                    NSString *requestUrl = [[NSString stringWithFormat:@"%@/DeleteProduct.aspx?guid=%@&UserID=%@&ProductID=%@", kServerURL, kGUID,
                                             [GlobalAPI loadLoginID], dealDataSource[tag][@"ID"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    NSLog(@"request = %@", requestUrl);
                    
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    [manager POST:requestUrl
                       parameters:nil
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              
                              [CB_AlertView hideAlert];
                              
                              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                              NSDictionary *responseJson = [responseString JSONValue];
                              
                              NSLog(@"response = %@", responseString);
                              
                              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                                  
                                  NSInteger indexOfAll = [arrayInventory indexOfObject:dealDataSource[tag]];

                                  [dealDataSource removeObjectAtIndex:tag];
                          
                                  if (indexOfAll >= 0 && indexOfAll < arrayInventory.count) {
                                      [arrayInventory removeObjectAtIndex:indexOfAll];
                                  }
                                  
                                  
//                                  arrayInventory = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
//                                  [arrayInventory removeObjectAtIndex:tag];
                                  
                                  [mCollectionView reloadData];
                              }
                              
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [CB_AlertView hideAlert];
                          }];
                    

                });
            }
        }];
    }];
    [alertView show];
}

- (void) onClickSetting:(UIButton*) sender
{
    int tag = (int) sender.tag - TAG_INVENTORY_SETTING;
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@""
                                                          message:@"Select Special Settings"];
    [alertView addButtonWithTitle:@"Standard Deal"];
    [alertView addButtonWithTitle:@"Time Based Deal"];
    [alertView addButtonWithTitle:@"Cancel"];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex == 0) { // standard
                dispatch_async(dispatch_get_main_queue(),^{
                    
                    [self performSegueWithIdentifier:@"gotospecial" sender:dealDataSource[tag]];
                    
                });
            }
            if (buttonIndex == 1) { // Decaying
                dispatch_async(dispatch_get_main_queue(),^{
                    
                    [self performSegueWithIdentifier:@"gototimedecay" sender:dealDataSource[tag]];
                    
                });
            }
        }];
    }];
    [alertView show];
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

- (void)fetchProductList {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetAllBusinessProductsAdmin.aspx?guid=%@&UserID=%@", kServerURL, kGUID, [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request = %@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];

              NSLog(@"responseJson = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  arrayInventory = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                  dealDataSource = [arrayInventory mutableCopy];

                  [mCollectionView reloadData];
                  
                  @try {
                      [mCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
                  }
                  @catch (NSException *exception) {
                  }
                  @finally {
                  }
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
/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrayInventory == nil) {
        return 0;
    }
    return arrayInventory.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = arrayInventory[indexPath.row];
    
    int widthThumb = [dic[@"ThumbWidth"] isKindOfClass:[NSNull class]] ? 1 : [dic[@"ThumbWidth"] intValue];
    int heightThumb = [dic[@"ThumbHeight"] isKindOfClass:[NSNull class]] ? 1 : [dic[@"ThumbHeight"] intValue];
    
    float imageHeight = heightThumb * CELL_WIDTH / widthThumb;

    float height = 8 + imageHeight + 146 + 6;
    
    if ([dic[@"DecayingSpecial"] intValue] == 1 || [dic[@"StandardSpecial"] intValue] == 1) {
        height += 43;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InventoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InventoryCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary * product = arrayInventory[indexPath.row];

    NSLog(@"product = %@", product);
    
    
    cell.ivProductPicture.image = nil;
    @try {

        NSString * url = [product[@"ThumbImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivProductPicture hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    cell.lbProductName.text = product[@"ProductName"];
    cell.lbProductDescription.text = product[@"ProductDescription"];
    cell.lbProductCategory.text = product[@"CategoryNames"];
    
    cell.lbOriginPrice.hidden = NO;
    cell.lbOriginPrice.text = [NSString stringWithFormat:@"$%d", [product[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? 0 : [product[@"OrigionalPrice"] intValue]];

    cell.swEnable.on = [product[@"CurrentState"] intValue];
    cell.swEnable.tag = TAG_INVENTORY_ENABLE + indexPath.row;
    [cell.swEnable addTarget:self action:@selector(changeProductEnable:) forControlEvents:UIControlEventValueChanged];

    // standard & decay
    if ([product[@"DecayingSpecial"] intValue] == 1 || [product[@"StandardSpecial"] intValue] == 1) {
        cell.constraintDecayViewHeight.constant = 43;

        cell.lbDiscountTagLine.text = [product[@"DiscountedTagLing"] isKindOfClass:[NSNull class]] ? @"null" : product[@"DiscountedTagLing"];
        cell.lbRemainQuality.text = [NSString stringWithFormat:@"%d Left!", [product[@"QuantityRemaining"] isKindOfClass:[NSNull class]] ? 0 : [product[@"QuantityRemaining"] intValue]];
    }
    
    if ([product[@"DecayingSpecial"] intValue] == 1) { // decay
        cell.lbOriginPrice.hidden = YES;
        
        cell.subDecayView.hidden = NO;
        cell.lbDecayOriginPrice.text = [NSString stringWithFormat:@"$%d", [product[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? 0 : [product[@"OrigionalPrice"] intValue]];
        cell.lbDecayingSpecialPrice.text = [NSString stringWithFormat:@"$%d", [product[@"SpecialPrice"] isKindOfClass:[NSNull class]] ? 0 : [product[@"SpecialPrice"] intValue]];
        
        cell.subDecayTimeView.hidden = NO;
    }
    else {
        cell.lbOriginPrice.hidden = NO;
        cell.subDecayView.hidden = YES;
        cell.subDecayTimeView.hidden = YES;
    }
    
    
    cell.btnEdit.tag = TAG_INVENTORY_EDIT + indexPath.row;
    [cell.btnEdit addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];

    cell.btnDelete.tag = TAG_INVENTORY_DELETE + indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(onClickDelete:) forControlEvents:UIControlEventTouchUpInside];

    cell.btnSetting.tag = TAG_INVENTORY_SETTING + indexPath.row;
    [cell.btnSetting addTarget:self action:@selector(onClickSetting:) forControlEvents:UIControlEventTouchUpInside];
    
     return cell;
}
 */

- (float) heightForAllText:(NSIndexPath*) indexPath {
    
    NSString * key = [NSString stringWithFormat:@"%d", indexPath.item];
    
    NSNumber * num = heightDeal[key];
    if (num != nil) {
        return [num floatValue];
    }
    
    float height = 0;
    float allheight = 0;
    NSDictionary * deal = dealDataSource[indexPath.item];
    
    NSString *string = deal[@"DiscountedTagLing"];
    
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
    
    string = deal[@"CategoryNames"];
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
//    imageHeight = imageHeight < 90 ? 90 : imageHeight;
    
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
    
    
    NSDictionary * deal = dealDataSource[indexPath.item];
    
    
    cell.layer.cornerRadius = 2;
    cell.clipsToBounds = YES;
    cell.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f].CGColor;
    cell.layer.borderWidth = 1;
    
    
//    cell.ivBusinessLogo.image = nil;
//    cell.ivBusinessLogo.layer.cornerRadius = cell.ivBusinessLogo.frame.size.width/2;
//    cell.ivBusinessLogo.layer.borderColor = [UIColor grayColor].CGColor;
//    cell.ivBusinessLogo.layer.borderWidth = 2;
//    cell.ivBusinessLogo.clipsToBounds = YES;
//    
//    @try {
//        NSString * url = [deal[@"SmallImageLogo"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        [cell.ivBusinessLogo hnk_setImageFromURL:[NSURL URLWithString:url]];
//    }
//    @catch (NSException *exception) {
//    }
//    @finally {
//    }
//    
//    cell.lbBusinessName.text = ([deal[@"BusinessName"] isKindOfClass:[NSNull class]]) ? @"" : deal[@"BusinessName"];
    
    cell.ivPhoto.contentMode = UIViewContentModeScaleToFill;
    cell.ivPhoto.image = nil;
    @try {
        NSString * url = [deal[@"ThumbImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivPhoto hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    cell.lbLikes.hidden = NO;
    cell.btnLike.hidden = NO;
    
    cell.lbLikes.text = [deal[@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%d", [deal[@"NumberOfLikes"] intValue]] ;
    
    if (![deal[@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [deal[@"CurrentUserHasLiked"] intValue] == 1) {
        cell.btnLike.selected = YES;
    }
    else {
        cell.btnLike.selected = NO;
    }
    
    
    cell.lbOriginPrice.hidden = NO;
    cell.lbOriginPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"OrigionalPrice"] stringValue]];
    
    if (![deal[@"DecayingSpecial"] isKindOfClass:[NSNull class]] && [deal[@"DecayingSpecial"] boolValue]) {
        // decaying
        cell.lbOriginPrice.hidden = YES;
        
        cell.subDecayView.hidden = NO;
        cell.lbDecayOriginPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"OrigionalPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"OrigionalPrice"] stringValue]];
        cell.lbDecayingSpecialPrice.text = [NSString stringWithFormat:@"$%@", [deal[@"SpecialPrice"] isKindOfClass:[NSNull class]] ? @"0" : [deal[@"SpecialPrice"] stringValue]];
        
        if (![deal[@"CurrentState"] isKindOfClass:[NSNull class]] && [deal[@"CurrentState"] intValue]) {
            cell.subDecayTimeView.hidden = NO;
            cell.lbDecayDuration.text = [GlobalAPI getLeftTime:deal[@"DecayEndTime"]];
        } else {
            cell.subDecayTimeView.hidden = YES;
        }
    }
    else {
        cell.lbOriginPrice.hidden = NO;
        cell.subDecayView.hidden = YES;
        cell.subDecayTimeView.hidden = YES;
    }
    
    
    
    NSString * key = [NSString stringWithFormat:@"%lu", (long)indexPath.item];
    cell.constraintAllTextHeight.constant = [heightDeal[key] floatValue];
    
    cell.lbTagLine.text = deal[@"DiscountedTagLing"];
    cell.constraintTaglineHeight.constant = [heightDeal[[NSString stringWithFormat:@"tag_%@", key]] floatValue];
    
    cell.lbDealName.text = deal[@"ProductName"];
    cell.constraintNameHeight.constant = [heightDeal[[NSString stringWithFormat:@"name_%@", key]] floatValue];
    
    cell.lbDealDescription.text = deal[@"ProductDescription"];
    cell.constraintDescriptionHeight.constant = [heightDeal[[NSString stringWithFormat:@"description_%@", key]] floatValue];
    
    cell.lbDealSubCategory.text = deal[@"CategoryNames"];
    cell.constraintSubHeight.constant = [heightDeal[[NSString stringWithFormat:@"sub_%@", key]] floatValue];
    
    
    
    [cell.swEnable setOnTintColor: APP_COLOR];
    cell.swEnable.on = [deal[@"CurrentState"] intValue];
//    [cell.swEnable setOn: [deal[@"CurrentState"] intValue]
//                      animated: NO];
    cell.swEnable.tag = TAG_INVENTORY_ENABLE + indexPath.row;
    [cell.swEnable addTarget:self action:@selector(changeProductEnable:) forControlEvents:UIControlEventValueChanged];
    
    cell.btnEdit.tag = TAG_INVENTORY_EDIT + indexPath.row;
    [cell.btnEdit addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnDelete.tag = TAG_INVENTORY_DELETE + indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(onClickDelete:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnSetting.tag = TAG_INVENTORY_SETTING + indexPath.row;
    [cell.btnSetting addTarget:self action:@selector(onClickSetting:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnMap addTarget:self action:@selector(onClickMap:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnMap.tag = TAG_BTN_MAP + indexPath.item;
    
    return cell;
}

#pragma mark UITextField Delegate
- (BOOL) textFieldShouldClear:(UITextField *)textField{
    [textField resignFirstResponder];
    
    dealDataSource = [arrayInventory mutableCopy];
    [mCollectionView reloadData];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* change = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (arrayInventory == nil) {
        return YES;
    }
    
    [self searchFilter:change];
    
    [mCollectionView reloadData];
    
    return YES;
}
- (void) searchFilter:(NSString*) change
{
    dealDataSource = [[NSMutableArray alloc] init];
    
    if (change.length == 0) {
        dealDataSource = [arrayInventory mutableCopy];
    }
    else {
        for (NSDictionary * dic in arrayInventory) {
            NSString * productName = dic[@"ProductName"];
            NSString * businessName = dic[@"ProductDescription"];
            NSString * categories = dic[@"CategoryNames"];
            NSString * tagLine = dic[@"DiscountedTagLing"];
            
            if ((productName != nil && ![productName isKindOfClass:[NSNull class]] && [productName.uppercaseString containsString:change.uppercaseString])
                || (businessName != nil && ![businessName isKindOfClass:[NSNull class]] && [businessName.uppercaseString containsString:change.uppercaseString])
                || (categories != nil && ![categories isKindOfClass:[NSNull class]] && [categories.uppercaseString containsString:change.uppercaseString])
                || (tagLine != nil && ![tagLine isKindOfClass:[NSNull class]] && [tagLine.uppercaseString containsString:change.uppercaseString])) {
                
                [dealDataSource addObject:dic];
            }
        }
    }

}
@end
