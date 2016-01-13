//
//  StudyDetailViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 29..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "StudyDetailViewController.h"
#import "MoviePlayerViewController.h"
#import "CommentListViewController.h"
#import "SearchResultViewController.h"
#import "ImageStudyViewController.h"
#import "ImagePlayerViewController.h"
#import "WeStudyDetailViewController.h"

@interface StudyDetailViewController () <UISearchBarDelegate, ImagePlayerViewControllerDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSDictionary *dic_Data;
@property (nonatomic, strong) MoviePlayerViewController *vc_MoviePlayerViewController;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIButton *btn_Filsu;
@property (nonatomic, weak) IBOutlet UIButton *btn_Sihum;
@property (nonatomic, weak) IBOutlet UIButton *btn_Scrip;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Depth;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UILabel *lb_Descrip;
@property (nonatomic, weak) IBOutlet UIButton *btn_Date;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_Per;
@property (nonatomic, weak) IBOutlet UILabel *lb_Per;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Per;
@property (nonatomic, weak) IBOutlet UIButton *btn_Teacher;
@property (nonatomic, weak) IBOutlet UILabel *lb_Teacher;
@property (nonatomic, weak) IBOutlet UIButton *btn_Point;
@property (nonatomic, weak) IBOutlet UILabel *lb_Point;
@property (nonatomic, weak) IBOutlet UIButton *btn_MyScore;
@property (nonatomic, weak) IBOutlet UILabel *lb_MyScore;
@property (nonatomic, weak) IBOutlet UIButton *btn_ViewCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_CmtCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_FavCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_LikeCnt;
@property (nonatomic, weak) IBOutlet UIView *v_Cnt;
//@property (nonatomic, weak) IBOutlet UIView *v_Func;
@property (nonatomic, weak) IBOutlet UIButton *btn_Func1;
@property (nonatomic, weak) IBOutlet UIButton *btn_Func2;
@end

@implementation StudyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Common studyViewCountUp:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] integerValue]]];

    
    UIView *v_Tmp = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    v_Tmp.backgroundColor = [UIColor whiteColor];
    v_Tmp.tag = 666;
    [self.view addSubview:v_Tmp];

//    self.navigationController.view.backgroundColor = [UIColor whiteColor];
//    self.view.alpha = NO;
    
    self.screenName = @"이달의 강의 상세";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateList) name:@"ReloadStudyDetailView" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    [self initNavi];

    [self updateList];
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
    if( self.isLibMode )
    {
        lb_Title.text = @"학습 자료실";
    }
    else
    {
        lb_Title.text = @"이달의 강의";
    }
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
    self.navigationItem.rightBarButtonItem = [self rightSearchIcon];
}

//네비게이션 서치바 오버라이드
- (void)searchMenuPress:(id)sender
{
    self.searchBar = [[UISearchBar alloc]init];
    [self.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.delegate = self;
    [self performSelector:@selector(onShowKeyboard) withObject:nil afterDelay:0.1f];
    
    self.navigationItem.leftBarButtonItem = [self leftCancelButton];
    self.navigationItem.rightBarButtonItem = [self rightSearchButton];
    
    //    self.searchDisplayController.searchBar.hidden = NO;
    //    self.searchDisplayController.searchBar.showsCancelButton = YES;
    //
    //    self.searchDisplayController.searchBar.barStyle = UIBarStyleBlack;
    //    [self.searchDisplayController setActive:YES animated:YES];
}

- (void)onShowKeyboard
{
    [self.searchBar becomeFirstResponder];
}

- (void)cancelButtonPress:(id)sender
{
    //취소버튼 눌렀을때
    [self initNavi];
}

- (void)searchButtonPress:(id)sender
{
    //검색버튼 눌렀을때
    [self showSearchResultView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self showSearchResultView];
}

- (void)showSearchResultView
{
    if( self.searchBar.text.length > 0 )
    {
        SearchResultViewController *vc = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
        vc.str_Keyword = self.searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)updateList
{
    //http://211.232.113.65:7080/api/learn/selectLearningContentInfo.do?integrationCourseIdx=1&userIdx=1004&comBraRIdx=10001

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectLearningContentInfo.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.dic_Data = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"LearningContentInfo"]];
                                            
                                            //http://127.0.0.1:7080/api/learn/selectIntegrationCourseList.do?comBraRIdx=10001&userIdx=1004&tabType=0&pageType=1&processCD=1
                                            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                                            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
                                            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
                                            [dicM_Params setObject:@"0" forKey:@"pageType"];
                                            [dicM_Params setObject:@"0" forKey:@"tabType"];
                                            [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
                                            
                                            [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
                                                                                param:dicM_Params
                                                                            withBlock:^(id resulte, NSError *error) {
                                                                                
                                                                                if( resulte )
                                                                                {
                                                                                    NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
                                                                                    self.dic_Info = [NSDictionary dictionaryWithDictionary:[ar firstObject]];
                                                                                    [self updateContents];
                                                                                }
                                                                                
                                                                                UIView *v_Tmp = [self.view viewWithTag:666];
                                                                                if( v_Tmp )
                                                                                {
                                                                                    [UIView animateWithDuration:0.3f
                                                                                                     animations:^{
                                                                                                         
                                                                                                         v_Tmp.alpha = NO;

                                                                                                     } completion:^(BOOL finished) {
                                                                                                         
                                                                                                         [v_Tmp removeFromSuperview];
                                                                                                     }];
                                                                                }
                                                                                
                                                                            }];
                                        }
                                    }];
    
//    [dicM_Params removeAllObjects];
//    dicM_Params = nil;
//    
//    //http://127.0.0.1:7080/api/learn/selectIntegrationCourseList.do?comBraRIdx=10001&userIdx=1004&tabType=0&pageType=1&processCD=1
//    dicM_Params = [NSMutableDictionary dictionary];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
//    [dicM_Params setObject:@"1" forKey:@"pageType"];
//    [dicM_Params setObject:@"0" forKey:@"tabType"];
//    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
//
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
//                                        param:dicM_Params
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        if( resulte )
//                                        {
//                                            NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
//                                            self.dic_Info = [NSDictionary dictionaryWithDictionary:[ar firstObject]];
//                                            [self updateContents];
//                                        }
//                                    }];
}

- (void)updateContents
{
    /*
     ContentType = 831;
     FrameContentInfo =         {
     };
     IntegrationCourseIdx = 1;
     IntegrationCourseNM = "\Ud14c\Uc2a4\Ud2b8\Uacfc\Uc815";
     LecturerNM = "\Ubc15\Ubbfc\Uacbd";
     VODContentInfo =         {
     "FullVODURL_A" = "rtsp://video.emcast.com/streams/_definst_/8416f34a-f3ac-4081-9102-4b2d17dc9da8/2015/02/16/56c41449-73f1-4622-a047-463d8bad9a0f/25ca5bd0-c714-45c8-8c0f-30b7ad56379e.mp4";
     "FullVODURL_B" = "http://video.emcast.com:1935/streams/_definst_/8416f34a-f3ac-4081-9102-4b2d17dc9da8/2015/02/16/56c41449-73f1-4622-a047-463d8bad9a0f/25ca5bd0-c714-45c8-8c0f-30b7ad56379e.mp4/playlist.m3u8";
     IntegrationCourseIdx = 1;
     VODIdx = 1;
     VODMineType = "video/mp4";
     VODName = "sample.mp4";
     VODPath = "56c41449-73f1-4622-a047-463d8bad9a0f";
     VODProcessingTime = 10;
     VODRunningTime = 141;
     VODSize = 6828059;
     VODType = 587;
     VODURL = "56c41449-73f1-4622-a047-463d8bad9a0f";
     };
     */
    
    NSDictionary *dic = self.dic_Info;
    
    self.btn_Sihum.hidden = self.btn_Filsu.hidden = YES;

    //필수, 시험 노출 여부
    NSInteger nFilsuCode = [[dic objectForKey_YM:@"EssentialRecommendYN"] integerValue];
    if( nFilsuCode == 743 )
    {
        //필수 아이콘 노출
        self.btn_Filsu.hidden = NO;
        [self.btn_Filsu setTitle:@"필수" forState:UIControlStateNormal];
        [self.btn_Filsu setBackgroundImage:BundleImage(@"icon_box_orange.png") forState:UIControlStateNormal];
    }
    else if( nFilsuCode == 745 )
    {
        self.btn_Filsu.hidden = NO;
        [self.btn_Filsu setTitle:@"선택" forState:UIControlStateNormal];
        [self.btn_Filsu setBackgroundImage:BundleImage(@"icon_box_gray.png") forState:UIControlStateNormal];
    }
    
    NSInteger nExamCnt = [[dic objectForKey_YM:@"ExamCnt"] integerValue];
    if( nExamCnt > 0 )
    {
        //시험 아이콘 노출
        if( self.btn_Filsu.hidden == NO )
        {
            CGRect frame = self.btn_Sihum.frame;
            frame.origin.x = self.btn_Filsu.frame.origin.x + self.btn_Filsu.frame.size.width + 3;
            self.btn_Sihum.frame = frame;
        }
        else
        {
            CGRect frame = self.btn_Sihum.frame;
            frame.origin.x = self.btn_Filsu.frame.origin.x;
            self.btn_Sihum.frame = frame;
        }
        
        self.btn_Sihum.hidden = NO;
    }

    
    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"FullImgURL"]];
    [self.iv_Thumb setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"") usingCache:NO];
    
    
    //과정명
    self.lb_Title.text = [dic objectForKey_YM:@"IntegrationCourseNM"];
    
    
    //분류
    NSString *str_Depth = [dic objectForKey_YM:@"ProcessNM"];
    self.lb_Depth.text = [str_Depth gtm_stringByUnescapingFromHTML];
    
    
    //태그
    NSMutableString *strM_Tag = [NSMutableString string];
    NSArray *ar_TagList = [dic objectForKey:@"IntegrationCourseTagList"];
    for( NSInteger i = 0; i < ar_TagList.count; i++ )
    {
        /*
         IntegrationCourseIdx = 1;
         TagIdx = 4;
         TagKeyword = "\Uac15\Ubbfc\Uc815";
         */
        NSDictionary *dic_Tag = ar_TagList[i];
        [strM_Tag appendFormat:@"#"];
        [strM_Tag appendString:[dic_Tag objectForKey_YM:@"TagKeyword"]];
        [strM_Tag appendString:@" "];
    }
    
    if( [strM_Tag hasSuffix:@" "] )
    {
        [strM_Tag deleteCharactersInRange:NSMakeRange([strM_Tag length]-1, 1)];
    }
    
    self.lb_Tag.text = strM_Tag;

    
    //과정내용
    self.lb_Descrip.text = [dic objectForKey_YM:@"LearnTarget"];
    
    CGRect frame = self.lb_Descrip.frame;
    frame.size.height = [Util getTextSize:self.lb_Descrip].height;
    self.lb_Descrip.frame = frame;
    
    CGFloat fLastY = self.lb_Descrip.frame.origin.y + self.lb_Descrip.frame.size.height;
    
    
    //학습일
    self.lb_Date.text = [NSString stringWithFormat:@"%@ ~ %@", [Util makeDate:[dic objectForKey_YM:@"LearningStartDT"]], [Util makeDate:[dic objectForKey_YM:@"LearningEndDT"]]];
    
    frame = self.lb_Date.frame;
    frame.origin.y = fLastY + 15.f;
    self.lb_Date.frame = frame;
    
    frame = self.btn_Date.frame;
    frame.origin.y = self.lb_Date.frame.origin.y;
    self.btn_Date.frame = frame;
    
    fLastY = self.lb_Date.frame.origin.y + self.lb_Date.frame.size.height;
    
    //강사명
    self.lb_Teacher.text = [dic objectForKey_YM:@"LecturerNM"];

    frame = self.lb_Teacher.frame;
    frame.origin.y = fLastY + 3.f;
    self.lb_Teacher.frame = frame;
    
    frame = self.btn_Teacher.frame;
    frame.origin.y = self.lb_Teacher.frame.origin.y;
    self.btn_Teacher.frame = frame;

    if( self.lb_Teacher.text.length > 0 )
    {
        self.lb_Teacher.hidden = self.btn_Teacher.hidden = NO;
        
        fLastY = self.lb_Teacher.frame.origin.y + self.lb_Teacher.frame.size.height;
    }
    else
    {
        self.lb_Teacher.hidden = self.btn_Teacher.hidden = YES;
    }
    
    //시험점수
    self.btn_Per.hidden = self.lb_Per.hidden = self.iv_Per.hidden = YES;
    self.btn_MyScore.hidden = self.lb_MyScore.hidden = YES;
    
    NSInteger nScore = [[dic objectForKey_YM:@"UserExamScore"] integerValue];
    if( nScore > -1 )
    {
        //시험을 봤다면 시험점수 노출
        self.btn_MyScore.hidden = self.lb_MyScore.hidden =  NO;
        self.lb_MyScore.text = [NSString stringWithFormat:@"%ld점", nScore];
        
        frame = self.lb_MyScore.frame;
        frame.origin.y = fLastY + 3.f;
        self.lb_MyScore.frame = frame;
        
        frame = self.btn_MyScore.frame;
        frame.origin.y = self.lb_MyScore.frame.origin.y;
        self.btn_MyScore.frame = frame;
        
        fLastY = self.lb_MyScore.frame.origin.y + self.lb_MyScore.frame.size.height;
    }
    else
    {
        //시험을 보지 않았다면 진도율 표시
        self.btn_Per.hidden = self.lb_Per.hidden = self.iv_Per.hidden = NO;
        
        //진도율
        NSString *str_Per = [dic objectForKey_YM:@"CompleteProgressRate"];
        NSInteger nPer = [str_Per integerValue];
        if( nPer >= 0 )
        {
            if( nPer >= 100 )
            {
                str_Per = @"100";
            }

            self.lb_Per.text = [NSString stringWithFormat:@"%@%%", str_Per];
            
            CGFloat fPer = [str_Per floatValue] * 0.01;
            
            CGRect frame = self.iv_Per.frame;
            frame.origin.y = fLastY + 10.f;
            frame.size.width = 180 * fPer;
            self.iv_Per.frame = frame;
            
            self.iv_Per.layer.cornerRadius = 2.f;
            
            if( fPer > 0 )
            {
                frame = self.lb_Per.frame;
                frame.origin.x = self.iv_Per.frame.origin.x + self.iv_Per.frame.size.width + 5;
                self.lb_Per.frame = frame;
            }
            else if( fPer < 0 )
            {
                self.lb_Per.text = @"0%";
            }
        }
        else
        {
//            self.lb_Per.text = [NSString stringWithFormat:@"%@%%", str_Per];
//            
//            CGFloat fPer = [str_Per floatValue] * 0.01;
//            
//            CGRect frame = self.iv_Per.frame;
//            frame.origin.y = fLastY + 10.f;
//            frame.size.width = 180 * fPer;
//            self.iv_Per.frame = frame;
//            
//            self.iv_Per.layer.cornerRadius = 2.f;
//            
//            if( fPer > 0 )
//            {
//                frame = self.lb_Per.frame;
//                frame.origin.x = self.iv_Per.frame.origin.x + self.iv_Per.frame.size.width + 5;
//                self.lb_Per.frame = frame;
//            }
//            else if( fPer < 0 )
//            {
//                self.lb_Per.text = @"0%";
//            }
        }
        
        CGRect frame = self.lb_Per.frame;
        frame.origin.y = fLastY + 3.f;
        self.lb_Per.frame = frame;
        
        frame = self.btn_Per.frame;
        frame.origin.y = self.lb_Per.frame.origin.y;
        self.btn_Per.frame = frame;
        
        fLastY = self.lb_Per.frame.origin.y + self.lb_Per.frame.size.height;
    }
    
    
    //수료시
    //CertiGetPoint
    /*
    self.btn_Point.hidden = self.lb_Point.hidden = YES;
    
    NSInteger nPoint = [[dic objectForKey_YM:@"GetPoint"] integerValue];
    if( nPoint > 0 )
    {
        //수료시 받을 포인트가 0보다 크면 "수료시" 표시
        self.btn_Point.hidden = self.lb_Point.hidden = NO;
        self.lb_Point.text = [NSString stringWithFormat:@"%ld", nPoint];
        
        frame = self.lb_Point.frame;
        frame.origin.y = fLastY + 3.f;
        self.lb_Point.frame = frame;
        
        frame = self.btn_Point.frame;
        frame.origin.y = self.lb_Point.frame.origin.y;
        self.btn_Point.frame = frame;
        
        fLastY = self.lb_Point.frame.origin.y + self.lb_Point.frame.size.height;
    }
     */
    
    //CertiGetPoint와 ExamGetPoint 둘중 하나라도 0보다 크면 보상 아이콘이 보이고
    //CertiGetPoint가 0보다 크면 수료시 xp 표시
    //ExamGetPoint가 0보다 크면 ()안에 내용 표시
    
    //ExamGetPoint 기준 이상히 획득 포인트
    NSInteger nPoint = [[dic objectForKey_YM:@"CertiGetPoint"] integerValue];
    NSInteger nMorePoint = [[dic objectForKey_YM:@"ExamGetPoint"] integerValue];
    NSInteger nHighScore = [[dic objectForKey_YM:@"HighScore"] integerValue];

    if( nPoint <= 0 && nMorePoint <= 0 )
    {
        //수료시 미표시
        self.btn_Point.hidden = self.lb_Point.hidden = YES;
    }
    else
    {
        //수료시 표시

        self.btn_Point.hidden = self.lb_Point.hidden = NO;
        
        if( nPoint > 0 && nMorePoint > 0 )
        {
            self.lb_Point.text = [NSString stringWithFormat:@"수료시 %ldp 시험 %ld점 이상 %ldp", nPoint, nHighScore, nMorePoint];
        }
        else if( nPoint > 0 && nMorePoint <= 0 )
        {
            self.lb_Point.text = [NSString stringWithFormat:@"수료시 %ldp", nPoint];
        }
        else if( nMorePoint > 0 && nPoint <= 0 )
        {
            self.lb_Point.text = [NSString stringWithFormat:@"시험 %ld점 이상 %ldp", nHighScore, nMorePoint];
        }
        
        frame = self.lb_Point.frame;
        frame.origin.y = fLastY + 3.f;
        self.lb_Point.frame = frame;
        
        frame = self.btn_Point.frame;
        frame.origin.y = self.lb_Point.frame.origin.y;
        self.btn_Point.frame = frame;
        
        fLastY = self.lb_Point.frame.origin.y + self.lb_Point.frame.size.height;
    }

    
    
    
    if( self.isLibMode )
    {
        //학습자료실은
        //학습기간 - 진도율 - 강사명 - 보상
        
        CGFloat fTeacherY = self.btn_Teacher.frame.origin.y;
        
        CGRect frame = self.btn_Teacher.frame;
        frame.origin.y = self.btn_Per.frame.origin.y;
        self.btn_Teacher.frame = frame;
        
        frame = self.lb_Teacher.frame;
        frame.origin.y = self.btn_Per.frame.origin.y;
        self.lb_Teacher.frame = frame;
        
        
        frame = self.btn_Per.frame;
        frame.origin.y = fTeacherY;
        self.btn_Per.frame = frame;
        
        frame = self.lb_Per.frame;
        frame.origin.y = fTeacherY;
        self.lb_Per.frame = frame;
        
        self.iv_Per.center = CGPointMake(self.iv_Per.center.x, self.btn_Per.center.y);
        
        
        NSInteger nScore = [[dic objectForKey_YM:@"UserExamScore"] integerValue];
        if( nScore <= -1 )
        {
            NSString *str_Per = [dic objectForKey_YM:@"CompleteProgressRate"];
            NSInteger nPer = [str_Per integerValue];
            if( nPer <= 0 )
            {
                self.btn_Per.hidden = self.lb_Per.hidden = self.iv_Per.hidden = YES;
                fLastY -= 22.0f;
             
                //강사명을 한칸 올려준다
                CGRect frame = self.lb_Teacher.frame;
                frame.origin.y = frame.origin.y - 22.0f;
                self.lb_Teacher.frame = frame;
                
                frame = self.btn_Teacher.frame;
                frame.origin.y = frame.origin.y - 22.0f;
                self.btn_Teacher.frame = frame;
                
                //보상도 한칸 위로 올려준다
                frame = self.lb_Point.frame;
                frame.origin.y = frame.origin.y - 22.0f;
                self.lb_Point.frame = frame;
                
                frame = self.btn_Point.frame;
                frame.origin.y = frame.origin.y - 22.0f;
                self.btn_Point.frame = frame;
            }
            else
            {
                self.btn_Per.hidden = self.lb_Per.hidden = self.iv_Per.hidden = NO;
            }
        }
        else
        {
            //20151205 레이아웃 버그로 인해 수정 (박민경 과장 요청)
            frame = self.lb_MyScore.frame;
            frame.origin.y -= 20.0f;
            self.lb_MyScore.frame = frame;
            
            frame = self.btn_MyScore.frame;
            frame.origin.y = self.lb_MyScore.frame.origin.y;
            self.btn_MyScore.frame = frame;
            ////////////////////////////////////
        }
    }
    else
    {
        //이달의 강의는
        //학습기간 - 강사명 - 진도율 - 보상
    }

    
    frame = self.v_Cnt.frame;
    frame.origin.y = fLastY + 15.f;
    self.v_Cnt.frame = frame;
    
    fLastY = self.v_Cnt.frame.origin.y + self.v_Cnt.frame.size.height;

    
    
    //뷰 카운트
    [self.btn_ViewCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"ClickCnt"]] forState:UIControlStateNormal];
    
    //커맨트 카운트
    [self.btn_CmtCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"CommentCnt"]] forState:UIControlStateNormal];
    [self.btn_CmtCnt addTarget:self action:@selector(onShowComment:) forControlEvents:UIControlEventTouchUpInside];

    //스크립 카운트
    [self.btn_FavCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"ArchivingCnt"]] forState:UIControlStateNormal];
    NSString *str_FavYn = [dic objectForKey_YM:@"UserArchivingYN"];
    if( [str_FavYn isEqualToString:@"Y"] )
    {
        [self.btn_Scrip setImage:BundleImage(@"icon_scrap_s.png") forState:UIControlStateNormal];
        [self.btn_FavCnt setImage:BundleImage(@"icon_conbottom_scrap_s.png") forState:UIControlStateNormal];
    }
    else
    {
        [self.btn_Scrip setImage:BundleImage(@"icon_scrap.png") forState:UIControlStateNormal];
        [self.btn_FavCnt setImage:BundleImage(@"icon_conbottom_scrap.png") forState:UIControlStateNormal];
    }
    
    [self.btn_Scrip addTarget:self action:@selector(onScrip:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_FavCnt addTarget:self action:@selector(onScrip:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //좋아요 카운트
    [self.btn_LikeCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"FavoriteCnt"]] forState:UIControlStateNormal];
    NSString *str_LikeYn = [dic objectForKey_YM:@"UserFavoriteYN"];
    if( [str_LikeYn isEqualToString:@"Y"] )
    {
        [self.btn_LikeCnt setImage:BundleImage(@"icon_conbottom_heart_s.png") forState:UIControlStateNormal];
    }
    else
    {
        [self.btn_LikeCnt setImage:BundleImage(@"icon_conbottom_heart.png") forState:UIControlStateNormal];
    }
    
    [self.btn_LikeCnt addTarget:self action:@selector(onLike:) forControlEvents:UIControlEventTouchUpInside];

    
    //학습하기 버튼
    //learningButtonState
//    L0 : 버튼없음
//    L1 : 복습 시작하기
//    L2 : 학습 시작하기학습하기 버튼 상태
    
    self.btn_Func1.hidden = self.btn_Func2.hidden = YES;

    [self.btn_Func1 removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [self.btn_Func2 removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];

    NSString *str_Study = [dic objectForKey_YM:@"LearningButtonState"];
    if( [str_Study isEqualToString:@"L0"] )
    {
        //버튼없음
        
    }
    else if( [str_Study isEqualToString:@"L1"] )
    {
        //복습하기
        self.btn_Func1.hidden = NO;
        
        [self.btn_Func1 setTitle:@"복습 시작하기" forState:UIControlStateNormal];
        [self.btn_Func1 addTarget:self action:@selector(onReStudy:) forControlEvents:UIControlEventTouchUpInside];
        
        frame = self.btn_Func1.frame;
        frame.origin.y = fLastY + 15.f;
        self.btn_Func1.frame = frame;
        
        fLastY = self.btn_Func1.frame.origin.y + self.btn_Func1.frame.size.height;
    }
    else if( [str_Study isEqualToString:@"L2"] )
    {
        //학습하기
        self.btn_Func1.hidden = NO;
        
        [self.btn_Func1 setTitle:@"학습 시작하기" forState:UIControlStateNormal];
        [self.btn_Func1 addTarget:self action:@selector(onStudy:) forControlEvents:UIControlEventTouchUpInside];

        frame = self.btn_Func1.frame;
        frame.origin.y = fLastY + 15.f;
        self.btn_Func1.frame = frame;
        
        fLastY = self.btn_Func1.frame.origin.y + self.btn_Func1.frame.size.height;
    }

    //시험 버튼
    //examButtonState
//    E0 : 버튼없음
//    E1 : 시험 결과보기
//    E2 : 시험 응시하기시험응시 버튼 상태
    
    NSString *str_Sihum = [dic objectForKey_YM:@"ExamButtonState"];
    if( [str_Sihum isEqualToString:@"E0"] )
    {
        //버튼없음
    }
    else if( [str_Sihum isEqualToString:@"E1"] )
    {
        //시험결과보기
        self.btn_Func2.hidden = NO;
        
        [self.btn_Func2 setTitle:@"시험 결과보기" forState:UIControlStateNormal];
        [self.btn_Func2 addTarget:self action:@selector(onShowSihumResult:) forControlEvents:UIControlEventTouchUpInside];

        frame = self.btn_Func2.frame;
        frame.origin.y = fLastY + 15.f;
        self.btn_Func2.frame = frame;
        
        fLastY = self.btn_Func2.frame.origin.y + self.btn_Func2.frame.size.height;
    }
    else if( [str_Sihum isEqualToString:@"E2"] )
    {
        //시험응시하기
        self.btn_Func2.hidden = NO;
        
        [self.btn_Func2 setTitle:@"시험 응시하기" forState:UIControlStateNormal];
        [self.btn_Func2 addTarget:self action:@selector(onStartSihum:) forControlEvents:UIControlEventTouchUpInside];

        frame = self.btn_Func2.frame;
        frame.origin.y = fLastY + 15.f;
        self.btn_Func2.frame = frame;
        
        fLastY = self.btn_Func2.frame.origin.y + self.btn_Func2.frame.size.height;
    }

    
    self.sv_Main.contentSize = CGSizeMake(0, fLastY + 10);
}

- (void)onShowComment:(UIButton *)btn
{
    CommentListViewController *vc = [[CommentListViewController alloc]initWithNibName:@"CommentListViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:self.dic_Info];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onScrip:(UIButton *)btn
{
    NSDictionary *dic = self.dic_Data;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[dic objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/insertIntegrationCourseArchiving.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             0 : 스크랩 실패
                                             1 : 스크랩 성공
                                             2 : 스크랩 취소 실패
                                             3 : 스크랩 취소 성공처리결과
                                             */
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                    [self.navigationController.view makeToast:@"스크랩"];
                                                    break;
                                                    
                                                case 3:
                                                    [self.navigationController.view makeToast:@"스크랩 취소"];
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                            
                                            [self updateList];
                                        }
                                    }];
}

- (void)onLike:(UIButton *)btn
{
    NSDictionary *dic = self.dic_Data;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[dic objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/insertIntegrationCourseFavorite.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             0 : 좋아요 실패
                                             1 : 좋아요 성공
                                             2 : 좋아요 취소 실패
                                             3 : 좋아요 취소 성공처리결과
                                             */
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                    [self.navigationController.view makeToast:@"좋아요"];
                                                    break;
                                                    
                                                case 3:
                                                    [self.navigationController.view makeToast:@"좋아요 취소"];
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                            
                                            [self updateList];
                                        }
                                    }];
}

//복습하기
- (void)onReStudy:(UIButton *)btn
{
    NSInteger nContentsCode = [[self.dic_Data objectForKey_YM:@"ContentType"] integerValue];
    if( nContentsCode == 829 )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ImagePlayerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ImagePlayerViewController"];
//        vc.isStudy = YES;
        vc.dic_Info = [NSDictionary dictionaryWithDictionary:self.dic_Data];

        [self presentViewController:vc animated:YES completion:^{

        }];

    }
    else if( nContentsCode == 831 )
    {
        //동영상
        [self showMoviePlayer:NO];
    }
}

//학습하기
- (void)onStudy:(UIButton *)btn
{
    //ContentType
    //829 : 슬라이드
    //831 : 동영상
    NSInteger nContentsCode = [[self.dic_Data objectForKey_YM:@"ContentType"] integerValue];
    if( nContentsCode == 829 )
    {
        //슬라이드
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ImagePlayerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ImagePlayerViewController"];
        vc.isStudy = YES;
        vc.dic_Info = [NSDictionary dictionaryWithDictionary:self.dic_Data];
        
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
    else if( nContentsCode == 831 )
    {
        //동영상
        [self showMoviePlayer:YES];
    }
}

//시험결과보기
- (void)onShowSihumResult:(UIButton *)btn
{
    WeStudyDetailViewController *vc = [[WeStudyDetailViewController alloc]initWithNibName:@"WeStudyDetailViewController" bundle:nil];
    vc.isShowResult = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"ExamPaperIdx"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}

//시험보기
- (void)onStartSihum:(UIButton *)btn
{
    WeStudyDetailViewController *vc = [[WeStudyDetailViewController alloc]initWithNibName:@"WeStudyDetailViewController" bundle:nil];
    vc.isShowResult = NO;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"ExamPaperIdx"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - ImagePlayerViewControllerDelegate
- (void)slideFinished:(NSString *)aString
{
    
//    [self.navigationController.view makeToastActivityStopUserAction];
//    [self performSelector:@selector(onvideoFinished:) withObject:aString afterDelay:0.5f];
}


#pragma mark - Study
- (void)showMoviePlayer:(BOOL)isSave
{
    [GMDCircleLoader hide];
    
    if( [[Util getNetworkSatatus] isEqualToString:@"Wifi"] == NO )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"3G/LTE 등으로 접속시 데이터\n통화료가 발생할 수 있습니다.", @"확인", @"취소");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                [self showPlay:isSave];
            }
        }];
    }
    else
    {
        [self showPlay:isSave];
//        MoviePlayerViewController *vc = [[MoviePlayerViewController alloc]initWithContentURL:url];
//        vc.dic_InfoMap = [NSDictionary dictionaryWithDictionary:dic_InfoMap];
//        vc.dic_ContentsList = [NSDictionary dictionaryWithDictionary:dic_ContentsList];
//        vc.isStudyMode = [str_Status isEqualToString:@"B3"] ? NO : YES;
//        
//        vc.moviePlayer.repeatMode = MPMovieRepeatModeOne;
//        vc.moviePlayer.fullscreen = NO;
//        vc.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
//        vc.moviePlayer.shouldAutoplay = YES;
//        vc.moviePlayer.repeatMode = NO;
//        [vc.moviePlayer setFullscreen:YES animated:YES];
//        [vc.moviePlayer prepareToPlay];
//        
//        [self presentViewController:vc
//                           animated:YES
//                         completion:^{
//                             
//                         }];
    }
}

- (void)showPlay:(BOOL)isSave
{
    //동영상 url은
    //  LearningContentInfo > VodContentInfo > FullVODURL_I : 아이폰용 동영상 URL (절대경로)
    //이걸 참고해야 함
    //근데 아직 서버에서 안내려주고 있음
    
    NSDictionary *dic = [self.dic_Data objectForKey:@"VODContentInfo"];
    NSString *str_Url = [dic objectForKey_YM:@"FullVODURL_I"];
    NSURL *url = [NSURL URLWithString:str_Url];
    
//    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/52138005/111.mp4"];
    self.vc_MoviePlayerViewController = [[MoviePlayerViewController alloc]initWithContentURL:url];
    self.screenName = @"학습하기(동영상)";
    //                vc.dic_InfoMap = [NSDictionary dictionaryWithDictionary:dic_InfoMap];
    //                vc.dic_ContentsList = [NSDictionary dictionaryWithDictionary:dic_ContentsList];
    //                vc.isStudyMode = [str_Status isEqualToString:@"B3"] ? NO : YES;
    self.vc_MoviePlayerViewController.dic_Info = [NSDictionary dictionaryWithDictionary:self.dic_Data];
    self.vc_MoviePlayerViewController.isSave = isSave;
    if( isSave )
    {
        self.vc_MoviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
    }
    else
    {
        self.vc_MoviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    }
    self.vc_MoviePlayerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    self.vc_MoviePlayerViewController.moviePlayer.fullscreen = NO;
    self.vc_MoviePlayerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.vc_MoviePlayerViewController.moviePlayer.shouldAutoplay = YES;
    self.vc_MoviePlayerViewController.moviePlayer.repeatMode = NO;
    [self.vc_MoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
    [self.vc_MoviePlayerViewController.moviePlayer prepareToPlay];
    
    [self presentViewController:self.vc_MoviePlayerViewController
                       animated:YES
                     completion:^{
                         
                     }];
}

@end
