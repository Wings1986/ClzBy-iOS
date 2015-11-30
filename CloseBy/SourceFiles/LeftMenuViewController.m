//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"



#import "InterestHeaderTableViewCell.h"
#import "MenuProfileCell.h"
#import "MenuTextCell.h"
#import "MenuUserTopCell.h"

#import "AppDelegate.h"
#import "UIImage+JSMessagesView.h"
#import <Haneke.h>

#import "ProfileViewController.h"

@interface LeftMenuViewController()
{
    BOOL isBusiness;
}

@end

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
//	self.tableView.separatorColor = [UIColor clearColor];
	
    [self.tableView setContentInset:UIEdgeInsetsMake(0,
                                                     self.tableView.contentInset.left,
                                                     self.tableView.contentInset.bottom,
                                                     self.tableView.contentInset.right)];
    
    self.view.backgroundColor = APP_COLOR;
    
    isBusiness = [GlobalAPI isBusiness];
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"notification_change_profile"
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *notification)
     {
         NSLog(@"Notification received!");
         
         [self.tableView reloadData];

     }];
    
}

#pragma mark - UITableView Delegate & Datasrouce -

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (isBusiness) {
        return 9;
    }
    
    // customer
	return 7;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    InterestHeaderTableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:@"InterestHeaderTableViewCell"];
//    
//    sectionHeaderView.mBackgroundView.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:0.5f];
//    sectionHeaderView.mLabelTitle.text = isBusiness ? @"MENU FOR BUSINESS SIDE" : @"MEMU FOR CUSTOMER SIDE";
//    
//    return sectionHeaderView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 140.0f;
    }
    else {
        return 50.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isBusiness) {
        if (indexPath.row == 0) {
            MenuProfileCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MenuProfileCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([GlobalAPI loadUserImage] != nil && [GlobalAPI loadUserImage].length > 0) {

                NSString * url = [[GlobalAPI loadUserImage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [cell.ivPic hnk_setImageFromURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"avatar.png"] success:^(UIImage *image) {

                    [cell.ivPic setImage:image];
//                    [cell.ivPic setImage:[image circleImageWithSize:cell.ivPic.frame.size.width]];
                    
                } failure:^(NSError *error) {
                    
                }];
                
            } else {
                [cell.ivPic setImage:[UIImage imageNamed:@"avatar.png"]];
//                [cell.ivPic setImage:[[UIImage imageNamed:@"avatar.png"] circleImageWithSize:cell.ivPic.frame.size.width]];
            }
            
//            cell.ivPic.layer.borderColor = [UIColor colorWithRed:113.0f/255.0f green:113.0f/255.0f blue:113.0f/255.0f alpha:0.8f].CGColor;
//            cell.ivPic.layer.borderWidth = 3;
//            cell.ivPic.layer.cornerRadius = cell.ivPic.frame.size.height/2.0f;
//            cell.ivPic.clipsToBounds = YES;

            cell.lbName.text = [GlobalAPI loadUsername];
            [cell.contentView bringSubviewToFront:cell.lbName];
            
            return cell;
        }
        else {
            
            MenuTextCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MenuTextCell"];

//            UIView *bgColorView = [[UIView alloc] init];
//            bgColorView.backgroundColor = [UIColor whiteColor];
//            [cell setSelectedBackgroundView:bgColorView];
            
            if (indexPath.row == 1) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_profile.png"]];
                cell.lbTitle.text = @"Profile";
            }
            else if (indexPath.row == 2) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_inventory.png"]];
                cell.lbTitle.text = @"Inventory";
            }
            else if (indexPath.row == 3) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_beacon.png"]];
                cell.lbTitle.text = @"Beacons";
            }
            else if (indexPath.row == 4) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_dashboard.png"]];
                cell.lbTitle.text = @"Dashboard";
            }
            else if (indexPath.row == 5) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_deals.png"]];
                cell.lbTitle.text = @"What's CloseBy?";
            }
            else if (indexPath.row == 6) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_shop.png"]];
                cell.lbTitle.text = @"Shops CloseBy";
            }
            else if (indexPath.row == 7) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_map.png"]];
                cell.lbTitle.text = @"Map";
            }
            else if (indexPath.row == 8) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_logout.png"]];
                cell.lbTitle.text = @"Log Out";
            }
            
            return cell;
        }

    }
    else { // customer
        
        if (indexPath.row == 0) {
            MenuUserTopCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MenuUserTopCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else {
            MenuTextCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MenuTextCell"];
            
            if (indexPath.row == 1) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_deals.png"]];
                cell.lbTitle.text = @"What's CloseBy?";
            }
            else if (indexPath.row == 2) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_shop.png"]];
                cell.lbTitle.text = @"Shops CloseBy";
            }
            else if (indexPath.row == 3) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_map.png"]];
                cell.lbTitle.text = @"Map";
            }
            else if (indexPath.row == 4) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_favourite.png"]];
                cell.lbTitle.text = @"Favourites";
            }
            else if (indexPath.row == 5) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_notify.png"]];
                cell.lbTitle.text = @"Notifications";
            }
            //        else if (indexPath.row == 5) {
            //            [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_setting.png"]];
            //            cell.lbTitle.text = @"Settings";
            //        }
            else if (indexPath.row == 6) {
                [cell.ivIcon setImage:[UIImage imageNamed:@"icon_menu_logout.png"]];
                cell.lbTitle.text = @"Log Out";
            }
            
            return cell;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
	
	UIViewController *vc ;
	
    if (isBusiness) {
        switch (indexPath.row)
        {
            case 0:
                return;
                
            case 1:{
                ProfileViewController *vc = (ProfileViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
                vc.bShowEditButton = YES;
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
                return;
            }
                
            case 2:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"InventoryViewController"];
                break;
                
            case 3:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"BeaconsViewController"];
                break;
                
            case 4:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"DashboardViewController"];
                break;
                
            case 5:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"DealListViewController"];
                break;
                
            case 6:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"BusinessListViewController"];
                break;
                
            case 7:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MapViewController"];
                break;
                
            case 8:
            {
                [(AppDelegate*)[UIApplication sharedApplication].delegate logOut];
            }
                return;
                
        }
    }
    else {
        switch (indexPath.row)
        {
            case 0:
                return;
                
            case 1:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"DealListViewController"];
                break;
                
            case 2:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"BusinessListViewController"];
                break;
                
            case 3:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MapViewController"];
                break;
                
            case 4:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SavedDealsViewController"];
                break;
                
            case 5:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HistoryNotificationViewController"];
                break;
                
//            case 5:
//                return;
//                break;
            case 6:
            {
                [(AppDelegate*)[UIApplication sharedApplication].delegate logOut];
            }
                return;
        }
    }
	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
															 withSlideOutAnimation:self.slideOutAnimationEnabled
																	 andCompletion:nil];
}

@end
