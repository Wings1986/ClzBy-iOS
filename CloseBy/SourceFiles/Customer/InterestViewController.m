//
//  InterestViewController.m
//  CloseBy
//
//  Created by daniel on 12/16/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "InterestViewController.h"

#import "InterestHeaderTableViewCell.h"
#import "InterestTableViewCell.h"

#import "DealListViewController.h"

#define TAG_BTN_CHECK   1000


@interface InterestViewController ()<UITableViewDataSource, UITableViewDelegate> {

    IBOutlet UITableView * mTableView;
    
    NSMutableArray * arrayList;
    NSMutableArray* interestDataSource;
}

@end

@implementation InterestViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Choose Interests";
    
//    [self configureNavigationBar];
    
    [self fetchCategories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (interestDataSource == nil) {
        return 0;
    }
    return interestDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [interestDataSource[section][@"SubCategoryIDS"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    InterestHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterestHeaderTableViewCell"];
    
    BOOL bSelected = NO;
    for (NSDictionary * subCategory in interestDataSource[section][@"SubCategoryIDS"]) {
        if ([subCategory[@"selected"] boolValue]) {
            bSelected = YES;
            break;
        }
    }
    if (bSelected) {
        cell.mIcon.image = [UIImage imageNamed:@"icon_selected_category.png"];
    } else {
        cell.mIcon.image = [UIImage imageNamed:@"icon_unselected_category.png"];
    }
    
    cell.mLabelTitle.text = interestDataSource[section][@"MainCategoryName"];
    
    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickCategory:)];
    [cell.contentView addGestureRecognizer:gesture];
    cell.contentView.tag = TAG_BTN_CHECK + section * 1000;

    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InterestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterestTableViewCell"];
    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickCheck:)];
    [cell.contentView addGestureRecognizer:gesture];
    cell.contentView.tag = TAG_BTN_CHECK + indexPath.section * 1000 + indexPath.row;
    
    
    
    BOOL bSelected = [interestDataSource[indexPath.section][@"SubCategoryIDS"][indexPath.row][@"selected"] boolValue];
    if (bSelected) {
        cell.ivChecked.image = [UIImage imageNamed:@"icon_selected_sub_category.png"];
    } else {
        cell.ivChecked.image = [UIImage imageNamed:@"icon_unselected_sub_category.png"];
    }
    

    cell.lbTitle.text = interestDataSource[indexPath.section][@"SubCategoryIDS"][indexPath.row][@"CategoryName"];
    
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary * dic = interestDataSource[indexPath.section][@"SubCategoryIDS"][indexPath.row];
    [dic setObject:[NSNumber numberWithBool:![dic[@"selected"] boolValue]] forKey:@"Selected"];
    
    [tableView reloadData];
    
//    InterestTableViewCell *cell = (InterestTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
//    [self performToggleActionForCell:cell];
    
}
- (void) onClickCategory:(UIGestureRecognizer*) sender
{
    int section = ((int)sender.view.tag - TAG_BTN_CHECK) / 1000;

    BOOL bSelected = NO;
    for (NSDictionary * subCategory in interestDataSource[section][@"SubCategoryIDS"]) {
        if ([subCategory[@"selected"] boolValue]) {
            bSelected = YES;
            break;
        }
    }

    for (NSMutableDictionary * subCategory in interestDataSource[section][@"SubCategoryIDS"]) {
         subCategory[@"selected"] = [NSNumber numberWithBool:!bSelected];
    }
    
    int mainCategoryID = [interestDataSource[section][@"MainCategoryID"] intValue];
    
    for (NSMutableDictionary* main in  arrayList) {
        if ([main[@"MainCategoryID"] intValue] == mainCategoryID) {
            for (NSMutableDictionary* sub in main[@"SubCategoryIDS"]) {
                sub[@"selected"] = [NSNumber numberWithBool:!bSelected];
            }
        }
    }
    
    
    [mTableView reloadData];
    
}
- (void) onClickCheck:(UIGestureRecognizer*) sender
{
    int section = ((int)sender.view.tag - TAG_BTN_CHECK) / 1000;
    int row = ((int)sender.view.tag - TAG_BTN_CHECK) % 1000;
    
    NSMutableDictionary * dic = interestDataSource[section][@"SubCategoryIDS"][row];
    [dic setObject:[NSNumber numberWithBool:![dic[@"selected"] boolValue]] forKey:@"selected"];
    
    
    for (NSMutableDictionary* main in  arrayList) {
        if ([main[@"MainCategoryID"] intValue] == [dic[@"MainCategoryID"] intValue]) {
            NSMutableArray * arrSub = main[@"SubCategoryIDS"];
            for (NSMutableDictionary* sub in arrSub) {
                if ([sub[@"ID"] intValue] == [dic[@"ID"] intValue]) {
                    sub[@"selected"] = [NSNumber numberWithBool:[dic[@"selected"] boolValue]];
                    break;
                }
            }
        }
    }
    
    
    [mTableView reloadData];
    
}



- (void)fetchCategories {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestCategoriesUrl = [[NSString stringWithFormat:@"%@/GetAllCategoriesFixed.aspx?guid=%@&lat=%f&lng=%f&userid=%@", kServerURL, kGUID,
                                       [MyLocation sharedInstance].getCurLatitude,
                                       [MyLocation sharedInstance].getCurLongitude,
                                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        NSLog(@"request = %@", requestCategoriesUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestCategoriesUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              [CB_AlertView hideAlert];
              
              arrayList = [[NSMutableArray alloc] init];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];
              
              NSLog(@"response = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
//                  int strPrevID = -1;
//                  NSMutableDictionary* newDict;
//                  NSMutableArray*subCategories;
//                  
//                  for (NSDictionary * dic in responseJson[@"Data"]) {
//                      
//                      int ID = [dic[@"MainCategoryID"] intValue];
//                      if(ID != strPrevID){
//                          if(strPrevID != -1){
//                              [newDict setObject:subCategories forKey:@"subcategories"];
//                              [arrayList addObject:newDict];
//                          }
//                          
//                          newDict = [[NSMutableDictionary alloc] init];
//                          strPrevID = ID;
//                          
//                          [newDict setValue:dic[@"MainCategoryID"] forKey:@"MainCategoryID"];
//                          [newDict setValue:dic[@"MainCategoryName"] forKey:@"MainCategoryName"];
//                          
//                          subCategories = [[NSMutableArray alloc] init];
//                          NSMutableDictionary* subdict = [[NSMutableDictionary alloc] init];
//                          [subdict setValue:dic[@"MainCategoryID"] forKey:@"MainCategoryID"];
//                          [subdict setValue:dic[@"MainCategoryName"] forKey:@"MainCategoryName"];
//                          [subdict setValue:dic[@"SubCategoryID"] forKey:@"SubCategoryID"];
//                          [subdict setValue:dic[@"SubCategoryName"] forKey:@"SubCategoryName"];
//                          [subdict setValue:dic[@"Selected"] forKey:@"Selected"];
//                          [subCategories addObject:subdict];
//                          
//                      }else{
//                          NSMutableDictionary* subdict = [[NSMutableDictionary alloc] init];
//                          [subdict setValue:dic[@"MainCategoryID"] forKey:@"MainCategoryID"];
//                          [subdict setValue:dic[@"MainCategoryName"] forKey:@"MainCategoryName"];
//                          [subdict setValue:dic[@"SubCategoryID"] forKey:@"SubCategoryID"];
//                          [subdict setValue:dic[@"SubCategoryName"] forKey:@"SubCategoryName"];
//                          [subdict setValue:dic[@"Selected"] forKey:@"Selected"];
//                          [subCategories addObject:subdict];
//                      }
//                      
//                  }
//                  
//                  [newDict setObject:subCategories forKey:@"subcategories"];
//                  [arrayList addObject:newDict];
                  
                  
                  arrayList = [responseJson[@"Data"] mutableCopy];
                  interestDataSource = [arrayList mutableCopy];
                  
                  NSLog(@"interestDataSource = %@", interestDataSource);
                  
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

- (IBAction)onClickDone:(id)sender {
    NSString * selectedCategory = @"";
    for (NSDictionary * sectionDic in interestDataSource) {
        for (NSDictionary* category in sectionDic[@"SubCategoryIDS"]) {
            BOOL bSelected = [category[@"selected"] boolValue];
            if (bSelected) {
                if (selectedCategory.length < 1) {
                    selectedCategory = [selectedCategory stringByAppendingString:[NSString stringWithFormat:@"%d", [category[@"ID"] intValue]]];
                }
                else {
                    selectedCategory = [selectedCategory stringByAppendingString:[NSString stringWithFormat:@",%d", [category[@"ID"] intValue]]];
                }
            }
        }
    }

    NSLog(@"1 : selectedCategory = %@", selectedCategory);
    
    NSString *requestCategoriesUrl = [[NSString stringWithFormat:@"%@/SaveInterests.aspx?guid=%@&lat=%f&long=%f&UserID=%@&SelectedCategories=%@", kServerURL, kGUID,
                                       [MyLocation sharedInstance].getCurLatitude,
                                       [MyLocation sharedInstance].getCurLongitude,
                                       [GlobalAPI loadLoginID],
                                       selectedCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"interest url = %@", requestCategoriesUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:requestCategoriesUrl
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [CB_AlertView hideAlert];
              
              arrayList = [[NSMutableArray alloc] init];
              
              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              NSDictionary *responseJson = [responseString JSONValue];
              
              NSLog(@"response = %@", responseJson);
              
              if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                  [self dismissViewControllerAnimated:NO completion:^{
                      [self.delegate chooseCategory:selectedCategory] ;
                  }];
                  
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
- (IBAction)onClickSelectAll:(id)sender {
    
    for (NSMutableDictionary * category in interestDataSource) {
        for (NSMutableDictionary * dic in category[@"SubCategoryIDS"]) {
            [dic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
    }
    
    for (NSMutableDictionary * category in arrayList) {
        for (NSMutableDictionary * dic in category[@"SubCategoryIDS"]) {
            [dic setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
    }
    
    [mTableView reloadData];
    
}
- (IBAction)onClickDeselectAll:(id)sender {

    for (NSMutableDictionary * category in interestDataSource) {
        for (NSMutableDictionary * dic in category[@"SubCategoryIDS"]) {
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
    }
    
    for (NSMutableDictionary * category in arrayList) {
        for (NSMutableDictionary * dic in category[@"SubCategoryIDS"]) {
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
    }
    
    [mTableView reloadData];

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoDeals"]) {
        NSString * selectedCategory = @"";
        for (NSDictionary * sectionDic in interestDataSource) {
            for (NSDictionary* category in sectionDic[@"SubCategoryIDS"]) {
                BOOL bSelected = [category[@"selected"] boolValue];
                if (bSelected) {
                    if (selectedCategory.length < 1) {
                        selectedCategory = [selectedCategory stringByAppendingString:[NSString stringWithFormat:@"%d", [category[@"ID"] intValue]]];
                    }
                    else {
                        selectedCategory = [selectedCategory stringByAppendingString:[NSString stringWithFormat:@",%d", [category[@"ID"] intValue]]];
                    }
                }
            }
        }
        
//        DealListViewController *vc = segue.destinationViewController;
//        [vc setCategories:selectedCategory];

    }
}


- (BOOL) textFieldShouldClear:(UITextField *)textField{
    [textField resignFirstResponder];
    
    interestDataSource = [arrayList mutableCopy];
    [mTableView reloadData];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* change = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (arrayList == nil) {
        return YES;
    }
    
    interestDataSource = [[NSMutableArray alloc] init];
    
    if (change.length == 0) {
        interestDataSource = [arrayList mutableCopy];
    }
    else {
        
        
        for (NSDictionary * main in arrayList) {
            
            NSString * mainName = @"";
            NSString * subName = @"";

            NSMutableDictionary * mainDic = [[NSMutableDictionary alloc] init];
            mainDic[@"MainCategoryID"] = main[@"MainCategoryID"];
            mainDic[@"MainCategoryName"] = main[@"MainCategoryName"];
            
            mainName = main[@"MainCategoryName"];
            
            
            NSMutableArray * arraySub = [[NSMutableArray alloc] init];
            
            BOOL isMatched = NO;
            
            for (NSDictionary* dic in main[@"SubCategoryIDS"]) {
                
                subName = dic[@"CategoryName"];
                
                if ((mainName != nil && ![mainName isKindOfClass:[NSNull class]] && [mainName.uppercaseString containsString:change.uppercaseString])
                    || (subName != nil && ![subName isKindOfClass:[NSNull class]] && [subName.uppercaseString containsString:change.uppercaseString])) {
                    isMatched = YES;
                    [arraySub addObject:dic];
                }
                
            }
            
            if(isMatched){
                mainDic[@"SubCategoryIDS"] = arraySub;
                [interestDataSource addObject:mainDic];
            }
            
        }
        

    }
    
    [mTableView reloadData];
    
    return YES;
}


@end
