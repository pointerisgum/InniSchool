//
//  AskingWriteViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 19..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "AskingWriteViewController.h"
#import "BSImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIPlaceHolderTextView.h"
#import "IQActionSheetPickerView.h"

static const NSInteger kMaxImageCnt = 3;

@interface AskingWriteViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, IQActionSheetPickerViewDelegate>
@property (nonatomic, strong) NSArray *ar_CategoryList;
@property (nonatomic, strong) NSDictionary *dic_SelectCategory;
@property (nonatomic, strong) NSMutableArray *arM_Photo;
@property (nonatomic, strong) BSImagePickerController *imagePicker;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UITextField *tf_Category;
@property (nonatomic, weak) IBOutlet UITextField *tf_Title;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *tv_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_Secret;
@property (nonatomic, weak) IBOutlet UIButton *btn_Picture;
@property (nonatomic, weak) IBOutlet UIView *v_Image;
@end

@implementation AskingWriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sv_Main.contentSize = CGSizeMake(0, self.sv_Main.frame.size.height);
    
    self.tv_Contents.placeholder = @"글을 작성해 주세요.";
    
    [self.tf_Category setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Category.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, self.tf_Category.frame.size.height)];

    [self.tf_Title setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Title.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, self.tf_Title.frame.size.height)];

    
    self.tf_Category.layer.cornerRadius = 5.0f;
    self.tf_Category.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tf_Category.layer.borderWidth = 0.5f;

    self.tf_Title.layer.cornerRadius = 5.0f;
    self.tf_Title.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tf_Title.layer.borderWidth = 0.5f;

    self.tv_Contents.layer.cornerRadius = 5.0f;
    self.tv_Contents.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tv_Contents.layer.borderWidth = 0.5f;

    self.btn_Picture.layer.cornerRadius = 5.0f;

    self.arM_Photo = [NSMutableArray array];
    
    self.sv_Main.contentSize = CGSizeMake(0, self.v_Image.frame.origin.y + self.v_Image.frame.size.height + 20);

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(svTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.sv_Main addGestureRecognizer:singleTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self initNavi];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:rate.floatValue animations:^{
        
        self.sv_Main.frame = CGRectMake(self.sv_Main.frame.origin.x, self.sv_Main.frame.origin.y,
                                        self.sv_Main.frame.size.width, self.view.frame.size.height - keyboardSize.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{

        self.sv_Main.frame = CGRectMake(self.sv_Main.frame.origin.x, self.sv_Main.frame.origin.y,
                                        self.sv_Main.frame.size.width, self.view.frame.size.height);
    }];
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

- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"작성하기";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self leftCancelButton];
    self.navigationItem.rightBarButtonItem = [self rightDoneButton];
}

- (void)cancelButtonPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)doneButtonPress:(UIButton *)btn
{
    if( self.tf_Category.text.length <= 0 || self.dic_SelectCategory == nil )
    {
        ALERT_ONE(@"카테고리를 선택해 주세요.");
        return;
    }
    
    if( self.tf_Title.text.length <= 0 )
    {
        ALERT_ONE(@"제목을 입력해 주세요.");
        return;
    }
    
    if( self.tv_Contents.text.length <= 0 )
    {
        ALERT_ONE(@"내용을 작성해 주세요.");
        return;
    }
    
    //http://127.0.0.1:7080/api/board/insertQna.do?comBraRIdx=10001&userIdx=1004&title=문의사항 테스트&contents=문의사항 내용입니다.&cateCd=1&secretYn=Y
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
//    [dicM_Params setObject:self.str_Idx forKey:@"surveyDeployIdx"];
    [dicM_Params setObject:self.tf_Title.text forKey:@"title"];
    
    [dicM_Params setObject:self.tv_Contents.text forKey:@"contents"];
    
    NSInteger nCateIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCD"] integerValue];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCateIdx] forKey:@"cateCd"];

    [dicM_Params setObject:self.btn_Secret.selected ? @"Y" : @"N" forKey:@"secretYn"];
    
    
    NSMutableDictionary *dicM_Image = [NSMutableDictionary dictionaryWithCapacity:self.arM_Photo.count];
    for( NSInteger i = 0; i < self.arM_Photo.count; i++ )
    {
        NSData *imageData = self.arM_Photo[i];
        NSString *str_Key = [NSString stringWithFormat:@"attachFiles%ld", i + 1];
        [dicM_Image setObject:imageData forKey:str_Key];
    }
    
    [[WebAPI sharedData] imageUpload:@"board/insertQna.do"
                               param:dicM_Params
                          withImages:dicM_Image
                           withBlock:^(id resulte, NSError *error) {
                               
                               UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                               
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                   switch (nCode)
                                   {
                                       case 1:
                                       {
                                           [self dismissViewControllerAnimated:YES completion:^{
                                               [window makeToast:@"등록 되었습니다"];
                                           }];
                                       }
                                           break;
                                           
                                       default:
                                           ALERT_ONE(@"이미지 등록에 실패하였습니다");
                                           break;
                                   }
                               }
                               else
                               {
                                   [self.navigationController.view makeToast:@"오류"];
                               }
                           }];
}

- (void)svTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}

- (void)updateImageThumbnail
{
    for( UIView *subView in self.v_Image.subviews )
    {
        if( subView.tag > 0 )
        {
            [subView removeFromSuperview];
        }
    }
    
    for( NSInteger i = 0; i < self.arM_Photo.count; i++ )
    {
        NSData *imageData = self.arM_Photo[i];
        UIImage *image = [UIImage imageWithData:imageData];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i * (68 + 6), 0, 68, 68)];
        view.tag = i + 1;
        view.backgroundColor = [UIColor blackColor];
        
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        iv.image = image;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        [view addSubview:iv];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = iv.frame;
        btn.tag = view.tag;
        [btn addTarget:self action:@selector(onImageDelete:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:BundleImage(@"btn_delete2_photo.png") forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
        [view addSubview:btn];
        
        [self.v_Image addSubview:view];
    }
}

- (void)onImageDelete:(UIButton *)btn
{
    [self.arM_Photo removeObjectAtIndex:btn.tag - 1];
    [self updateImageThumbnail];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_Category )
    {
        [self.view endEditing:YES];
        
        //http://127.0.0.1:7080/api/board/selectQnaCategoryList.do?comBraRIdx=10001&userIdx=1004
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"board/selectQnaCategoryList.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                self.ar_CategoryList = [NSArray arrayWithArray:[resulte objectForKey:@"CategoryList"]];
                                                NSMutableArray *arM_Name = [NSMutableArray arrayWithCapacity:self.ar_CategoryList.count];
                                                for( NSInteger i = 0; i < self.ar_CategoryList.count; i++ )
                                                {
                                                    NSDictionary *dic = self.ar_CategoryList[i];
                                                    [arM_Name addObject:[dic objectForKey_YM:@"CateName"]];
                                                }
                                                IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"" delegate:self];
                                                [picker removeCancelButton];
                                                [picker setTag:1];
                                                [picker setTitlesForComponenets:@[arM_Name]];
                                                [picker show];
                                            }
                                        }];
        return NO;
    }
    
    return YES;
}


#pragma mark - IQActionSheetPickerViewDelegate
- (void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    switch (pickerView.tag)
    {
        case 1:
        {
            for( NSInteger i = 0; i < self.ar_CategoryList.count; i++ )
            {
                NSDictionary *dic = self.ar_CategoryList[i];
                if( [titles[0] isEqualToString:[dic objectForKey_YM:@"CateName"]] )
                {
                    self.tf_Category.text = titles[0];
                    self.dic_SelectCategory = [NSDictionary dictionaryWithDictionary:dic];
                }
            }
        }
            break;

        default:
            break;
    }
}


#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSData *imageData = UIImageJPEGRepresentation(outputImage, 1);
    [self.arM_Photo addObject:imageData];
    [self updateImageThumbnail];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - IBAction
- (IBAction)goPicture:(id)sender
{
    if( kMaxImageCnt <= self.arM_Photo.count)
    {
        NSString *str_Msg = [NSString stringWithFormat:@"최대 %ld장의\n이미지 등록이 가능합니다", kMaxImageCnt];
        ALERT_ONE(str_Msg);
        return;
    }
    
    [self.view endEditing:YES];
   
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"사진촬영", @"앨범에서 선택"]
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = YES;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 1 )
         {
             self.imagePicker = [[BSImagePickerController alloc] init];
             self.imagePicker.maximumNumberOfImages = kMaxImageCnt - self.arM_Photo.count;
             
             [self presentImagePickerController:self.imagePicker
                                       animated:YES
                                     completion:nil
                                         toggle:^(ALAsset *asset, BOOL select) {
                                             if(select)
                                             {
                                                 NSLog(@"Image selected");
                                             }
                                             else
                                             {
                                                 NSLog(@"Image deselected");
                                             }
                                         }
                                         cancel:^(NSArray *assets) {
                                             NSLog(@"User canceled...!");
                                             [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
                                         }
                                         finish:^(NSArray *assets) {
                                             NSLog(@"User finished :)!");
                                             [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
                                             
                                             for( NSInteger i = 0; i < assets.count; i++ )
                                             {
                                                 ALAsset *asset = assets[i];
                                                 
                                                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                                                 CGImageRef iref = [rep fullScreenImage];
                                                 if (iref)
                                                 {
                                                     UIImage *image = [UIImage imageWithCGImage:iref];
                                                     NSData *imageData = UIImageJPEGRepresentation(image, 1);
                                                     [self.arM_Photo addObject:imageData];
                                                     [self updateImageThumbnail];
                                                 }
                                             }
                                         }];
         }
     }];
}

- (IBAction)goSecret:(id)sender
{
    self.btn_Secret.selected = !self.btn_Secret.selected;
}

@end
