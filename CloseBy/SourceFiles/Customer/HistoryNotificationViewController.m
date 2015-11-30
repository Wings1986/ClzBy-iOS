//
//  HistoryNotificationViewController.m
//  CloseBy
//
//  Created by Denis Cossaks on 4/8/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "HistoryNotificationViewController.h"

#import <Haneke.h>
#import "URBAlertView.h"

#import "NotifyFlashMessage.h"
#import "ProfileViewController.h"

@interface HistoryNotificationViewController ()<UIPageViewControllerDataSource, NotifyFlashMessageDelegate>
{
    
    NSMutableArray * arrayNotification;
}
@end

@implementation HistoryNotificationViewController

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Notifications";
    
    [self fetchNotificationList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)fetchNotificationList {
    
    [CB_AlertView showAlertOnView:self.view];
    
    NSString *requestUrl = [[NSString stringWithFormat:@"%@/BeaconFeedForCustomer.aspx?guid=%@&UserID=%@",
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
                  arrayNotification = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                  
                  [self setInterface];
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

- (void) setInterface {

    self.dataSource = self;
    
    NotifyFlashMessage *startingViewController = [self viewControllerAtIndex:0];
    if (startingViewController == nil) {
        return;
    }
    
    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    NSArray *subviews = self.view.subviews;
    UIPageControl *thisControl = nil;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    
    thisControl.hidden = true;
    self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    
}

- (NotifyFlashMessage *)viewControllerAtIndex:(NSUInteger)index
{
    if (arrayNotification == nil
        || arrayNotification.count == 0
        || index >= arrayNotification.count) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    NotifyFlashMessage *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotifyFlashMessage"];
    
    pageContentViewController.responseData = arrayNotification[index];
    
    pageContentViewController.bMultiData = YES;
    pageContentViewController.pageIndex = index;
    pageContentViewController.pageTotal = arrayNotification.count;
    
    pageContentViewController.delegate = self;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((NotifyFlashMessage*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((NotifyFlashMessage*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [arrayNotification count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    if (arrayNotification == nil) {
        return 0;
    }
    
    return [arrayNotification count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - PageContentVC delegate
- (void) gotoBackward:(NSUInteger)page
{
    NotifyFlashMessage *viewController = [self viewControllerAtIndex:page];
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}
- (void) gotoForward:(NSUInteger)page
{
    NotifyFlashMessage *viewController = [self viewControllerAtIndex:page];
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}
- (void) takeMe:(NSUInteger)page
{
    ProfileViewController *vc = (ProfileViewController*)[self.storyboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
    
    vc.businessUserID = arrayNotification[page][@"BusinessID"];
    vc.bShowBackButton = YES;
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
    
}
@end
