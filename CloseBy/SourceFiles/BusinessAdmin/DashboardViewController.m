//
//  DashboardViewController.m
//  CloseBy
//

#import "DashboardViewController.h"

#import "NIDropDown.h"

#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"

typedef enum {
    TODAY = 0,
    YESTERDAY,
    THISMONTH,
    LASTMONTH,
    SPECIFYDATE,
}FILTER_TYPE;

typedef enum
{
    START_TIME = 0,
    END_TIME
}BUTTON_TYPE;


@interface DashboardViewController()<NIDropDownDelegate>
{

    NIDropDown *dropDown;
    IBOutlet UIButton *btnFilter;
    
    IBOutlet UIButton *btnStartTime;
    IBOutlet UIButton *btnEndTime;
    IBOutlet UIButton *btnGo;
    
    IBOutlet MDRadialProgressView* totalImpression;
    IBOutlet MDRadialProgressView* totalLikes;
    IBOutlet MDRadialProgressView* totalMessages;
    
    
    IBOutlet UIDatePicker *mPickerView;
    IBOutlet NSLayoutConstraint *bottomPicker;
    BOOL m_isShowPicker;
    
    
    FILTER_TYPE m_filter;
    
    NSMutableDictionary * dicInfo;
    
    BUTTON_TYPE m_buttonType;
}
@end


@implementation DashboardViewController

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
    
    self.title = @"Dashboard";
    
    totalImpression.progressTotal = 5;
    totalImpression.progressCounter = 5;
    totalImpression.theme.completedColor = APP_COLOR;
    totalImpression.theme.incompletedColor = [UIColor whiteColor];
    totalImpression.theme.thickness = 5;
    totalImpression.theme.sliceDividerHidden = YES;
    totalImpression.theme.centerColor = [UIColor clearColor];
    totalImpression.theme.dropLabelShadow = NO;
    totalImpression.theme.labelColor = APP_COLOR;
    totalImpression.label.textColor = APP_COLOR;
    

    totalLikes.progressTotal = 5;
    totalLikes.progressCounter = 5;
    totalLikes.theme.completedColor = APP_COLOR;
    totalLikes.theme.incompletedColor = [UIColor whiteColor];
    totalLikes.theme.thickness = 5;
    totalLikes.theme.sliceDividerHidden = YES;
    totalLikes.theme.centerColor = [UIColor clearColor];
    totalLikes.theme.dropLabelShadow = NO;
    totalLikes.theme.labelColor = APP_COLOR;
    totalLikes.label.textColor = APP_COLOR;

    
    totalMessages.progressTotal = 5;
    totalMessages.progressCounter = 5;
    totalMessages.theme.completedColor = APP_COLOR;
    totalMessages.theme.incompletedColor = [UIColor whiteColor];
    totalMessages.theme.thickness = 5;
    totalMessages.theme.sliceDividerHidden = YES;
    totalMessages.theme.centerColor = [UIColor clearColor];
    totalMessages.theme.dropLabelShadow = NO;
    totalMessages.theme.labelColor = APP_COLOR;
    totalMessages.label.textColor = APP_COLOR;

    totalImpression.label.text = @"0";
    totalLikes.label.text = @"0";
    totalMessages.label.text = @"0";
    
    m_filter = TODAY;
    
    btnStartTime.layer.cornerRadius = 2;
    btnStartTime.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    btnStartTime.layer.shadowRadius = 2;
    btnStartTime.layer.shadowOffset = CGSizeMake(1, 1);
    btnStartTime.layer.shadowOpacity = 0.5;

    btnEndTime.layer.cornerRadius = 2;
    btnEndTime.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    btnEndTime.layer.shadowRadius = 2;
    btnEndTime.layer.shadowOffset = CGSizeMake(1, 1);
    btnEndTime.layer.shadowOpacity = 0.5;

    
    btnStartTime.hidden = YES;
    btnEndTime.hidden = YES;
    btnGo.hidden = YES;
    bottomPicker.constant = -216;
    mPickerView.backgroundColor = [UIColor whiteColor];
    
    [self getDashboard];
}

- (void) setInfos
{
    if (dicInfo != nil || [dicInfo isKindOfClass:[NSDictionary class]]) {
        totalImpression.label.text = [dicInfo[@"TotalDealImpressions"] isKindOfClass:[NSNull class]] ? @"0" : [NSString stringWithFormat:@"%d", [dicInfo[@"TotalDealImpressions"] intValue]];
        totalLikes.label.text = [dicInfo[@"TotalProductLikes"] isKindOfClass:[NSNull class]] ? @"0" : [NSString stringWithFormat:@"%d", [dicInfo[@"TotalProductLikes"] intValue]];
        totalMessages.label.text = [dicInfo[@"TotalNumberOfSentOutMessages"] isKindOfClass:[NSNull class]] ? @"0" : [NSString stringWithFormat:@"%d", [dicInfo[@"TotalNumberOfSentOutMessages"] intValue]];
    }
    else {
        totalImpression.label.text = @"0";
        totalLikes.label.text = @"0";
        totalMessages.label.text = @"0";
    }
}

- (void) getDashboard
{
    [CB_AlertView showAlertOnView:self.view];
    
    
    NSString *requestUrl = @"";
    
    if (m_filter == TODAY) {
        requestUrl = [[NSString stringWithFormat:@"%@/Analytics/BusinessAnalyticsTotals.aspx?guid=%@&UserID=%@",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        requestUrl = [[NSString stringWithFormat:@"%@/BusinessAnalyticsDays.aspx?guid=%@&UserID=%@&SelectedDay=Today",
//                       kServerURL,
//                       kGUID,
//                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else if (m_filter == YESTERDAY) {
        requestUrl = [[NSString stringWithFormat:@"%@/Analytics/BusinessAnalyticsDays.aspx?guid=%@&UserID=%@&SelectedDay=Yesterday",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    }
    else if (m_filter == THISMONTH) {
        requestUrl = [[NSString stringWithFormat:@"%@/Analytics/BusinessAnalyticsMonths.aspx?guid=%@&UserID=%@&SelectedMonth=ThisMonth",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    }
    else if (m_filter == LASTMONTH) {
        requestUrl = [[NSString stringWithFormat:@"%@/Analytics/BusinessAnalyticsMonths.aspx?guid=%@&UserID=%@&SelectedMonth=LastMonth",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    }
    else {
        NSString * startTime = [btnStartTime titleForState:UIControlStateNormal];
        NSString * endTime = [btnEndTime titleForState:UIControlStateNormal];

        requestUrl = [[NSString stringWithFormat:@"%@/Analytics/BusinessAnalyticsBetween.aspx?guid=%@&UserID=%@&StartDate=%@&EndDate=%@",
                       kServerURL,
                       kGUID,
                       [GlobalAPI loadLoginID],
                       startTime,
                       endTime] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    }
    
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
                  dicInfo = [responseJson[@"Data"] mutableCopy];
                  
                  [self setInfos];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [CB_AlertView hideAlert];
          }];

}
- (IBAction)filterClicked:(id)sender {
    
    [self hideShoppingPicker];
    
    NSArray * arrFilter = @[@"Today", @"Yesterday", @"This Month", @"Last Month", @"Specify Date"];

    if(dropDown == nil) {
        CGFloat f = 200;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arrFilter :nil :@"down"];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(NSInteger) row{

    m_filter = (int) row;
    
    if (m_filter == SPECIFYDATE) {
        btnStartTime.hidden = NO;
        btnEndTime.hidden = NO;
        btnGo.hidden = NO;
    }
    else {
        btnStartTime.hidden = YES;
        btnEndTime.hidden = YES;
        btnGo.hidden = YES;
        
        [self getDashboard];
    }
    
    [self rel];
}

-(void)rel{
    //    [dropDown release];
    dropDown = nil;
}
- (IBAction)onClickGO:(id)sender {
    
    [self hideShoppingPicker];
    
    NSString * startTime = [btnStartTime titleForState:UIControlStateNormal];
    NSString * endTime = [btnEndTime titleForState:UIControlStateNormal];
    
    if (startTime.length < 1 || [startTime isEqualToString:@"Start Time"]) {
        return;
    }
    if (endTime.length < 1 || [endTime isEqualToString:@"End Time"]) {
        return;
    }

    [self getDashboard];
}

- (IBAction)onClickStartTime:(id)sender {
    m_buttonType = START_TIME;
    [self showShoppingPicker:(UIButton*)sender];
}
- (IBAction)onClickEndTime:(id)sender {
    m_buttonType = END_TIME;
    [self showShoppingPicker:(UIButton*)sender];
    
}

- (IBAction)onChangeDatePicker:(id)sender {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString * time = [formatter stringFromDate:((UIDatePicker*)sender).date];
    
    
    if (m_buttonType == START_TIME) {
        [btnStartTime setTitle:time forState:UIControlStateNormal];
    }
    else {
        [btnEndTime setTitle:time forState:UIControlStateNormal];
    }

}

- (void)showShoppingPicker : (UIButton*) button {
//    if (m_isShowPicker) {
//        return;
//    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         bottomPicker.constant = 0;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = YES;

                         NSString * time = [button titleForState:UIControlStateNormal];
                         
                         if (time.length < 1
                             || [time isEqualToString:@"Start Time"]
                             || [time isEqualToString:@"End Time"]) {
                             
                             mPickerView.date = [NSDate new];
                             
                             NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                             [formatter setDateFormat:@"MM/dd/yyyy"];
                             
                             NSString * time = [formatter stringFromDate:[NSDate new]];
                             
                             [button setTitle:time forState:UIControlStateNormal];
                         }
                         else {
                             NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                             [formatter setDateFormat:@"MM/dd/yyyy"];
                             NSDate * dateTime = [formatter dateFromString:time];
                             mPickerView.date = dateTime;
                         }
                         
                     }];
}
- (void)hideShoppingPicker {
    if (!m_isShowPicker) {
        return;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         bottomPicker.constant = -216;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = NO;
                     }];
}

- (void) hideKeyboard :(UIGestureRecognizer*) gesture{
    [super hideKeyboard:gesture];
    
    if (m_isShowPicker) {
        [self hideShoppingPicker];
    }
}
@end
