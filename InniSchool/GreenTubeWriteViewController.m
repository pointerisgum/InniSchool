//
//  GreenTubeWriteViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 10..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GreenTubeWriteViewController.h"
#import "UIPlaceHolderTextView.h"
#import "IQActionSheetPickerView.h"
#import "AddTagViewController.h"
#import "BSImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "VoteWriteViewController.h"


static const NSInteger kMaxImageCnt = 3;

@interface GreenTubeWriteViewController () <IQActionSheetPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSMutableArray *arM_VideoData;
@property (nonatomic, strong) NSMutableArray *arM_Photo;
@property (nonatomic, strong) NSArray *ar_Category;
@property (nonatomic, strong) NSArray *ar_TagList;
@property (nonatomic, strong) NSMutableDictionary *dic_SelectCategory;
@property (nonatomic, strong) NSDictionary *dic_VoteInfo;
@property (nonatomic, strong) BSImagePickerController *imagePicker;
@property (nonatomic, strong) NSArray *ar_SubCategory;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIButton *btn_Category;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *tv_Contents;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tag;
@property (nonatomic, weak) IBOutlet UIView *v_Image;
@property (nonatomic, weak) IBOutlet UIView *v_Acc;
@property (nonatomic, weak) IBOutlet UIButton *btn_Photo;
@property (nonatomic, weak) IBOutlet UIButton *btn_Video;
@property (nonatomic, weak) IBOutlet UIButton *btn_Poll;
@property (nonatomic, weak) IBOutlet UIView *v_LastObj;
@property (nonatomic, weak) IBOutlet UIView *v_VoteItem;
@property (nonatomic, weak) IBOutlet UILabel *lb_VoteTitle;
@end

@implementation GreenTubeWriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"그린튜브 글쓰기";
    
    if( self.writeMode == kImage )
    {
        self.btn_Photo.selected = YES;
    }
    else if( self.writeMode == kText )
    {
        self.btn_Photo.selected = NO;
    }
    else if( self.writeMode == kMovie )
    {
        self.btn_Video.selected = YES;
    }
    else if( self.writeMode == kVote )
    {
        self.btn_Poll.selected = YES;
    }

    self.arM_Photo = [NSMutableArray array];
    self.arM_VideoData = [NSMutableArray array];
    
    self.btn_Category.layer.cornerRadius = 5.0f;
    self.btn_Category.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Category.layer.borderWidth = 0.5f;
    
    self.tv_Contents.layer.cornerRadius = 5.0f;
    self.tv_Contents.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tv_Contents.layer.borderWidth = 0.5f;
    
    self.tv_Contents.placeholder = @"글을 작성해 주세요.";
    
    self.sv_Main.contentSize = CGSizeMake(0, self.sv_Main.frame.size.height);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(svTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.sv_Main addGestureRecognizer:singleTap];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiTagList:)
                                                 name:@"notiTagList"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiVoteUpdate:)
                                                 name:@"notiVoteUpdate"
                                               object:nil];
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

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.view.userInteractionEnabled = YES;
    
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
     
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        if( IS_3_5Inch )
        {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, 80, 0.0);
        }
        else
        {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        }
        
    }
    else
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.sv_Main.contentInset = contentInsets;
        self.sv_Main.scrollIndicatorInsets = contentInsets;
        
//        self.v_Acc.frame = CGRectMake(self.v_Acc.frame.origin.x, self.v_Acc.frame.origin.y - keyboardSize.height,
//                                          self.v_Acc.frame.size.width, self.v_Acc.frame.size.height);
        
        
        
        
        
        
        static CGFloat fY = 0.0f;
        
        self.v_Acc.frame = CGRectMake(self.v_Acc.frame.origin.x, fY > 0 ? fY : self.v_Acc.frame.origin.y - keyboardSize.height,
                                          self.v_Acc.frame.size.width, self.v_Acc.frame.size.height);
        
        if( fY == 0.0f )
        {
            fY = self.v_Acc.frame.origin.y;
        }
        
        
        
        
        
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.sv_Main.contentInset = UIEdgeInsetsZero;
        self.sv_Main.scrollIndicatorInsets = UIEdgeInsetsZero;
        
        self.v_Acc.frame = CGRectMake(self.v_Acc.frame.origin.x, self.view.frame.size.height - self.v_Acc.frame.size.height,
                                          self.v_Acc.frame.size.width, self.v_Acc.frame.size.height);
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //integrationCourseIdx
    
    //    if( [segue.identifier isEqualToString:@"Detail"] )
    //    {
    //        NSIndexPath *indexPath = (NSIndexPath *)sender;
    //        NSDictionary *dic = nil;
    //        if( self.viewMode == kFeed )
    //        {
    //            dic = self.arM_FeedList[indexPath.section];
    //        }
    //        else
    //        {
    //            dic = self.arM_ArchiveList[indexPath.section];
    //        }
    //
    //        StudyDetailViewController *vc = [segue destinationViewController];
    //        vc.dic_Info = dic;
    //    }
}


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
    //http://127.0.0.1:7080/api/sns/insertSnsPost.do?
    //comBraRIdx=10001
    //userIdx=1004
    //contentType=1002
    //cateCodeIdx=1000
    //snsContent=이미지 등록 테스트
    
    if( self.dic_SelectCategory == nil )
    {
        ALERT_ONE(@"카테고리를 선택해 주세요");
        return;
    }
    
    if( self.tv_Contents.text.length <= 0 )
    {
        ALERT_ONE(@"내용을 입력해 주세요");
        return;
    }
    
    BOOL isAskingCategory = [self.btn_Category.titleLabel.text isEqualToString:@"문의사항"];
    if( isAskingCategory )
    {
//        NSInteger nCategoryIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCodeIdx"] integerValue];
//
//        if( nCategoryIdx == 4000 )
//        {
//            ALERT_ONE(@"하위 카테고리를 선택해 주세요");
//            return;
//        }
        ALERT_ONE(@"하위 카테고리를 선택해 주세요");
        return;
    }
    
    if( self.arM_VideoData.count > 0 )
    {
        [self sendVideoContentsToServer];
    }
    else if( self.dic_VoteInfo )
    {
        [self sendVoteToServer];
    }
    else
    {
        [self sendImageOrTextContentsToServer];
    }
}

- (void)sendVoteToServer
{
    self.navigationController.view.userInteractionEnabled = NO;

    NSString *str_ShowCode = @"";
    NSString *str_IsOnly = [self.dic_VoteInfo objectForKey_YM:@"isOnly"];
    if( [str_IsOnly isEqualToString:@"Y"] )
    {
        str_ShowCode = @"505";
    }
    else
    {
        str_ShowCode = @"504";
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1004" forKey:@"contentType"];
    [dicM_Params setObject:self.tv_Contents.text forKey:@"snsContent"];
    [dicM_Params setObject:[self.dic_VoteInfo objectForKey_YM:@"title"] forKey:@"title"];
    [dicM_Params setObject:str_ShowCode forKey:@"resultViewYN"];
    
    NSInteger nCategoryIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCodeIdx"] integerValue];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCategoryIdx] forKey:@"cateCodeIdx"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsPost.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {

                                        [self.view endEditing:YES];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                {
                                                    NSInteger nFeedIdx = [[resulte objectForKey_YM:@"SNSFeedIdx"] integerValue];
                                                    NSString *str_FeedIdx = [NSString stringWithFormat:@"%ld", nFeedIdx];
                                                    [self sendVoteDataToServer:str_FeedIdx];
                                                    [self sendTagToServer:str_FeedIdx];
                                                    
                                                    [self dismissViewControllerAnimated:YES completion:^{
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadSnsFeed" object:nil userInfo:nil];
                                                        self.navigationController.view.userInteractionEnabled = YES;
                                                    }];
                                                }
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                        }
                                        
                                        self.navigationController.view.userInteractionEnabled = YES;
                                    }];

}

- (void)sendVoteDataToServer:(NSString *)str_FeedIdx
{
    //http://127.0.0.1:7080/api/sns/insertSnsPollContent.do
    //comBraRIdx=10001
    //userIdx=1004
    //snsFeedIdx=13
    //pollContent=김치찌개
    //pollNum=1

    self.navigationController.view.userInteractionEnabled = NO;
    
    NSArray *ar_VoteList = [self.dic_VoteInfo objectForKey:@"list"];
    for( NSInteger i = 0; i < ar_VoteList.count; i++ )
    {
        NSString *str_Item = ar_VoteList[i];
        NSString *str_Number = [NSString stringWithFormat:@"%ld", i + 1];
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
        [dicM_Params setObject:str_FeedIdx forKey:@"snsFeedIdx"];
        [dicM_Params setObject:str_Item forKey:@"pollContent"];
        [dicM_Params setObject:str_Number forKey:@"pollNum"];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsPollContent.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [self.view endEditing:YES];
                                            
                                            if( resulte )
                                            {
                                                
                                            }
                                            
                                            self.navigationController.view.userInteractionEnabled = YES;
                                        }];

    }
}

- (void)sendVideoContentsToServer
{
    self.navigationController.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1003" forKey:@"contentType"];
    [dicM_Params setObject:self.tv_Contents.text forKey:@"snsContent"];
    
    NSInteger nCategoryIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCodeIdx"] integerValue];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCategoryIdx] forKey:@"cateCodeIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsPost.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [self.view endEditing:YES];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                {
                                                    NSInteger nFeedIdx = [[resulte objectForKey_YM:@"SNSFeedIdx"] integerValue];
                                                    NSString *str_FeedIdx = [NSString stringWithFormat:@"%ld", nFeedIdx];
                                                    [self sendVideoFileToServer:str_FeedIdx];
                                                    [self sendTagToServer:str_FeedIdx];
                                                    
                                                    [self dismissViewControllerAnimated:YES completion:^{
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadSnsFeed" object:nil userInfo:nil];
                                                        self.navigationController.view.userInteractionEnabled = YES;
                                                    }];
                                                }
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                        }
                                        
                                        self.navigationController.view.userInteractionEnabled = YES;
                                    }];
    
    
    
    
    
    
    
    
    
//    fileKey
}

- (void)sendVideoFileToServer:(NSString *)str_FeedIdx
{
    self.navigationController.view.userInteractionEnabled = NO;
    
    //http://127.0.0.1:7080/api/sns/insertSnsImageContents.do?comBraRIdx=10001&userIdx=1004&snsFeedIdx=14&attachType=1002&attachSort=1
    [GMDCircleLoader show];
    
    [[WebAPI sharedData] fileUpload:@""
                              param:nil
                        withFileUrl:self.videoUrl
                          withBlock:^(id resulte, NSError *error) {
                              
                              [GMDCircleLoader hide];
                              
                              if( resulte )
                              {
                                  NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                                  [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
                                  [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
                                  [dicM_Params setObject:str_FeedIdx forKey:@"snsFeedIdx"];
                                  [dicM_Params setObject:@"N" forKey:@"onlyDeleteYN"];
                                  [dicM_Params setObject:resulte forKey:@"fileKey"];
                                  
                                  [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsVideoContents.do"
                                                                      param:dicM_Params
                                                                  withBlock:^(id resulte, NSError *error) {
                                                                      
                                                                      [self.view endEditing:YES];

                                                                      [GMDCircleLoader hide];

                                                                      if( resulte )
                                                                      {
                                                                          NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                                          switch (nCode)
                                                                          {
                                                                              case 1:
                                                                              {
                                                                                  UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                                                  [window makeToast:@"동영상 업로드 성공하였습니다\n인코딩 과정이 끝난 후 확인하실 수 있습니다"];
                                                                              }
                                                                                  break;
                                                                                  
                                                                              default:
                                                                                  ALERT_ONE(@"동영상 업로드 실패");
                                                                                  break;
                                                                          }
                                                                      }
                                                                  }];
                              }
                              
                              self.navigationController.view.userInteractionEnabled = YES;
                          }];
}

- (void)sendImageOrTextContentsToServer
{
    if( self.arM_Photo.count > 0 )
    {
        NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@");
        
        //2015.07.21 새로 추가된 API
        //이미지가 있을 경우 이미지와 텍스트를 한번에 올린다

        self.navigationController.view.userInteractionEnabled = NO;
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
        [dicM_Params setObject:self.tv_Contents.text forKey:@"snsContent"];
        NSInteger nCategoryIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCodeIdx"] integerValue];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCategoryIdx] forKey:@"cateCodeIdx"];
        
        NSMutableDictionary *dicM_Image = [NSMutableDictionary dictionaryWithCapacity:self.arM_Photo.count];
        for( NSInteger i = 0; i < self.arM_Photo.count; i++ )
        {
            NSData *imageData = self.arM_Photo[i];
            NSString *str_Key = [NSString stringWithFormat:@"attachFiles%ld", i + 1];
            [dicM_Image setObject:imageData forKey:str_Key];
        }
        
        [[WebAPI sharedData] imageUpload:@"sns/insertSnsImageTypePost.do"
                                   param:dicM_Params
                              withImages:dicM_Image
                               withBlock:^(id resulte, NSError *error) {
                                   
                                   if( resulte )
                                   {
                                       NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                       NSInteger nFeedIdx = [[resulte objectForKey_YM:@"SNSFeedIdx"] integerValue];
                                       NSString *str_FeedIdx = [NSString stringWithFormat:@"%ld", nFeedIdx];
                                       
                                       switch (nCode)
                                       {
                                           case 1:
                                           {
                                               [self sendTagToServer:str_FeedIdx];
                                               
                                               [self dismissViewControllerAnimated:YES completion:^{
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadSnsFeed" object:nil userInfo:nil];
                                                   self.navigationController.view.userInteractionEnabled = YES;
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
                                   
                                   self.navigationController.view.userInteractionEnabled = YES;
                               }];
    }
    else
    {
        self.navigationController.view.userInteractionEnabled = NO;
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
        [dicM_Params setObject:@"1001" forKey:@"contentType"];
        [dicM_Params setObject:self.tv_Contents.text forKey:@"snsContent"];
        
        NSInteger nCategoryIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCodeIdx"] integerValue];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCategoryIdx] forKey:@"cateCodeIdx"];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsPost.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [self.view endEditing:YES];
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                switch (nCode)
                                                {
                                                    case 1:
                                                    {
                                                        NSInteger nFeedIdx = [[resulte objectForKey_YM:@"SNSFeedIdx"] integerValue];
                                                        NSString *str_FeedIdx = [NSString stringWithFormat:@"%ld", nFeedIdx];
                                                        if( self.arM_Photo.count > 0 )
                                                        {
                                                            [self sendImageToServer:str_FeedIdx];
                                                        }
                                                        [self sendTagToServer:str_FeedIdx];
                                                        
                                                        [self dismissViewControllerAnimated:YES completion:^{
                                                            
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadSnsFeed" object:nil userInfo:nil];
                                                            self.navigationController.view.userInteractionEnabled = YES;
                                                        }];
                                                    }
                                                        break;
                                                        
                                                    default:
                                                        [self.navigationController.view makeToast:@"오류"];
                                                        break;
                                                }
                                            }
                                            
                                            self.navigationController.view.userInteractionEnabled = YES;
                                        }];
    }
}

- (void)sendImageToServer:(NSString *)str_FeedIdx
{
    //http://127.0.0.1:7080/api/sns/insertSnsImageContents.do
    //comBraRIdx=10001
    //userIdx=1004
    //snsFeedIdx=14
    //attachType=1002
    //attachSort=1
    
    self.navigationController.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:str_FeedIdx forKey:@"snsFeedIdx"];
    [dicM_Params setObject:@"1002" forKey:@"attachType"];

    NSMutableDictionary *dicM_Image = [NSMutableDictionary dictionaryWithCapacity:self.arM_Photo.count];
    for( NSInteger i = 0; i < self.arM_Photo.count; i++ )
    {
        NSData *imageData = self.arM_Photo[i];
        NSString *str_Key = [NSString stringWithFormat:@"attachFiles%ld", i + 1];
        [dicM_Image setObject:imageData forKey:str_Key];
    }
    
    [[WebAPI sharedData] imageUpload:@"sns/insertSnsImageContents.do"
                               param:dicM_Params
                          withImages:dicM_Image
                           withBlock:^(id resulte, NSError *error) {
                               
                               if( resulte )
                               {
                                   NSDictionary *dic = [resulte objectForKey:@"ResultInfo"];
                                   NSInteger nCode = [[dic objectForKey_YM:@"ResultCode"] integerValue];
                                   switch (nCode)
                                   {
                                       case 1:
                                           ALERT_ONE(@"이미지 등록에 실패하였습니다");
                                           break;
                                           
                                       default:

                                           break;
                                   }
                               }
                               else
                               {
                                   [self.navigationController.view makeToast:@"오류"];
                               }
                               
                               self.navigationController.view.userInteractionEnabled = YES;
                           }];
}

- (void)sendTagToServer:(NSString *)str_FeedIdx
{
    //http://127.0.0.1:7080/api/sns/insertSnsTagKeyword.do?
    //snsFeedIdx=12
    //tagKeyword=자연보호

    self.navigationController.view.userInteractionEnabled = NO;
    
    for( NSInteger i = 0; i < self.ar_TagList.count; i++ )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
        [dicM_Params setObject:str_FeedIdx forKey:@"snsFeedIdx"];

        id obj = self.ar_TagList[i];
        if( [obj isKindOfClass:[NSString class]] )
        {
            NSString *str_Tag = (NSString *)obj;
            [dicM_Params setObject:str_Tag forKey:@"tagKeyword"];
        }
        else
        {
            NSDictionary *dic = (NSDictionary *)obj;
            NSInteger nTagIdx = [[dic objectForKey_YM:@"TagIdx"] integerValue];
            NSString *str_TagIdx = [NSString stringWithFormat:@"%ld", nTagIdx];
            [dicM_Params setObject:str_TagIdx forKey:@"tagIdx"];
        }
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsTagKeyword.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [self.view endEditing:YES];
                                            
                                            if( resulte )
                                            {
                                                
                                            }
                                            
                                            self.navigationController.view.userInteractionEnabled = YES;
                                        }];
    }
}

- (void)svTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}


#pragma mark - IQActionSheetPickerViewDelegate
- (void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    switch (pickerView.tag)
    {
        case 1:
        {
            for( NSInteger i = 0; i < self.ar_Category.count; i++ )
            {
                NSDictionary *dic = self.ar_Category[i];
                if( [titles[0] isEqualToString:[dic objectForKey_YM:@"CateName"]] )
                {
                    [self.btn_Category setTitle:titles[0] forState:UIControlStateNormal];
                    [self.btn_Category setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    self.dic_SelectCategory = [NSMutableDictionary dictionaryWithDictionary:dic];
                    
                    /*
                     CateCodeIdx = 4000;
                     CateCodeParentIdx = 9999011;
                     CateName = "\Ubb38\Uc758\Uc0ac\Ud56d";
                     CodeLevel = 1;
                     CodeSort = 4;
                     ComBraRIdx = 10001;
                     EditDate = "<null>";
                     EditorIdx = 999999;
                     MemoTXT = "<null>";
                     RegDate = "<null>";
                     RegUserIdx = 999999;
                     */
                    
                    if( [titles[0] isEqualToString:@"문의사항"] )
                    {
                        //http://127.0.0.1:7080/api/sns/selectSnsCategoryList.do?userIdx=1004&comBraRIdx=10001&cateCodeParentIdx=4000
                        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
                        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
                        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"CateCodeParentIdx"] integerValue]] forKey:@"cateCodeParentIdx"];
                        
                        [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsCategoryList.do"
                                                            param:dicM_Params
                                                        withBlock:^(id resulte, NSError *error) {
                                                            
                                                            if( resulte )
                                                            {
                                                                self.ar_SubCategory = [NSArray arrayWithArray:[resulte objectForKey:@"SNSCategoryList"]];
                                                                NSMutableArray *arM_ListName = [NSMutableArray arrayWithCapacity:self.ar_SubCategory.count];
                                                                for( NSInteger i = 0; i < self.ar_SubCategory.count; i++ )
                                                                {
                                                                    NSDictionary *dic = self.ar_SubCategory[i];
                                                                    [arM_ListName addObject:[dic objectForKey_YM:@"CateName"]];
                                                                }
                                                                
                                                                IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"" delegate:self];
                                                                [picker removeCancelButton];
                                                                [picker setTag:2];
                                                                [picker setTitlesForComponenets:@[arM_ListName]];
                                                                [picker show];
                                                            }
                                                        }];
                    }
                    else
                    {
                        if( [self.tv_Contents.text hasPrefix:@"1)제품명"] )
                        {
                            self.tv_Contents.text = @"";
                        }
                    }

                    break;
                }
            }
        }
            break;

        case 2:
        {
            for( NSInteger i = 0; i < self.ar_SubCategory.count; i++ )
            {
                NSDictionary *dic = self.ar_SubCategory[i];
                if( [titles[0] isEqualToString:[dic objectForKey_YM:@"CateName"]] )
                {
                    NSString *str_CateName = [NSString stringWithFormat:@"%@ > %@", self.btn_Category.titleLabel.text, titles[0]];
                    [self.btn_Category setTitle:str_CateName forState:UIControlStateNormal];
                    [self.btn_Category setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [self.dic_SelectCategory setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"CateCodeIdx"]integerValue]] forKey:@"CateCodeIdx"];
                    
                    if( [titles[0] isEqualToString:@"제품클레임 등록"] )
                    {
                        self.tv_Contents.text = @"1)제품명 : \n2)제품코드 : \n3)제조일/제조로트 : \n4)클레임현상 : \n*사진첨부";
                    }
                    else
                    {
                        if( [self.tv_Contents.text hasPrefix:@"1)제품명"] )
                        {
                            self.tv_Contents.text = @"";
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - Noti
- (void)notiVoteUpdate:(NSNotification *)noti
{
    self.dic_VoteInfo = [NSDictionary dictionaryWithDictionary:[noti object]];
    self.v_VoteItem.hidden = NO;
    self.lb_VoteTitle.text = [self.dic_VoteInfo objectForKey_YM:@"title"];
    
//    [dic objectForKey:@"title"];
//    [dic objectForKey:@"list"];
//    [dic objectForKey:@"isOnly"];
}

- (void)notiTagList:(NSNotification *)noti
{
    self.ar_TagList = [NSArray arrayWithArray:noti.object];
    [self updateTagText];
}

- (void)updateTagText
{
    if( self.ar_TagList.count > 0 )
    {
        self.btn_Tag.selected = YES;
    }
    else
    {
        self.btn_Tag.selected = NO;
    }
    
    NSMutableString *strM_Tag = [NSMutableString string];
    for( NSInteger i = 0; i < self.ar_TagList.count; i++ )
    {
        id obj = self.ar_TagList[i];
        if( [obj isKindOfClass:[NSString class]] )
        {
            NSString *str_Tag = (NSString *)obj;
            [strM_Tag appendString:[NSString stringWithFormat:@"#%@", str_Tag]];
            [strM_Tag appendString:@" "];
        }
        else
        {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *str_Tag = [dic objectForKey_YM:@"TagKeyword"];
            [strM_Tag appendString:[NSString stringWithFormat:@"#%@", str_Tag]];
            [strM_Tag appendString:@" "];
        }
    }
    
    if( [strM_Tag hasSuffix:@" "] )
    {
        [strM_Tag deleteCharactersInRange:NSMakeRange([strM_Tag length]-1, 1)];
    }
    
    self.lb_Tag.text = strM_Tag;
}


#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        self.videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        NSData *imageData = UIImageJPEGRepresentation(thumb, 0.5);
        CGImageRelease(image);
        
        [self.arM_VideoData removeAllObjects];
        [self.arM_VideoData addObject:imageData];
        [self updateVideoThumbnail];
        
        [self dismissViewControllerAnimated:YES
                                 completion:^{

                                 }];
        
    }
    else
    {
        UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSData *imageData = UIImageJPEGRepresentation(outputImage, 0.5);
        [self.arM_Photo addObject:imageData];
        [self updateImageThumbnail];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - IBAction
- (IBAction)goCategory:(id)sender
{
    //http://127.0.0.1:7080/api/sns/selectSnsCategoryList.do?userIdx=1004&comBraRIdx=10001&cateCodeParentIdx=4000
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsCategoryList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [self.view endEditing:YES];
                                        
                                        if( resulte )
                                        {
                                            /*
                                             CateCodeIdx = 1000;
                                             CateCodeParentIdx = 9999011;
                                             CateName = "\Uacf5\Uac10\Uc218\Ub2e4";
                                             CodeLevel = 1;
                                             CodeSort = 1;
                                             ComBraRIdx = 10001;
                                             EditDate = "<null>";
                                             EditorIdx = 999999;
                                             MemoTXT = "<null>";
                                             RegDate = "<null>";
                                             RegUserIdx = 999999;
                                             */
                                            
                                            self.ar_Category = [NSArray arrayWithArray:[resulte objectForKey:@"SNSCategoryList"]];
                                            NSMutableArray *arM_ListName = [NSMutableArray arrayWithCapacity:self.ar_Category.count];
                                            for( NSInteger i = 0; i < self.ar_Category.count; i++ )
                                            {
                                                NSDictionary *dic = self.ar_Category[i];
                                                [arM_ListName addObject:[dic objectForKey_YM:@"CateName"]];
                                            }
                                            
                                            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"" delegate:self];
                                            [picker setTag:1];
                                            [picker setTitlesForComponenets:@[arM_ListName]];
                                            [picker show];
                                        }
                                    }];
}

- (IBAction)goAddTag:(id)sender
{
    AddTagViewController *vc = [[AddTagViewController alloc]initWithNibName:@"AddTagViewController" bundle:nil];
    vc.ar_TagList = self.ar_TagList;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goPicture:(id)sender
{
    [self.view endEditing:YES];
    
    if( self.arM_VideoData.count > 0 || self.dic_VoteInfo )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"사진, 영상, 투표 컨텐츠는 1개의 게시글당 1종류만 업로드\n하실 수 있습니다.\n기존 업로드된 컨텐츠를 삭제 하고 새로 등록하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                self.dic_VoteInfo = nil;
                self.v_VoteItem.hidden = YES;
                
                [self.arM_Photo removeAllObjects];
                [self updateImageThumbnail];
                
                [self.arM_VideoData removeAllObjects];
                [self updateVideoThumbnail];
                
                [self showImageListView];
            }
        }];
    }
    else
    {
        if( kMaxImageCnt <= self.arM_Photo.count)
        {
            NSString *str_Msg = [NSString stringWithFormat:@"최대 %ld장의\n이미지 등록이 가능합니다", kMaxImageCnt];
            ALERT_ONE(str_Msg);
            return;
        }
        
        [self showImageListView];
    }
}

- (void)showImageListView
{
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
                                                     NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                                                     [self.arM_Photo addObject:imageData];
                                                     [self updateImageThumbnail];
                                                 }
                                             }
                                         }];
         }
     }];
}

- (void)updateImageThumbnail
{
    self.btn_Photo.selected = self.btn_Video.selected = self.btn_Poll.selected = NO;
    
    if( self.arM_Photo.count <= 0 )
    {
        self.btn_Photo.selected = NO;
    }
    else
    {
        self.btn_Photo.selected = YES;
    }
    
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

- (IBAction)goVideo:(id)sender
{
    [self.view endEditing:YES];

    if( self.arM_Photo.count > 0 || self.dic_VoteInfo)
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"사진, 영상, 투표 컨텐츠는 1개의 게시글당 1종류만 업로드\n하실 수 있습니다.\n기존 업로드된 컨텐츠를 삭제 하고 새로 등록하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {

            if( buttonIndex == 0 )
            {
                self.dic_VoteInfo = nil;
                self.v_VoteItem.hidden = YES;

                [self.arM_Photo removeAllObjects];
                [self updateImageThumbnail];
                
                [self.arM_VideoData removeAllObjects];
                [self updateVideoThumbnail];

                [self showVideoListView];
            }
        }];
    }
    else
    {
        if( self.arM_VideoData.count > 0 )
        {
            ALERT_ONE(@"최대 1개의\n동영상 등록이 가능합니다");
            return;
        }

        [self showVideoListView];
    }
}

- (void)showVideoListView
{
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc]init];
    imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    imagePickController.delegate = self;
    imagePickController.allowsEditing = NO;
    
    if(IS_IOS8_OR_ABOVE)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:imagePickController animated:YES completion:nil];
        }];
    }
    else
    {
        [self presentViewController:imagePickController animated:YES completion:nil];
    }
}

- (void)updateVideoThumbnail
{
    self.btn_Photo.selected = self.btn_Video.selected = self.btn_Poll.selected = NO;
    
    if( self.arM_VideoData.count <= 0 )
    {
        self.btn_Video.selected = NO;
    }
    else
    {
        self.btn_Video.selected = YES;
    }
    
    for( UIView *subView in self.v_Image.subviews )
    {
        if( subView.tag > 0 )
        {
            [subView removeFromSuperview];
        }
    }
    
    for( NSInteger i = 0; i < self.arM_VideoData.count; i++ )
    {
        NSData *imageData = self.arM_VideoData[i];
        UIImage *image = [UIImage imageWithData:imageData];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i * (68 + 6), 0, 68, 68)];
        view.tag = i + 1;
        view.backgroundColor = [UIColor blackColor];
        
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        iv.image = image;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        [view addSubview:iv];
        
        UIImageView *iv_Play = [[UIImageView alloc]initWithFrame:iv.frame];
        iv_Play.image = BundleImage(@"btn_play_mini.png");
        iv_Play.contentMode = UIViewContentModeCenter;
        iv_Play.clipsToBounds = YES;
        [view addSubview:iv_Play];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = iv.frame;
        btn.tag = view.tag;
        [btn addTarget:self action:@selector(onVideoDelete:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:BundleImage(@"btn_delete2_photo.png") forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
        [view addSubview:btn];
        
        [self.v_Image addSubview:view];
    }
}

- (void)onVideoDelete:(UIButton *)btn
{
    [self.arM_VideoData removeObjectAtIndex:btn.tag - 1];
    [self updateVideoThumbnail];
}

- (IBAction)goVote:(id)sender
{
    if( self.arM_VideoData.count > 0 || self.arM_Photo.count > 0 )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"사진, 영상, 투표 컨텐츠는 1개의 게시글당 1종류만 업로드\n하실 수 있습니다.\n기존 업로드된 컨텐츠를 삭제 하고 새로 등록하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                [self.arM_VideoData removeAllObjects];
                [self.arM_Photo removeAllObjects];

                for( UIView *subView in self.v_Image.subviews )
                {
                    if( subView.tag > 0 )
                    {
                        [subView removeFromSuperview];
                    }
                }

                self.btn_Photo.selected = self.btn_Video.selected = NO;
                self.btn_Poll.selected = YES;
                
                VoteWriteViewController *vc = [[VoteWriteViewController alloc]initWithNibName:@"VoteWriteViewController" bundle:nil];
                UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
                [self presentViewController:navi animated:YES completion:^{
                    
                }];
            }
        }];
    }
    else
    {
        [self.arM_VideoData removeAllObjects];
        [self.arM_Photo removeAllObjects];
        
        for( UIView *subView in self.v_Image.subviews )
        {
            if( subView.tag > 0 )
            {
                [subView removeFromSuperview];
            }
        }
        
        self.btn_Photo.selected = self.btn_Video.selected = NO;
        self.btn_Poll.selected = YES;
        
        VoteWriteViewController *vc = [[VoteWriteViewController alloc]initWithNibName:@"VoteWriteViewController" bundle:nil];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:navi animated:YES completion:^{
            
        }];
    }
}

@end
