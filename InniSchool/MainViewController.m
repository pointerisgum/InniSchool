//
//  MainViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 28..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "MainViewController.h"
#import "PopUpViewController.h"
#import "StudyDetailViewController.h"
#import "NotiView.h"
#import "MainLibView.h"
#import "MainWikiView.h"
#import "MainTubeView.h"
#import "MainTubeItem.h"
#import "GlobalSearchViewController.h"

@interface MainViewController () <UISearchBarDelegate>
@property (nonatomic, assign) NSInteger nLastView;
@property (nonatomic, strong) NotiView *v_NotiView;
@property (nonatomic, strong) MainLibView *v_MainLibView;
@property (nonatomic, strong) MainTubeView *v_MainTubeView;
@property (nonatomic, strong) MainWikiView *v_MainWikiView;
@property (nonatomic, strong) NSMutableArray *arM_TopStudyList;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIView *v_LastObj;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Top;
@property (nonatomic, weak) IBOutlet UIPageControl *pgc;
@property (nonatomic, weak) IBOutlet UIView *v_Container;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bar;
@property (nonatomic, weak) IBOutlet UIButton *btn_Noti;
@property (nonatomic, weak) IBOutlet UIButton *btn_Lib;
@property (nonatomic, weak) IBOutlet UIButton *btn_GreenTube;
@property (nonatomic, weak) IBOutlet UIButton *btn_GreenWiki;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nLastView = 0;
    self.screenName = @"메인";
    
    //팝업을 띄워야 하면 띄운다
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mypage/selectInniDiaryImage.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSDictionary *dic = [resulte objectForKey:@"InniDiaryImageInfo"];
                                            
                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                            if( str_ImageUrl && str_ImageUrl.length > 0 )
                                            {
                                                [self performSelector:@selector(showPopUpIfNeeded:) withObject:str_ImageUrl afterDelay:0.0f];
                                            }
                                        }
                                    }];

    
    [self addNotiView];
    
//    [self addLibView];
//    
//    [self addGreenTubeView];
//    
//    [self addGreenWikiView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self initNavi];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self updateTopImage];
    
//    switch (self.nLastView)
//    {
//        case 1:
//            [self addLibView];
//            break;
//
//        case 2:
//            [self addGreenTubeView];
//            break;
//
//        case 3:
//            [self addGreenWikiView];
//            break;
//
//        default:
//            [self addNotiView];
//            break;
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.sv_Main.contentSize = CGSizeMake(0, self.v_LastObj.frame.origin.y + self.v_LastObj.frame.size.height);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    lb_Title.text = @"이니스쿨";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    

    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
//    self.view.backgroundColor = naviTintColor;
    
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItemWithWhiteColor:YES];
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
        GlobalSearchViewController *vc = [[GlobalSearchViewController alloc]initWithNibName:@"GlobalSearchViewController" bundle:nil];
        vc.str_Keyword = self.searchBar.text;
        
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];

        [self presentViewController:navi animated:YES completion:nil];
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showPopUpIfNeeded:(NSString *)aUrl
{
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    
    NSString *str_CuTime = [NSString stringWithFormat:@"%04ld%02ld%02ld", nYear, nMonth, nDay];
    long long llCurTime = [str_CuTime longLongValue];
    
    long long llPopupTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"popUpTime"] longLongValue];
    if( llCurTime > llPopupTime )
    {
        PopUpViewController *vc = [[PopUpViewController alloc]initWithNibName:@"PopUpViewController" bundle:nil];
        vc.str_Url = aUrl;
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}

- (void)removeAllView:(UIView *)parentView
{
    for( UIView *view in parentView.subviews )
    {
        [view removeFromSuperview];
    }
}

- (void)addNotiView
{
    //http://127.0.0.1:7080/api/board/selectNoticeList.do?comBraRIdx=10001&userIdx=1004&startRowNum=1&endRowNum=3
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1" forKey:@"startRowNum"];
    [dicM_Params setObject:@"4" forKey:@"endRowNum"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"board/selectNoticeList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            [self removeAllView:self.v_Container];

                                            NSInteger nMax = 4;
                                            NSArray *ar = [resulte objectForKey:@"ContentList"];
                                            if( ar.count < nMax )
                                            {
                                                nMax = ar.count;
                                            }
                                            
                                            NSMutableArray *arM_List = [NSMutableArray arrayWithCapacity:nMax];
                                            for( NSInteger i = 0; i < nMax; i++ )
                                            {
                                                [arM_List addObject:ar[i]];
                                            }
                                            
                                            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"NotiView" owner:self options:nil];
                                            self.v_NotiView = [topLevelObjects objectAtIndex:0];
                                            self.v_NotiView.vc_Parent = self;
                                            self.v_NotiView.ar_List = [NSArray arrayWithArray:arM_List];
                                            [self.v_Container addSubview:self.v_NotiView];
                                            
                                            [self.v_NotiView updateNotiView];
                                            
                                            self.nLastView = 0;
                                        }
                                    }];
}

- (void)addLibView
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"2" forKey:@"pageType"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
//    [dicM_Params setObject:@"0" forKey:@"archivingYN"];
    [dicM_Params setObject:@"1" forKey:@"startRowNum"];
    [dicM_Params setObject:@"6" forKey:@"endRowNum"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            [self removeAllView:self.v_Container];
                                            
                                            NSInteger nMax = 3;
                                            NSArray *ar = [resulte objectForKey:@"IntegrationCourseList"];
                                            if( ar.count < nMax )
                                            {
                                                nMax = ar.count;
                                            }
                                            
                                            NSMutableArray *arM_List = [NSMutableArray arrayWithCapacity:nMax];
                                            for( NSInteger i = 0; i < nMax; i++ )
                                            {
                                                [arM_List addObject:ar[i]];
                                            }
                                            
                                            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"MainLibView" owner:self options:nil];
                                            self.v_MainLibView = [topLevelObjects objectAtIndex:0];
                                            self.v_MainLibView.vc_Parent = self;
                                            self.v_MainLibView.ar_List = [NSArray arrayWithArray:arM_List];
                                            [self.v_Container addSubview:self.v_MainLibView];
                                            
                                            [self.v_MainLibView updateNotiView];
                                            
                                            self.nLastView = 1;
                                        }
                                    }];
}

- (void)addGreenTubeView
{
    //http://127.0.0.1:7080/api/sns/selectSnsList.do?userIdx=1004&comBraRIdx=10001&searchType=0&startRowNum=1&endRowNum=20
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1" forKey:@"startRowNum"];
    [dicM_Params setObject:@"6" forKey:@"endRowNum"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            [self removeAllView:self.v_Container];
                                            
                                            NSInteger nMax = 6;
                                            NSArray *ar = [resulte objectForKey:@"SNSList"];
                                            if( ar.count < nMax )
                                            {
                                                nMax = ar.count;
                                            }
                                            
                                            NSMutableArray *arM_List = [NSMutableArray arrayWithCapacity:nMax];
                                            for( NSInteger i = 0; i < nMax; i++ )
                                            {
                                                [arM_List addObject:ar[i]];
                                            }
                                            
                                            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"MainTubeView" owner:self options:nil];
                                            self.v_MainTubeView = [topLevelObjects objectAtIndex:0];
                                            self.v_MainTubeView.vc_Parent = self;
                                            self.v_MainTubeView.ar_List = [NSArray arrayWithArray:arM_List];
                                            [self.v_Container addSubview:self.v_MainTubeView];
                                            
                                            [self.v_MainTubeView updateNotiView];
                                            
                                            self.nLastView = 2;
                                        }
                                    }];
}

- (void)addGreenWikiView
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
    [dicM_Params setObject:@"1" forKey:@"startRowNum"];
    [dicM_Params setObject:@"4" forKey:@"endRowNum"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/selectSurveyList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            [self removeAllView:self.v_Container];
                                            
                                            NSInteger nMax = 4;
                                            NSArray *ar = [resulte objectForKey:@"SurveyList"];
                                            if( ar.count < nMax )
                                            {
                                                nMax = ar.count;
                                            }
                                            
                                            NSMutableArray *arM_List = [NSMutableArray arrayWithCapacity:nMax];
                                            for( NSInteger i = 0; i < nMax; i++ )
                                            {
                                                [arM_List addObject:ar[i]];
                                            }
                                            
                                            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"MainWikiView" owner:self options:nil];
                                            self.v_MainWikiView = [topLevelObjects objectAtIndex:0];
                                            self.v_MainWikiView.vc_Parent = self;
                                            self.v_MainWikiView.ar_List = [NSArray arrayWithArray:arM_List];
                                            [self.v_Container addSubview:self.v_MainWikiView];
                                            
                                            [self.v_MainWikiView updateNotiView];
                                            
                                            self.nLastView = 3;
                                        }
                                    }];
}

- (void)updateTopImage
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1" forKey:@"pageType"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
    [dicM_Params setObject:@"0" forKey:@"archivingYN"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nMaxCnt = 4;
                                            NSArray *ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
                                            if( ar_List.count < nMaxCnt )
                                            {
                                                nMaxCnt = ar_List.count;
                                            }
                                            
                                            self.arM_TopStudyList = [NSMutableArray arrayWithCapacity:nMaxCnt];
                                            for( NSInteger i = 0; i < nMaxCnt; i++ )
                                            {
                                                [self.arM_TopStudyList addObject:ar_List[i]];
                                            }
                                            
                                            //이미지 등록
                                            [self addTopThumbnail];
                                        }
                                    }];

}

- (void)addTopThumbnail
{
    for( UIView *subView in self.sv_Top.subviews )
    {
        if( subView.tag > 0 )
        {
            [subView removeFromSuperview];
        }
    }
    
    for( NSInteger i = 0; i < self.arM_TopStudyList.count; i++ )
    {
        NSDictionary *dic = self.arM_TopStudyList[i];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i * self.sv_Top.frame.size.width, 0, self.sv_Top.frame.size.width, self.sv_Top.frame.size.height)];
        view.tag = i + 1;
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        iv.tag = i;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        iv.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [iv addGestureRecognizer:singleTap];
        
        NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
        [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
        
        [view addSubview:iv];
        
        [self.sv_Top addSubview:view];
    }
    
    self.sv_Top.contentSize = CGSizeMake(self.sv_Top.frame.size.width * self.arM_TopStudyList.count, 0);
    self.pgc.numberOfPages = self.arM_TopStudyList.count;
    self.pgc.currentPage = 0;
}





#pragma mark - UIGesture
- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView *)gestureRecognizer.view;

    NSDictionary *dic = self.arM_TopStudyList[view.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StudyDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"StudyDetailViewController"];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView == self.sv_Top )
    {
        NSInteger nPage = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.pgc.currentPage = nPage;
    }
}



#pragma mark - IBAction
- (IBAction)goMenuToggel:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if( btn.selected )
    {
        return;
    }
    
    self.btn_Noti.selected = self.btn_Lib.selected = self.btn_GreenTube.selected = self.btn_GreenWiki.selected = NO;
    
    btn.selected = YES;
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                        
                         self.iv_Bar.center = CGPointMake(btn.center.x, self.iv_Bar.center.y);
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    if( self.btn_Noti.selected )
    {
        [self addNotiView];
    }
    else if( self.btn_Lib.selected )
    {
        [self addLibView];
    }
    else if( self.btn_GreenTube.selected )
    {
        [self addGreenTubeView];
    }
    else if( self.btn_GreenWiki.selected )
    {
        [self addGreenWikiView];
    }
}

- (IBAction)goTogether:(id)sender
{
    UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"TogetherNavi"];
    [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
}

- (IBAction)goAsking:(id)sender
{
    UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"AskingNavi"];
    [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
}

- (IBAction)goMyPage:(id)sender
{
    UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPageNavi"];
    [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
}

- (IBAction)goSetting:(id)sender
{
    UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingNavi"];
    [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
}

- (IBAction)goMoreView:(id)sender
{
    UINavigationController *navi = nil;
    if( self.btn_Noti.selected )
    {
        navi = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiNavi"];
    }
    else if( self.btn_Lib.selected )
    {
        navi = [self.storyboard instantiateViewControllerWithIdentifier:@"StudyLibNavi"];
    }
    else if( self.btn_GreenTube.selected )
    {
        navi = [self.storyboard instantiateViewControllerWithIdentifier:@"GreenTubeNavi"];
    }
    else if( self.btn_GreenWiki.selected )
    {
        navi = [self.storyboard instantiateViewControllerWithIdentifier:@"WikiNavi"];
    }
    else
    {
        return;
    }
    
    [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
}

@end
