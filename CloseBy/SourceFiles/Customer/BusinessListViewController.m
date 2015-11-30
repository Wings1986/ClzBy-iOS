//
//  BusinessListViewController.m
//  CloseBy
//
//  Created by Denis Cossaks on 4/7/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BusinessListViewController.h"

#import "BusinessCell.h"
#import <Haneke.h>
#import "URBAlertView.h"

#import "SVPullToRefresh.h"

#import "ProfileViewController.h"

#define  TAG_VIEW_CONTENT 3000


@interface BusinessListViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *mTableView;
    
    NSMutableArray * arrayBusiness;
    NSMutableArray* arrayDataSource;
    
    int     m_limit;
    int     m_offset;
}

@property (nonatomic, assign) BOOL _loading;

@end

@implementation BusinessListViewController

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
    
     self.title = @"Shops CloseBy";
    
    mTableView.separatorColor = APP_COLOR;
    
    __weak BusinessListViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [mTableView addPullToRefreshWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startRefresh];
        }
        
    }];
    
    // setup infinite scrolling
    [mTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startMoreLoad];
        }
    }];
    
    m_offset = 0;
    m_limit = 10;
    
    [self startRefresh];
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

    if ([segue.identifier isEqualToString:@"gotoprofile"]) {
        
        ProfileViewController * vc = segue.destinationViewController;
        vc.businessUserID = ((NSDictionary*)sender)[@"UserID"];
    }
}


#pragma mark - Refresh & More Load
- (void)startRefresh {
    
    m_offset = 0;
    
    [self fetchBusinessList];
}

- (void)startMoreLoad {
    
    if (m_offset < m_limit) {
        [self doneLoadingTableViewData];
        return;
    }
    
    [self fetchBusinessList];
}
- (void) doneLoadingTableViewData
{
    [mTableView reloadData];
    
    [mTableView.pullToRefreshView stopAnimating];
    [mTableView.infiniteScrollingView stopAnimating];
    
    self._loading = NO;
}

- (void)fetchBusinessList {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetBusinessesWithinRange.aspx?guid=%@&UserID=%@&userlat=%f&userlong=%f&range=%d&fromrow=%d&limit=%d",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID],
                             [MyLocation sharedInstance].getCurLatitude,
                             [MyLocation sharedInstance].getCurLongitude,
                             500,
                             m_offset,
                             m_limit] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
                  
                  NSMutableArray * result = responseJson[@"Data"][@"BusinessListing"];
                  
                  if (result != nil && result.count > 0) {
                      if (arrayBusiness == nil || m_offset == 0) {
                          arrayBusiness = [[NSMutableArray alloc] initWithArray:result];
                      }
                      else {
                          [arrayBusiness addObjectsFromArray:result];
                      }
                      
                      arrayDataSource = [arrayBusiness mutableCopy];
                      
                      [self searchFilter:searchField.text];
                      
                      m_offset += m_limit;
                      
                  }
                  
                  [self doneLoadingTableViewData];
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

- (void) onTapCell:(UIGestureRecognizer* ) gesture
{
    NSInteger tag = gesture.view.tag - TAG_VIEW_CONTENT;
    
    [self performSegueWithIdentifier:@"gotoprofile" sender:arrayDataSource[tag]];
}

#pragma mark UITextField Delegate
- (BOOL) textFieldShouldClear:(UITextField *)textField{
    [textField resignFirstResponder];
    
    arrayDataSource = [arrayBusiness mutableCopy];
    [mTableView reloadData];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* change = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (arrayBusiness == nil) {
        return YES;
    }
    
    [self searchFilter:change];
    
    [mTableView reloadData];
    
    return YES;
}

- (void) searchFilter:(NSString*) change {

    arrayDataSource = [[NSMutableArray alloc] init];
    
    if (change.length == 0) {
        arrayDataSource = [arrayBusiness mutableCopy];
    }
    else {
        for (NSDictionary * dic in arrayBusiness) {
            
            NSString * businessName = dic[@"BusinessName"];
            NSString * categories = dic[@"CategoryName"];
            NSString * address = dic[@"BusinessAddressUserInput"];
            
            if ((businessName != nil && ![businessName isKindOfClass:[NSNull class]] && [businessName.uppercaseString containsString:change.uppercaseString])
                || (categories != nil && ![categories isKindOfClass:[NSNull class]] && [categories.uppercaseString containsString:change.uppercaseString])
                || (address != nil && ![address isKindOfClass:[NSNull class]] && [address.uppercaseString containsString:change.uppercaseString])) {
                
                [arrayDataSource addObject:dic];
            }
        }
    }
}

#pragma mark - Table view data source

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrayDataSource == nil) {
        return 0;
    }
    return arrayDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    int widthThumb = [arrayBusiness[indexPath.row][@"MediumWidth"] isKindOfClass:[NSNull class]] ? 1 : [arrayBusiness[indexPath.row][@"MediumWidth"] intValue];
//    int heightThumb = [arrayBusiness[indexPath.row][@"MediumHeight"] isKindOfClass:[NSNull class]] ? 1 : [arrayBusiness[indexPath.row][@"MediumHeight"] intValue];
//    
//    float height = heightThumb * tableView.frame.size.width / widthThumb + 116;
//    
//    return height;
    return 74.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCell:)]];
    cell.contentView.tag = TAG_VIEW_CONTENT + indexPath.item;
    
    
    
    NSDictionary * product = arrayDataSource[indexPath.row];
    
    
    cell.ivPhoto.image = nil;
    cell.ivPhoto.layer.cornerRadius = 5;
    
    @try {
        cell.ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
        [cell.ivPhoto setClipsToBounds:YES];
        
        NSString * url = [product[@"LogoImageThumb"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivPhoto hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    @try {
        cell.lbBusinessName.text = product[@"BusinessName"] == nil ? @"" : product[@"BusinessName"];
        cell.lbBusinessAddress.text = [product[@"BusinessAddressUserInput"] isKindOfClass:[NSNull class]] ? @"" : product[@"BusinessAddressUserInput"];
        cell.lbBusinessEmail.text = [product[@"CategoryName"] isKindOfClass:[NSNull class]] ? @"" : product[@"CategoryName"];
        
        if ([GlobalAPI isBusiness]) {
            cell.ivLike.hidden = YES;
            cell.lbLikes.hidden = YES;
        }
        else {
            cell.ivLike.hidden = NO;
            cell.lbLikes.hidden = NO;

            if ([product[@"CurrentUserLikesBusiness"] isKindOfClass:[NSNull class]]) {
                cell.ivLike.image = [UIImage imageNamed:@"like-button.png"];
            }
            else {
                cell.ivLike.image = [UIImage imageNamed:@"like-button-tapped.png"];
            }
            cell.lbLikes.text = [product[@"Likes"] isKindOfClass:[NSNull class]] ? @"0 Like" : [NSString stringWithFormat:@"%d Likes", [product[@"Likes"] intValue]];
            
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"error = %@", exception.description);
    }
    @finally {
        
    }
   

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"gotoprofile" sender:arrayDataSource[indexPath.row]];
}


@end
