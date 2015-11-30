//
//  MerchantAddProductViewController.m
//  CloseBy
//
//  Created by arian on 12/30/14.
//  Copyright (c) 2014 clzby. All rights reserved.
//

#import "MerchantAddProductViewController.h"

#import <Haneke.h>
#import "DropDownListView.h"

@interface MerchantAddProductViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, kDropDownListViewDelegate> {
    
    
    IBOutlet UITextField *productNameField;
    IBOutlet UITextField *categoryField;
    IBOutlet UITextField *priceField;
    IBOutlet UITextField *descriptionField;
    IBOutlet UIImageView *productImageView;

    IBOutlet UIButton *btnAction;

    
    IBOutlet UIPickerView *mPickerView;
    IBOutlet NSLayoutConstraint *constraintBottomPicker;
    BOOL m_isShowPicker;
    
    NSMutableArray * arrayCategory;
//    int     selectedIndexCategory;
    NSMutableArray * arraySelectedIndexCategory;
    

    DropDownListView * Dropobj;
    
}

@end


@implementation MerchantAddProductViewController

#pragma mark - Private Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (_productData != nil) { // update
        self.title = @"Update Product";
        [btnAction setTitle:@"Update Product" forState:UIControlStateNormal];
        
        productNameField.text = _productData[@"ProductName"];
        priceField.text = [NSString stringWithFormat:@"%@", [_productData[@"OrigionalPrice"] stringValue]];
        descriptionField.text = _productData[@"ProductDescription"];
        NSString * url = [_productData[@"ProductPhoto"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [productImageView hnk_setImageFromURL:[NSURL URLWithString:url]];
    }
    else {
        self.title = @"Add Product";
        [btnAction setTitle:@"Add Product" forState:UIControlStateNormal];
    }
    
    UITapGestureRecognizer * tapGestureImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChoosePhoto:)];
    productImageView.userInteractionEnabled = YES;
    [productImageView addGestureRecognizer:tapGestureImage];
    
    
    constraintBottomPicker.constant = -180;
    
    arraySelectedIndexCategory = [NSMutableArray new];
    
    [self getCategories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Choose photo
-(void) onChoosePhoto:(UITapGestureRecognizer*) recognizer {
    
    [super listSubviewsOfView:self.view];
    [self hidePicker];
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Choose Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll", @"New Picture", nil];
    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // camera roll
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [imagePicker setAllowsEditing:YES];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    else if (buttonIndex == 1) {//new picture
        if( ![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            return;
        
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [imagePicker setShowsCameraControls:YES];
        [imagePicker setAllowsEditing:YES];
        
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];

    productImageView.image = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)addProductionAction:(id)sender {
    
    NSString *productName = productNameField.text;
    NSString *categoryName = categoryField.text;
    NSString *priceName = priceField.text;
    NSString *tagline = descriptionField.text;
    
    if (productName == nil || [productName isEqualToString:@""]) {
        [GlobalAPI showAlertView:@"Invalid Data" message:@"Product Name is not valid"];
        return;
    }
    
    if (tagline == nil || [tagline isEqualToString:@""]) {
        [GlobalAPI showAlertView:@"Invalid Data" message:@"Tag Line is not valid"];
        return;
    }
    
    if (categoryName == nil || [categoryName isEqualToString:@""]) {
        [GlobalAPI showAlertView:@"Invalid Data" message:@"Category is not valid"];
        return;
    }
    
    if (priceName == nil || [priceName isEqualToString:@""]) {
        [GlobalAPI showAlertView:@"Invalid Data" message:@"price is not valid"];
        return;
    }
    
    
    [CB_AlertView showAlertOnView:self.view];
    
    
    NSString* apiName = _productData == nil ? @"AddNewProduct.aspx" : @"EditBusinessProduct.aspx";
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerURL, apiName]]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:kGUID forKey:@"guid"];
    [parameters setObject:[GlobalAPI loadLoginID] forKey:@"UserID"];
    
    if (_productData != nil) { // update
        [parameters setObject:_productData[@"ID"] forKey:@"ProductID"];
    }
    
    [parameters setObject:productName forKey:@"ProductName"];
    [parameters setObject:tagline forKey:@"ProductDescription"];
    [parameters setObject:priceName forKey:@"OrigionalPrice"];

//    NSLog(@"selectedSubCateogories = %@", arrayCategory[selectedIndexCategory][@"SubCategoryID"]);
//    [parameters setObject:arrayCategory[selectedIndexCategory][@"SubCategoryID"] forKey:@"SelectedSubCategories"];
    
    NSString * strCategories = @"";
    int count = 0;
    for (NSIndexPath * obj in arraySelectedIndexCategory) {
        if (count == 0)
            strCategories = arrayCategory[obj.row][@"SubCategoryID"];
        else
            strCategories = [NSString stringWithFormat:@"%@, %@", strCategories, arrayCategory[obj.row][@"SubCategoryID"]];
        count ++;
    }
    
    [parameters setObject:strCategories forKey:@"SelectedSubCategories"];


    NSString *imageData = [GlobalAPI base64StringForImage:productImageView.image];
    if (imageData) {
//        NSLog(@"imageData = %@", imageData);
        [parameters setObject:imageData forKey:@"ProductPhoto"];
    }
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSLog(@"param = %@", parameters);
    
    AFHTTPRequestOperation *op = [manager POST:@"" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            [CB_AlertView hideAlert];
            
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"response = %@", responseString);

            NSDictionary *responseJson = [responseString JSONValue];
            
            if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Success!"
                                                                      message:responseJson[@"Message"]
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil, nil];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        if (buttonIndex == 0) { // OK
                            dispatch_async(dispatch_get_main_queue(),^{
                                [self.navigationController popViewControllerAnimated:YES];
                            });
                        }
                    }];
                }];
                [alertView show];
                
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

            
            
        
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [CB_AlertView hideAlert];
    }];
    [op start];
    
}


- (void) getCategories
{
    if (arrayCategory == NULL) {
        [CB_AlertView showAlertOnView:self.view];
        
        NSString *requestUrl = [[NSString stringWithFormat:@"%@/GetSubcategoriesForMaincategory.aspx?guid=%@&UserID=%@",
                                 kServerURL,
                                 kGUID,
                                 [GlobalAPI loadLoginID]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"request = %@", requestUrl);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:requestUrl
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 [CB_AlertView hideAlert];
                 
                 NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 NSDictionary *responseJson = [responseString JSONValue];
                 
                 NSLog(@"json data = %@", responseJson);
                 
                 if (responseJson != nil && [responseJson[@"Success"] isEqualToString:@"Success"]) {
                     
                     arrayCategory = [[NSMutableArray alloc] initWithArray:responseJson[@"Data"]];
                     
                     if (_productData != nil) {
                         
                         NSArray *chunks = [_productData[@"CategoryIds"] componentsSeparatedByString: @","];
                         if (chunks != nil && chunks.count > 0) {
                             for (NSString * str in chunks) {
                                 NSInteger index = [self getIndexOfCategory:[str intValue]];
                                 if (index != -1) {
                                     [arraySelectedIndexCategory addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                                 }
                             }
                         }
                         
                         NSString * strCategory = @"";
                         
                         int count = 0;
                         for (NSIndexPath *obj in arraySelectedIndexCategory) {
                             if (count == 0)
                                 strCategory = arrayCategory[obj.row][@"SubcategoryName"];
                             else {
                                 strCategory = [NSString stringWithFormat:@"%@, %@", strCategory, arrayCategory[obj.row][@"SubcategoryName"]];
                             }
                             
                             count  ++;
                         }
                         
                         categoryField.text = strCategory;
                         
//                         int index = 0;
//                         for (NSDictionary * dic in arrayCategory) {
//                             NSString * subCategoryID = [dic[@"SubCategoryID"] stringValue];
//                             
//                             if ([subCategoryID isEqualToString:_productData[@"CategoryIds"]]) {
//                                 selectedIndexCategory = index;
//                                 
//                                 categoryField.text = arrayCategory[selectedIndexCategory][@"SubcategoryName"];
//                                 break;
//                             }
//                             
//                             index ++;
//                         }
                     }
                 }

             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [CB_AlertView hideAlert];
             }];
    }
}

- (NSInteger) getIndexOfCategory: (NSInteger) categoryID {
    NSInteger count = 0;
    for (NSDictionary * dic in arrayCategory) {
        NSInteger SubCategoryID = [dic[@"SubCategoryID"] integerValue];
        if (SubCategoryID == categoryID) {
            return count;
        }
        count ++;
    }
    return -1;
}

- (void)showPicker {

    [self.view removeGestureRecognizer:tapGesture];

    Dropobj = [[DropDownListView alloc] initWithTitle:@"Select Category" options:arrayCategory indexData:arraySelectedIndexCategory key:@"SubcategoryName" xy:CGPointMake(50, 60) size:CGSizeMake(220, 300) isMultiple:YES];
    Dropobj.delegate = self;
    [Dropobj showInView:self.view animated:YES];

    m_isShowPicker = YES;
    
/*
    if (m_isShowPicker) {
        return;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         constraintBottomPicker.constant = 0;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = YES;
                         [mPickerView reloadAllComponents];
                         
                         
                         if (selectedIndexCategory == -1) {
                             selectedIndexCategory = 0;
                         }
                         
                         if (selectedIndexCategory != -1 && arrayCategory.count>0) {
                             
                             categoryField.text = arrayCategory[selectedIndexCategory][@"SubcategoryName"];
                             
                             [mPickerView selectRow:selectedIndexCategory inComponent:0 animated:YES];
                         }
                     }];
*/
}
- (void)hidePicker {
    
    [self.view addGestureRecognizer:tapGesture];
    
    [Dropobj fadeOut];
    
/*
    if (!m_isShowPicker) {
        return;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         constraintBottomPicker.constant = -180;
                     }
                     completion:^(BOOL finished){
                         m_isShowPicker = NO;
                     }];
*/
}

- (void)DropDownListView:(DropDownListView *)dropdownListView indexlist:(NSMutableArray *)indexData {

    arraySelectedIndexCategory = [indexData mutableCopy];
    
    NSString * strCategory = @"";
    
    int count = 0;
    for (NSIndexPath *obj in arraySelectedIndexCategory) {
        if (count == 0)
            strCategory = arrayCategory[obj.row][@"SubcategoryName"];
        else {
            strCategory = [NSString stringWithFormat:@"%@, %@", strCategory, arrayCategory[obj.row][@"SubcategoryName"]];
        }
        
        count  ++;
    }
    
    categoryField.text = strCategory;
    

    [self.view addGestureRecognizer:tapGesture];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([touch.view isKindOfClass:[UIView class]]) {
        [Dropobj fadeOut];
    }
}

#pragma mark -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
    
    if ([textField isEqual:categoryField]) {
        
        [super listSubviewsOfView:self.view];
        
        
        shouldEdit = NO;
        
        [self showPicker];
    }
    else {
        
        [self hidePicker];
    }
    
    return shouldEdit;
}

#pragma mark - ShoppingPicker View Delegate & DataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component
{
    if (arrayCategory == NULL) {
        return 0;
    }
    return arrayCategory.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString * title = arrayCategory[row][@"SubcategoryName"];
    return title;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    selectedIndexCategory = (int)row;
//    categoryField.text = arrayCategory[row][@"SubcategoryName"];
}

#pragma mark keyboard
- (void) hideKeyboard :(UIGestureRecognizer*) gesture{
    [super hideKeyboard:gesture];
    
    if (m_isShowPicker) {
        [self hidePicker];
    }
    
}

@end
