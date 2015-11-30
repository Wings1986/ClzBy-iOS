//
//  BaseViewController.m
//  CloseBy
//
//  Created by iGold on 3/9/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "BaseViewController.h"

@implementation UIView (FindFirstResponder)

-(UIView*) findFirstResponder {
    
    if (self.isFirstResponder) return self;
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        if (firstResponder != nil) return firstResponder;
    }
    return nil;
    
}

@end

@interface BaseViewController()<UITextFieldDelegate, UITextViewDelegate>
@end

@implementation BaseViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
//    UIImage *image = [UIImage imageNamed:@"background.png"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    
    toolBar = [self createToolbar];

    
    // UITextfield placeholder color
    [self listSubviewsOfViewForColor:self.view];
    
    
//    [DaiDodgeKeyboard addRegisterTheViewNeedDodgeKeyboard:self.view];
    
    if (!_skipSearch) {
        [self createSearchView];
    }
    
}


-(UIToolbar*) createToolbar {
    
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    tb.tintColor = APP_COLOR;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldDone)];
    UIButton * btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone addTarget:self action:@selector(textFieldDone) forControlEvents:UIControlEventTouchUpInside];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.frame = CGRectMake(0.0, 0.0, 60.0, 40.0);
    
    btnDone.titleLabel.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:15.0f];
    [btnDone setTitleColor:APP_COLOR forState:UIControlStateNormal];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
    
    tb.items = @[space, done];
    
    return tb;
    
}
-(void) textFieldDone {
    
    [[self.view findFirstResponder] resignFirstResponder];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
#pragma mark - tap gesture
- (void) hideKeyboard :(UIGestureRecognizer*) gesture
{
    [self listSubviewsOfView:gesture.view];
}

- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([view isKindOfClass:[UITextField class]]) {
        if ([view isFirstResponder]) {
            [view resignFirstResponder];
        }
        return;
    }
    //    if ([subviews count] == 0) {
    //       if ([view isKindOfClass:[UITextField class]]) {
    //           if ([view isFirstResponder]) {
    //               [view resignFirstResponder];
    //           }
    //       }
    //       return; // COUNT CHECK LINE
    //    }
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        //        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
}

- (void)listSubviewsOfViewForColor:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([view isKindOfClass:[UITextField class]]) {
        [view setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        ((UITextField*) view).autocorrectionType = UITextAutocorrectionTypeNo;
        
        ((UITextField*) view).delegate = self;
        
        [view performSelector:@selector(setDelegate:) withObject:self];
        
        if (((UITextField*)view).keyboardType == UIKeyboardTypeNumberPad
            || ((UITextField*)view).keyboardType == UIKeyboardTypePhonePad) {
            [view performSelector:@selector(setInputAccessoryView:) withObject:toolBar];
        }
        
        return;
    }
    if ([view isKindOfClass:[UITextView class]]) {
        
        ((UITextView*) view).delegate = self;
        
        [view performSelector:@selector(setDelegate:) withObject:self];
        
        [view performSelector:@selector(setInputAccessoryView:) withObject:toolBar];
        
        return;
    }
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        //        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfViewForColor:subview];
    }
}

#pragma mark - search bar

- (void) createSearchView
{
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchView.backgroundColor = APP_COLOR;
    
    searchField = [[RoundTextField alloc] initWithFrame:CGRectMake(8, 5, 304, 34)];
    searchField.delegate = self;
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.textColor = [UIColor blackColor];
    searchField.placeholder = @"Search";
    searchField.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:12.0f];
    
    [searchView addSubview:searchField];
    
    [self.view addSubview:searchView];
    
    searchView.hidden = YES;
}


- (void) showSearchBar {
    if (searchView == nil) {
        return;
    }
    
    if (!searchView.hidden) {
        return;
    }
    
    searchView.alpha = 0;
    searchView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        searchView.alpha = 1.0f;
    }];
}
- (void) hideSearchBar {
    if (searchView == nil) {
        return;
    }
    
    if (searchView.hidden) {
        return;
    }
    
    searchView.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        searchView.alpha = 0;
    } completion:^(BOOL finished) {
        searchView.hidden = YES;
    }];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (searchView == nil) {
        return;
    }
    
    CGPoint pos = [scrollView.panGestureRecognizer velocityInView:scrollView];
    float yVelocity = pos.y;
    
    if (yVelocity > 0 && searchView.hidden == NO) {
        [self hideSearchBar];
    }
    else if (yVelocity < 0 && searchView.hidden == YES) {
        [self showSearchBar];
    }
}


@end
