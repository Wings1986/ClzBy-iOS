//
//  BeaconsViewController.m
//  CloseBy
//
//  Created by iGold on 3/5/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BeaconsViewController.h"

#import "AddBeaconViewController.h"
#import "AddFlashMessageViewController.h"

#import "AppDelegate.h"

#import "URBAlertView.h"
#import <Haneke.h>


#import "BeaconTypeCell1.h"
#import "BeaconTypeCell3.h"

#define TAG_BEACON_ENABLE   1000
#define TAG_BEACON_EDIT_MESSAGE   2000
#define TAG_BEACON_TEST     3000
#define TAG_BEACON_EDIT     4000


@interface BeaconsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView * mTableView;
    
    NSMutableArray * arrayBeacons;
    
}
@end

@implementation BeaconsViewController

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
    
    self.skipSearch = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self configureNavigationBar];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchBeaconList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"gotoAddBeacon"]) {
        
        if (sender == nil) { // add beacon
            
        }
        else {
            AddBeaconViewController * vc = segue.destinationViewController;
            vc.beaconData = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*) sender];
        }
    }
    
    if ([segue.identifier isEqualToString:@"gotoflashmessage"]) {
        
        AddFlashMessageViewController * vc = segue.destinationViewController;
        vc.beaconUUID = ((NSDictionary*) sender)[@"BeaconUUID"];
        vc.beaconMajor = ((NSDictionary*) sender)[@"Major"];
        vc.beaconMinor = ((NSDictionary*) sender)[@"Minor"];

    }
    
}

- (void) onClickEdit:(UIButton*) sender
{
    int tag = (int)sender.tag - TAG_BEACON_EDIT;
    NSDictionary* dic = arrayBeacons[tag];
    int beaconTypeID = [dic[@"BeaconTypeID"] intValue];

    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@""
                                                          message:@""
                                                cancelButtonTitle:@"Save"
                                                otherButtonTitles:@"Cancel", nil];
    [alertView createRadioButton:beaconTypeID];
    
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex == 0) { // OK
                dispatch_async(dispatch_get_main_queue(),^{
                    NSLog(@"selected = %d", [alertView getSelectedRadio]);
                    
                    int selectedTypeID = [alertView getSelectedRadio];
                    
                    if (selectedTypeID != beaconTypeID) {
                     
                        
                        [CB_AlertView showAlertOnView:self.view];
                        
                        NSString *requestUrl = [[NSString stringWithFormat:@"%@/UpdateBeaconType.aspx?guid=%@&userid=%@&BeaconUUID=%@&Major=%@&Minor=%@&BeaconTypeID=%d",
                                                 kServerURL,
                                                 kGUID,
                                                 [GlobalAPI loadLoginID],
                                                 dic[@"BeaconUUID"],
                                                 [NSString stringWithFormat:@"%@", dic[@"Major"]],
                                                 [NSString stringWithFormat:@"%@", dic[@"Minor"]],
                                                 selectedTypeID]
                                                stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        NSLog(@"request = %@", requestUrl);
                        
                        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                        
                        [manager GET:requestUrl
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 [CB_AlertView hideAlert];
                                 
                                 NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                 NSDictionary *responseJson = [responseString JSONValue];
                                 
                                 NSLog(@"response = %@", responseJson);
                                 
                                 if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                                     
                                     arrayBeacons = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                                     
                                     [mTableView reloadData];
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
                });
            }
            
        }];
    }];
    [alertView show];
    
}

- (void) changeBeaconEnable:(UISwitch*) sender {
    int tag = (int)sender.tag - TAG_BEACON_ENABLE;
    
    NSDictionary* beaconData = arrayBeacons[tag];
    
    BOOL enable = [beaconData[@"Enabled"] boolValue];
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/EnableDisableNotification.aspx?guid=%@&Userid=%@&beaconid=%@&Major=%@&Minor=%@&status=%d",
                             kServerURL, kGUID, [GlobalAPI loadLoginID], beaconData[@"BeaconUUID"],
                             beaconData[@"Major"],
                             beaconData[@"Minor"],
                             !enable]
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
                  
                  arrayBeacons[tag][@"Enabled"] = [NSNumber numberWithBool:!enable];
                  
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Success"
                                                                        message:responseJson[@"Message"]
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                  [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                      [alertView hideWithCompletionBlock:^{
                      }];
                  }];
                  [alertView show];
                  
//                  arrayBeacons = [[NSMutableArray alloc] initWithArray:responseJson];
//                  
//                  NSLog(@"json data = %@", arrayBeacons);
//                  
//                  [mTableView reloadData];
                  
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
- (void) onClickFlashMessage:(UIButton*) btn
{
    [self performSegueWithIdentifier:@"gotoflashmessage" sender:arrayBeacons[btn.tag - TAG_BEACON_EDIT_MESSAGE]];
}

- (void) onClickTest:(UIButton*) btn
{

    NSDictionary* dicBeacon = arrayBeacons[btn.tag - TAG_BEACON_TEST];
    if (![dicBeacon[@"Enabled"] boolValue]) {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"NOTE" message:@"This beacon was disable. You can not get any notification"];
        [alertView addButtonWithTitle:@"OK"];
        [alertView show];
        return;
    }
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    [appDelegate setupBeaconBusiness:dicBeacon];
    [appDelegate checkBeacon:dicBeacon]; //testing
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"TESTING"
                                                          message:@"Please lock your screen and walk far away from the Beacon (~40ft) then walk back to it"
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil, nil];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {

        [alertView hideWithCompletionBlock:^{
            // stub
            if (buttonIndex == 0) { // OK
                dispatch_async(dispatch_get_main_queue(),^{
                    
                });
            }
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationFlipHorizontal];
}

- (void)fetchBeaconList {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessBeacons.aspx?guid=%@&UserID=%@", kServerURL, kGUID, [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
                  arrayBeacons = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                  [mTableView reloadData];
              }
              else {
                  
                  NSString * urlString = responseJson[@"Url"];
                  URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"NOTE"
                                                                        message:responseJson[@"Message"]
                                                              cancelButtonTitle:@"YES"
                                                              otherButtonTitles:@"NO", nil];
                  [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                      
                      [alertView hideWithCompletionBlock:^{
                          // stub
                          if (buttonIndex == 0) { // OK
                              dispatch_async(dispatch_get_main_queue(),^{
                                  if (urlString != nil && urlString.length > 0) {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                                  }
                              });
                          }
                      }];
                  }];
                  [alertView showWithAnimation:URBAlertAnimationFlipHorizontal];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [CB_AlertView hideAlert];
          }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrayBeacons == nil) {
        return 0;
    }
    return arrayBeacons.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int beaconTypeID = [arrayBeacons[indexPath.row][@"BeaconTypeID"] intValue];

    if (beaconTypeID == 2) { // flash message
        return 392;
    }
    return 677.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dic = arrayBeacons[indexPath.row];
    
    int beaconTypeID = [dic[@"BeaconTypeID"] intValue];
    
    if (beaconTypeID == 1) { // business info
        BeaconTypeCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconTypeCell3"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.chBeaconEnable.on = [dic[@"Enabled"] boolValue];
        cell.chBeaconEnable.tag = TAG_BEACON_ENABLE + indexPath.row;
        [cell.chBeaconEnable addTarget:self action:@selector(changeBeaconEnable:) forControlEvents:UIControlEventValueChanged];
        
        cell.btnTest.tag = TAG_BEACON_TEST + indexPath.row;
        [cell.btnTest addTarget:self action:@selector(onClickTest:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btnEditType.tag = TAG_BEACON_EDIT + indexPath.row;
        [cell.btnEditType addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
        
        // beacon data
        NSString * businessLogo = dic[@"BeaconData"][@"BusinessLogoSmall"];
        if (businessLogo != nil && ![businessLogo isKindOfClass:[NSNull class]]) {
            NSString * url = [businessLogo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [cell.ivBusinessLogo hnk_setImageFromURL:[NSURL URLWithString:url]];
        }
        
        cell.lbBusinessName.text = dic[@"BeaconData"][@"BusinessName"];
        cell.lbBusinessContactNumber.text = dic[@"BeaconData"][@"BusinessContactNumber"];
        cell.lbBusinessBusinessAddress.text = dic[@"BeaconData"][@"BusinessAddress"];
        cell.lbMainCategoryName.text = dic[@"BeaconData"][@"MainCategoryName"] == nil ? @"null" : dic[@"BeaconData"][@"MainCategoryName"];
        
        [cell setBusinessName:dic[@"BeaconData"][@"BusinessName"] logo:dic[@"BeaconData"][@"BusinessLogoSmall"]];
        
//        cell.lbLikes.text = [dic[@"BeaconData"][@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%d", [dic[@"BeaconData"][@"NumberOfLikes"] intValue]] ;
//        
//        if (![dic[@"BeaconData"][@"CurrentUserHasLiked"] isKindOfClass:[NSNull class]] && [dic[@"BeaconData"][@"CurrentUserHasLiked"] isEqualToString:@"Yes"]) {
//            cell.ivLike.image = [UIImage imageNamed:@"like-button-tapped.png"];
//        }
//        else {
//            cell.ivLike.image = [UIImage imageNamed:@"like-button.png"];
//        }
        
        int count = 0;
        for (NSDictionary * openingHours in dic[@"BeaconData"][@"OpeningHours"]) {
            NSString * startTime = openingHours[@"StartTime"];
            NSString * endTime = openingHours[@"EndTime"];
            
            switch (count) {
                case 0:
                {
                    if ([startTime isEqualToString:@"00:00"]) {
                        cell.startTimeMon.text = @"Closed";
                        cell.endTimeMon.hidden = YES;
                    } else {
                        cell.startTimeMon.text = startTime;
                        cell.endTimeMon.text = endTime;
                    }
                    break;
                }
                case 1:
                {
                    if ([startTime isEqualToString:@"00:00"]) {
                        cell.startTimeTue.text = @"Closed";
                        cell.endTimeTue.hidden = YES;
                    } else {
                        cell.startTimeTue.text = startTime;
                        cell.endTimeTue.text = endTime;
                    }
                    break;
                }
                case 2:
                {
                    if ([startTime isEqualToString:@"00:00"]) {
                        cell.startTimeWed.text = @"Closed";
                        cell.endTimeWed.hidden = YES;
                    } else {
                        cell.startTimeWed.text = startTime;
                        cell.endTimeWed.text = endTime;
                    }
                    break;
                }
                case 3:
                {
                    if ([startTime isEqualToString:@"00:00"]) {
                        cell.startTimeThu.text = @"Closed";
                        cell.endTimeThu.hidden = YES;
                    } else {
                        cell.startTimeThu.text = startTime;
                        cell.endTimeThu.text = endTime;
                    }
                    break;
                }
                case 4:
                {
                    if ([startTime isEqualToString:@"00:00"]) {
                        cell.startTimeFri.text = @"Closed";
                        cell.endTimeFri.hidden = YES;
                    } else {
                        cell.startTimeFri.text = startTime;
                        cell.endTimeFri.text = endTime;
                    }
                    break;
                }
                case 5:
                {
                    if ([startTime isEqualToString:@"00:00"]) {
                        cell.startTimeSat.text = @"Closed";
                        cell.endTimeSat.hidden = YES;
                    } else {
                        cell.startTimeSat.text = startTime;
                        cell.endTimeSat.text = endTime;
                    }
                    break;
                }
                case 6:
                {
                    if ([startTime isEqualToString:@"00:00"]) {
                        cell.startTimeSun.text = @"Closed";
                        cell.endTimeSun.hidden = YES;
                    } else {
                        cell.startTimeSun.text = startTime;
                        cell.endTimeSun.text = endTime;
                    }
                    break;
                }
            }
            
            count ++;
        }
        
        // map
        [cell gotoMap:dic[@"BeaconData"]];
        
        // thumb
        [cell showDeals:dic[@"BeaconData"][@"BusinessDeals"]];

        return cell;
        
    }
    
    else { // flash message
        BeaconTypeCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconTypeCell1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.chBeaconEnable.on = [dic[@"Enabled"] boolValue];
        cell.chBeaconEnable.tag = TAG_BEACON_ENABLE + indexPath.row;
        [cell.chBeaconEnable addTarget:self action:@selector(changeBeaconEnable:) forControlEvents:UIControlEventValueChanged];
        
        cell.btnTest.tag = TAG_BEACON_TEST + indexPath.row;
        [cell.btnTest addTarget:self action:@selector(onClickTest:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btnEditType.tag = TAG_BEACON_EDIT + indexPath.row;
        [cell.btnEditType addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btnEditMessage.tag = TAG_BEACON_EDIT_MESSAGE + indexPath.row;
        [cell.btnEditMessage addTarget:self action:@selector(onClickFlashMessage:) forControlEvents:UIControlEventTouchUpInside];

        // beacon data
        
        cell.lbBeaconTitle.text = dic[@"BeaconData"][@"MainTitle"];
        cell.lbBeaconTagline.text = dic[@"BeaconData"][@"TagLine"];
        cell.lbBeaconDescription.text = dic[@"BeaconData"][@"Description"];
        NSString * beaconLogo = dic[@"BeaconData"][@"ThumbImage"];
        if (beaconLogo != nil && ![beaconLogo isKindOfClass:[NSNull class]]) {
            NSString * url = [beaconLogo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [cell.ivBeaconImage hnk_setImageFromURL:[NSURL URLWithString:url]];
        }
        
        return cell;
    }


    return nil;
}

//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    NSDictionary* dic = arrayBeacons[indexPath.row];
//    
//    int beaconTypeID = [dic[@"BeaconTypeID"] intValue];
//    
//    if (beaconTypeID == 1) { // business info
//        BeaconTypeCell2 *myCell = (BeaconTypeCell2*) cell;
//        [myCell removeMap];
//    }
//
//}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateBeacon:arrayBeacons[indexPath.row]];
    
    [tableView reloadData];
}
 */


@end
