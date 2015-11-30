//
//  DropDownListView.m
//  KDropDownMultipleSelection
//
//  Created by macmini17 on 03/01/14.
//  Copyright (c) 2014 macmini17. All rights reserved.
//

#import "DropDownListView.h"
#import "DropDownViewCell.h"

#define DROPDOWNVIEW_SCREENINSET 0
#define DROPDOWNVIEW_HEADER_HEIGHT 50.
#define RADIUS 5.0f
#define DROPDOWNVIEW_FOOTER_HEIGHT 50.


@interface DropDownListView (private)
- (void)fadeIn;
- (void)fadeOut;
@end
@implementation DropDownListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions indexData:(NSArray*)aIndex key:(NSString*)key xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple
{
    isMultipleSelection=isMultiple;
    float height = MIN(size.height, DROPDOWNVIEW_HEADER_HEIGHT+[aOptions count]*44+DROPDOWNVIEW_FOOTER_HEIGHT);
    CGRect rect = CGRectMake(point.x, point.y, size.width, height);
    if (self = [super initWithFrame:rect])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        self.layer.borderColor = APP_COLOR.CGColor;
        self.layer.borderWidth  =1;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(2.5, 2.5);
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOpacity = 0.5f;
        
        _kTitleText = [aTitle copy];
        keyValue = key;
        
        // title
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, DROPDOWNVIEW_HEADER_HEIGHT)];
        titleLabel.backgroundColor = APP_COLOR;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:15.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = _kTitleText;
        [self addSubview:titleLabel];
        
        _kDropDownOption = [aOptions copy];
        _arryData=[[NSMutableArray alloc] initWithArray:aIndex];
        
        
        _kTableView = [[UITableView alloc] initWithFrame:CGRectMake(DROPDOWNVIEW_SCREENINSET,
                                                                   DROPDOWNVIEW_SCREENINSET + DROPDOWNVIEW_HEADER_HEIGHT,
                                                                   rect.size.width - 2 * DROPDOWNVIEW_SCREENINSET,
                                                                   rect.size.height - 2 * DROPDOWNVIEW_SCREENINSET - DROPDOWNVIEW_HEADER_HEIGHT - DROPDOWNVIEW_FOOTER_HEIGHT - RADIUS)];
        _kTableView.separatorColor = [UIColor clearColor]; //[UIColor colorWithWhite:1 alpha:.2];
        _kTableView.separatorInset = UIEdgeInsetsZero;
        _kTableView.backgroundColor = [UIColor clearColor];
        _kTableView.dataSource = self;
        _kTableView.delegate = self;
        [self addSubview:_kTableView];
        
        if (isMultipleSelection || YES) {
            UIButton *btnDone=[UIButton  buttonWithType:UIButtonTypeCustom];
            [btnDone setFrame:CGRectMake((rect.size.width-120)/2, rect.size.height-DROPDOWNVIEW_FOOTER_HEIGHT + (DROPDOWNVIEW_FOOTER_HEIGHT-36)/2,
                                         120, 36)];
            [btnDone setBackgroundColor:APP_COLOR];
            [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
            [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnDone.titleLabel.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:13.0];
            btnDone.layer.cornerRadius = btnDone.frame.size.height/2;
            [btnDone addTarget:self action:@selector(Click_Done) forControlEvents: UIControlEventTouchUpInside];
            [self addSubview:btnDone];
        }

        
    }
    return self;
}
-(void)Click_Done{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(DropDownListView:indexlist:)]) {

        NSLog(@"%@",self.arryData);
        
//        NSMutableArray *arryResponceData=[[NSMutableArray alloc]init];
//        for (int k=0; k<self.arryData.count; k++) {
//            NSIndexPath *path=[self.arryData objectAtIndex:k];
//            [arryResponceData addObject:[_kDropDownOption objectAtIndex:path.row]];
//            NSLog(@"pathRow=%d", (int)path.row);
//        }
    
        [self.delegate DropDownListView:self indexlist:self.arryData];
        
    }
    // dismiss self
    [self fadeOut];
}
#pragma mark - Private Methods
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}
- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_kDropDownOption count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"DropDownViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    cell = [[DropDownViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    
    int row = (int)[indexPath row];
    UIImageView *imgarrow=[[UIImageView alloc] initWithFrame:CGRectMake(15,12, 12, 12)];
    
    if([self.arryData containsObject:indexPath]){
        imgarrow.image=[UIImage imageNamed:@"icon_selected_sub_category.png"];
    } else {
        imgarrow.image=[UIImage imageNamed:@"icon_unselected_sub_category.png"];
    }
    
    [cell addSubview:imgarrow];

    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(40,0, cell.frame.size.width, 36)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:12.];

    titleLabel.text = _kDropDownOption[row][keyValue];
    [cell addSubview:titleLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isMultipleSelection) {
        if([self.arryData containsObject:indexPath]){
            [self.arryData removeObject:indexPath];
        } else {
            [self.arryData addObject:indexPath];
        }
        [tableView reloadData];

    } else {
    
//        if (self.delegate && [self.delegate respondsToSelector:@selector(DropDownListView:didSelectedIndex:)]) {
//            [self.delegate DropDownListView:self didSelectedIndex:[indexPath row]];
//        }
//        // dismiss self
//        [self fadeOut];
        
        if([self.arryData containsObject:indexPath]){
            [self.arryData removeObject:indexPath];
        } else {
            
            [self.arryData removeAllObjects];
            
            [self.arryData addObject:indexPath];
        }
        [tableView reloadData];

        
        
    }
	
}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // tell the delegate the cancellation
}

@end
