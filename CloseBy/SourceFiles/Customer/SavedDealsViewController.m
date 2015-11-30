//
//  SavedDealsViewController.m
//  CloseBy
//
//  Created by Denis Cossaks on 4/8/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "SavedDealsViewController.h"

//#import "SavedDealCell.h"

#import "BusinessCell.h"


#import <Haneke.h>
#import "URBAlertView.h"

#import "ProfileViewController.h"

#define  TAG_VIEW_CONTENT 3000

@interface SavedDealsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *mTableView;
    
    NSMutableArray * arrayList;
    NSMutableArray* arrayDataSource;
}
@end

@implementation SavedDealsViewController

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
    
    self.title = @"Favourites";
    
    [self fetchSavedDealList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"gotoprofile"]) {
        
        ProfileViewController * vc = segue.destinationViewController;
        vc.businessUserID = ((NSDictionary*)sender)[@"BusinessUserID"];
    }
}

- (void) fetchSavedDealList {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetAllUserSavedDeals.aspx?guid=%@&UserID=%@",
                             kServerURL,
                             kGUID,
                             [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
                  arrayList = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                  arrayDataSource = [arrayList mutableCopy];
                  
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

#pragma mark UITextField Delegate
- (BOOL) textFieldShouldClear:(UITextField *)textField{
    [textField resignFirstResponder];
    
    arrayDataSource = [arrayList mutableCopy];
    [mTableView reloadData];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* change = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (arrayList == nil) {
        return YES;
    }
    
    [self searchFilter:change];
    
    [mTableView reloadData];
    
    return YES;
}

- (void) searchFilter:(NSString*) change {
    arrayDataSource = [[NSMutableArray alloc] init];
    
    if (change.length == 0) {
        arrayDataSource = [arrayList mutableCopy];
    }
    else {
        for (NSDictionary * dic in arrayList) {
            
            NSString * productName = dic[@"ProductName"];
            NSString * businessName = dic[@"BusinessName"];
            
            
            if ((productName != nil && ![productName isKindOfClass:[NSNull class]] && [productName.uppercaseString containsString:change.uppercaseString])
                || (businessName != nil && ![businessName isKindOfClass:[NSNull class]] && [businessName.uppercaseString containsString:change.uppercaseString])) {
                
                [arrayDataSource addObject:dic];
            }
        }
    }

}
- (void) onTapCell:(UIGestureRecognizer* ) gesture
{
    NSInteger tag = gesture.view.tag - TAG_VIEW_CONTENT;
    
    [self performSegueWithIdentifier:@"gotoprofile" sender:arrayDataSource[tag]];
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
        
        NSString * url = [product[@"ThumbImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.ivPhoto hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    @try {
        cell.lbBusinessName.text = [product[@"ProductName"] isKindOfClass:[NSNull class]] ? @"" : product[@"ProductName"];
        cell.lbBusinessAddress.text = [product[@"BusinessName"] isKindOfClass:[NSNull class]] ? @"" : product[@"BusinessName"];
        cell.lbBusinessEmail.text = [product[@"DiscountedTagLine"] isKindOfClass:[NSNull class]] ? @"" : product[@"DiscountedTagLine"];

        cell.lbLikes.text = [product[@"NumberOfLikes"] isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%d Likes", [product[@"NumberOfLikes"] intValue]] ;
    }
    @catch (NSException *exception) {
        NSLog(@"error = %@", exception.description);
    }
    @finally {
        
    }
    
    
    return cell;
}

@end
