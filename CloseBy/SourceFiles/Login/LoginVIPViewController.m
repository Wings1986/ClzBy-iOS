//
//  LoginVIPViewController.m
//  CloseBy
//
//  Created by Kevin on 2/18/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "LoginVIPViewController.h"

@interface LoginVIPViewController ()
{
    
    IBOutlet UITextField *tfMemberCode;
}

@end

@implementation LoginVIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.allowsSelection = NO;
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
- (IBAction)onClickSubmit:(id)sender {
}

@end
