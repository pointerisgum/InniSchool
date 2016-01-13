//
//  StudyViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 28..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "StudyViewController.h"
#import "ODRefreshControl.h"
#import "StudyDetailViewController.h"
#import "CommentListViewController.h"
#import "SearchResultViewController.h"
#import "StudyCell.h"

static NSInteger snNotFinisiNodataTag = 100;
static NSInteger snFinisiNodataTag = 101;

typedef NS_ENUM(NSUInteger, ViewMode){
    kNotFinish,
    kFinish
};

//@interface StudyCell : UITableViewCell
//@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
//@property (nonatomic, weak) IBOutlet UIButton *btn_Filsu;
//@property (nonatomic, weak) IBOutlet UIButton *btn_Sihum;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Depth;
//@property (nonatomic, weak) IBOutlet UIView *v_Status;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Per;
//@property (nonatomic, weak) IBOutlet UIImageView *iv_Per;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
//@property (nonatomic, weak) IBOutlet UIButton *btn_ViewCnt;
//@property (nonatomic, weak) IBOutlet UIButton *btn_CmtCnt;
//@property (nonatomic, weak) IBOutlet UIButton *btn_FavCnt;
//@property (nonatomic, weak) IBOutlet UIButton *btn_LikeCnt;
//@end
//
//@implementation StudyCell
//- (void)awakeFromNib
//{
//    self.btn_Filsu.hidden = self.btn_Sihum.hidden = YES;
//}
//@end


@interface StudyViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) ODRefreshControl *refreshControl1;
@property (nonatomic, strong) ODRefreshControl *refreshControl2;
@property (nonatomic, assign) ViewMode viewMode;
@property (nonatomic, strong) NSMutableArray *arM_NotFinishList;
@property (nonatomic, strong) NSMutableArray *arM_FinishList;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIButton *btn_NotFinish;
@property (nonatomic, weak) IBOutlet UIButton *btn_Finish;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bar;
@property (nonatomic, weak) IBOutlet UITableView *tbv_NotFinishList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_FinishList;


//@property (nonatomic, strong) IBOutlet UISearchDisplayController *searchDisplayController;

@end

@implementation StudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     NSMutableDictionary *event =
     [[GAIDictionaryBuilder createEventWithCategory:@"UI"
     action:@"buttonPress"
     label:@"dispatch"
     value:nil] build];
     [[GAI sharedInstance].defaultTracker send:event];
     [[GAI sharedInstance] dispatch];
     */
    
    self.screenName = @"이달의 강의";
    
    self.refreshControl1 = [[ODRefreshControl alloc] initInScrollView:self.tbv_NotFinishList];
    self.refreshControl1.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl1 addTarget:self action:@selector(notFinishRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_NotFinishList addSubview:self.refreshControl1];
    
    self.refreshControl2 = [[ODRefreshControl alloc] initInScrollView:self.tbv_FinishList];
    self.refreshControl2.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl2 addTarget:self action:@selector(finishRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_FinishList addSubview:self.refreshControl2];
    
    self.viewMode = kNotFinish;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.sv_Main addGestureRecognizer:swipeLeft];
    [self.sv_Main addGestureRecognizer:swipeRight];
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

    if( self.viewMode == kNotFinish )
    {
        self.sv_Main.contentOffset = CGPointZero;
    }
    else
    {
        self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
    }
    
    [self updateList];
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
//    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//    
//    UIEdgeInsets contentInsets;
//    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
//    {
//        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
//    }
//    else
//    {
//        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
//    }
//    
//    [UIView animateWithDuration:rate.floatValue animations:^{
//        self.tbv_NotFinishList.contentInset = contentInsets;
//        self.tbv_NotFinishList.scrollIndicatorInsets = contentInsets;
//        
//        self.tbv_FinishList.contentInset = contentInsets;
//        self.tbv_FinishList.scrollIndicatorInsets = contentInsets;
//    }];
//    
//    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tbv_NotFinishList scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [self.tbv_FinishList scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//    [UIView animateWithDuration:rate.floatValue animations:^{
//        self.tbv_NotFinishList.contentInset = UIEdgeInsetsZero;
//        self.tbv_NotFinishList.scrollIndicatorInsets = UIEdgeInsetsZero;
//        
//        self.tbv_FinishList.contentInset = UIEdgeInsetsZero;
//        self.tbv_FinishList.scrollIndicatorInsets = UIEdgeInsetsZero;
//    }];
}

- (void)notFinishRefresh:(UIRefreshControl *)sender
{
    NSLog(@"refreshing");
    [self updateList];
//    [self.refreshControl1 performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
}

- (void)finishRefresh:(UIRefreshControl *)sender
{
    NSLog(@"refreshing");
    [self updateList];
//    [self.refreshControl2 performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//        if( self.viewMode == kNotFinish )
//        {
//            dic = self.arM_NotFinishList[indexPath.section];
//        }
//        else
//        {
//            dic = self.arM_FinishList[indexPath.section];
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
    lb_Title.text = @"이달의 강의";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
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
        SearchResultViewController *vc = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
        vc.str_Keyword = self.searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1" forKey:@"pageType"];    //0:전체 / 1:이달의 강의 / 2:자료실
    if( self.viewMode == kNotFinish )
    {
        //미수료
        //?comBraRIdx=10001&userIdx=1004&tabType=0&processCD=1
        //http://52.68.160.225:80/api/learn/selectIntegrationCourseList.do?comBraRIdx=10001&userIdx=1004&tabType=0&processCD=1
        //
        [dicM_Params setObject:@"1" forKey:@"tabType"];
        
//        [UIView animateWithDuration:0.3f
//                         animations:^{
//                            
//                             self.sv_Main.contentOffset = CGPointZero;
//                         }];
    }
    else
    {
        //수료
        [dicM_Params setObject:@"2" forKey:@"tabType"];

//        [UIView animateWithDuration:0.3f
//                         animations:^{
//                            
//                             self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
//                         }];
    }
    
    
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             ArchivingCnt = 0;
                                             CertificatedYN = Y;
                                             ClickCnt = 0;
                                             ComBraRIdx = 10001;
                                             CommentCnt = 1;
                                             CompleteProgressRate = 13;
                                             ContentType = 829;
                                             EssentialRecommendYN = 743;
                                             ExamButtonState = E0;
                                             ExamCnt = 0;
                                             FavoriteCnt = 0;
                                             GetPoint = "<null>";
                                             ImgURL = "/file_upload/20150424174514.jpeg";
                                             InfoMultimediaURL = "<null>";
                                             IntegrationCourseCnt = "<null>";
                                             IntegrationCourseIdx = 13;
                                             IntegrationCourseNM = "\Uacfc\Uc815!";
                                             IntegrationCourseTagList =             (
                                             );
                                             LangIdx = 0;
                                             LearnCurriculum = "\Uacfc\Uc815!~!";
                                             LearnTarget = "\Uacfc\Uc815!~!";
                                             LearningButtonState = L1;
                                             LearningDTYN = N;
                                             LearningEndDT = 20150402;
                                             LearningStartDT = 20150401;
                                             LecturerNM = "\Uae40\Uac15\Uc0ac";
                                             MinimumProgressRate = 0;
                                             MinusPoint = 14;
                                             ProcessCD = "1|$|5|$|9";
                                             ProcessCD1 = 1;
                                             ProcessCD2 = 5;
                                             ProcessCD3 = 9;
                                             ProcessCDIdx = 9;
                                             ProcessNM = "\Uc0c1\Ud488\Uacfc\Uc815>\Ub77c\Uc778\Ubcc4 \Uc0c1\Ud488>\Ube0c\Ub79c\Ub4dc\Uc2a4\Ud1a0\Ub9ac";
                                             RegDate = 20150424;
                                             RegularTestScore = 12;
                                             UserArchivingYN = N;
                                             UserExamScore = "-1";
                                             UserFavoriteYN = 0;
                                             */
                                            
                                            //엠프티 뷰 지우기
                                            UIView *view = (UIView *)[self.tbv_NotFinishList viewWithTag:snNotFinisiNodataTag];
                                            [view removeFromSuperview];

                                            view = (UIView *)[self.tbv_FinishList viewWithTag:snFinisiNodataTag];
                                            [view removeFromSuperview];
                                            /////////////////////
                                            
                                            if( self.viewMode == kNotFinish )
                                            {
                                                //미수료
                                                self.arM_NotFinishList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
                                                
                                                if( self.arM_NotFinishList == nil || self.arM_NotFinishList.count <= 0 )
                                                {
                                                    //미수료가 없을때
                                                    [self showNotFinishNodata];
                                                }
                                                
                                                [self.tbv_NotFinishList reloadData];
                                                
                                                [self.refreshControl1 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                            }
                                            else
                                            {
                                                UIView *view = (UIView *)[self.tbv_FinishList viewWithTag:snFinisiNodataTag];
                                                [view removeFromSuperview];

                                                self.arM_FinishList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
                                                
                                                if( self.arM_FinishList == nil || self.arM_FinishList.count <= 0 )
                                                {
                                                    //수료가 없을때
                                                    [self showFinishNodata];
                                                }

                                                [self.tbv_FinishList reloadData];
                                                
                                                [self.refreshControl2 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                            }
                                        }
                                    }];
}

- (void)showNotFinishNodata
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"NotFinishNodata" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snNotFinisiNodataTag;
    view.center = self.tbv_NotFinishList.center;
    [self.tbv_NotFinishList addSubview:view];
}

- (void)showFinishNodata
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FinishNodata" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snFinisiNodataTag;
    view.center = self.tbv_NotFinishList.center;
    [self.tbv_FinishList addSubview:view];
}


#pragma mark - UIGesture
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    [self.view endEditing:YES];
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if( self.viewMode == kNotFinish )
        {
            [self goMenuToggle:self.btn_Finish];
        }
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if( self.viewMode == kFinish )
        {
            [self goMenuToggle:self.btn_NotFinish];
        }
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( self.viewMode == kNotFinish )
    {
        return self.arM_NotFinishList.count;
    }
    else
    {
        return self.arM_FinishList.count;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StudyCell";
    StudyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 5.0f;

    NSDictionary *dic = nil;
    if( self.viewMode == kNotFinish )
    {
        dic = self.arM_NotFinishList[indexPath.section];
    }
    else
    {
        dic = self.arM_FinishList[indexPath.section];
    }
    
    cell.btn_Sihum.hidden = cell.btn_Filsu.hidden = YES;

    //필수, 시험 노출 여부
    NSInteger nFilsuCode = [[dic objectForKey_YM:@"EssentialRecommendYN"] integerValue];
    if( nFilsuCode == 743 )
    {
        //필수 아이콘 노출
        cell.btn_Filsu.hidden = NO;
        [cell.btn_Filsu setTitle:@"필수" forState:UIControlStateNormal];
        [cell.btn_Filsu setBackgroundImage:BundleImage(@"icon_box_orange.png") forState:UIControlStateNormal];
    }
    else if( nFilsuCode == 745 )
    {
        cell.btn_Filsu.hidden = NO;
        [cell.btn_Filsu setTitle:@"선택" forState:UIControlStateNormal];
        [cell.btn_Filsu setBackgroundImage:BundleImage(@"icon_box_gray.png") forState:UIControlStateNormal];
    }
    
    NSInteger nExamCnt = [[dic objectForKey_YM:@"ExamCnt"] integerValue];
    if( nExamCnt > 0 )
    {
        //시험 아이콘 노출
        if( cell.btn_Filsu.hidden == NO )
        {
            CGRect frame = cell.btn_Sihum.frame;
            frame.origin.x = cell.btn_Filsu.frame.origin.x + cell.btn_Filsu.frame.size.width + 3;
            cell.btn_Sihum.frame = frame;
        }
        else
        {
            CGRect frame = cell.btn_Sihum.frame;
            frame.origin.x = cell.btn_Filsu.frame.origin.x;
            cell.btn_Sihum.frame = frame;
        }
        
        cell.btn_Sihum.hidden = NO;
    }
    
    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"FullImgURL"]];
    [cell.iv_Thumb setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"") usingCache:NO];
    
    //과정명
    cell.lb_Title.text = [dic objectForKey_YM:@"IntegrationCourseNM"];
    
    //분류
    NSString *str_Depth = [dic objectForKey_YM:@"ProcessNM"];
    cell.lb_Depth.text = [str_Depth gtm_stringByUnescapingFromHTML];

    NSString *str_IsFinish = [dic objectForKey_YM:@"CertificatedYN"];
//    if( [str_IsFinish isEqualToString:@"Y"] )
    if( 1 ) //수료여부와 상관없이 다 보여달라고 요청 옴(5월27일 박민경 과장)
    {
        //수료면
        cell.v_Per.hidden = NO;
        
        //학습일
        cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~ %@", [Util makeDate:[dic objectForKey_YM:@"LearningStartDT"]], [Util makeDate:[dic objectForKey_YM:@"LearningEndDT"]]];
        
        //진도율
        NSString *str_Per = [dic objectForKey_YM:@"CompleteProgressRate"];
        NSInteger nPer = [str_Per integerValue];
        if( nPer >= 0 )
        {
            if( nPer >= 100 )
            {
                str_Per = @"100";
            }
            
            cell.lb_Per.text = [NSString stringWithFormat:@"%@%%", str_Per];
            
            CGFloat fPer = [str_Per floatValue] * 0.01;
            
            CGRect frame = cell.iv_Per.frame;
            frame.size.width = 180 * fPer;
            cell.iv_Per.frame = frame;
            
            cell.iv_Per.layer.cornerRadius = 2.f;
            
            if( fPer > 0 )
            {
                frame = cell.lb_Per.frame;
                frame.origin.x = cell.iv_Per.frame.origin.x + cell.iv_Per.frame.size.width + 5;
                cell.lb_Per.frame = frame;
            }
            else if( fPer < 0 )
            {
                cell.lb_Per.text = @"0%";
            }
        }
        
        CGRect frame = cell.v_Status.frame;
        frame.origin.y = 145.0f;
        cell.v_Status.frame = frame;
    }
    else
    {
        //미수료면
        cell.v_Per.hidden = YES;

        CGRect frame = cell.v_Status.frame;
        frame.origin.y = cell.v_Per.frame.origin.y;
        cell.v_Status.frame = frame;
    }
    
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

    cell.lb_Tag.text = strM_Tag;
    
    cell.tag = cell.btn_CmtCnt.tag = cell.btn_FavCnt.tag = cell.btn_LikeCnt.tag = indexPath.section;
    
    //뷰 카운트
    [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"ClickCnt"]] forState:UIControlStateNormal];
    
    //커맨트 카운트
    [cell.btn_CmtCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"CommentCnt"]] forState:UIControlStateNormal];
    [cell.btn_CmtCnt addTarget:self action:@selector(onShowComment:) forControlEvents:UIControlEventTouchUpInside];
    
    //스크립 카운트
    [cell.btn_FavCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"ArchivingCnt"]] forState:UIControlStateNormal];
    NSString *str_FavYn = [dic objectForKey_YM:@"UserArchivingYN"];
    if( [str_FavYn isEqualToString:@"Y"] )
    {
        [cell.btn_FavCnt setImage:BundleImage(@"icon_conbottom_scrap_s.png") forState:UIControlStateNormal];
    }
    else
    {
        [cell.btn_FavCnt setImage:BundleImage(@"icon_conbottom_scrap.png") forState:UIControlStateNormal];
    }
    
    [cell.btn_FavCnt addTarget:self action:@selector(onScrip:) forControlEvents:UIControlEventTouchUpInside];

    
    //좋아요 카운트
    [cell.btn_LikeCnt setTitle:[NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"FavoriteCnt"]] forState:UIControlStateNormal];
    //이건 서버 수정전까지 막아둠 왜냐면 YN인데 0,1로 주고 있음
    NSString *str_LikeYn = [dic objectForKey_YM:@"UserFavoriteYN"];
    if( [str_LikeYn isEqualToString:@"Y"] )
    {
        [cell.btn_LikeCnt setImage:BundleImage(@"icon_conbottom_heart_s.png") forState:UIControlStateNormal];
    }
    else
    {
        [cell.btn_LikeCnt setImage:BundleImage(@"icon_conbottom_heart.png") forState:UIControlStateNormal];
    }
    
    [cell.btn_LikeCnt addTarget:self action:@selector(onLike:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = nil;
    if( self.viewMode == kNotFinish )
    {
        dic = self.arM_NotFinishList[indexPath.section];
    }
    else
    {
        dic = self.arM_FinishList[indexPath.section];
    }

    StudyDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StudyDetailViewController"];
    vc.dic_Info = dic;
    [self.navigationController pushViewController:vc animated:YES];
    
    
    //integrationCourseIdx
//    [self performSegueWithIdentifier:@"Detail" sender:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StudyCell *cell = (StudyCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dic = nil;
    if( self.viewMode == kNotFinish )
    {
        dic = self.arM_NotFinishList[cell.tag];
    }
    else
    {
        dic = self.arM_FinishList[cell.tag];
    }
    
    NSString *str_IsFinish = [dic objectForKey_YM:@"CertificatedYN"];
//    if( [str_IsFinish isEqualToString:@"Y"] )
    if( 1 ) //수료여부와 상관없이 다 보여달라고 요청 옴(5월27일 박민경 과장)
    {
        //수료면
        return 210;
    }
    else
    {
        //미수료면
        return 210 - 47;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}


#pragma mark - IBAction
- (IBAction)goMenuToggle:(id)sender
{
    if( sender == self.btn_NotFinish )
    {
        if( self.btn_NotFinish.selected == NO )
        {
            self.btn_NotFinish.selected = YES;
            self.btn_Finish.selected = NO;
            self.viewMode = kNotFinish;
            [self updateList];
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                
                                 self.iv_Bar.center = CGPointMake(self.btn_NotFinish.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointZero;
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
    }
    else
    {
        if( self.btn_Finish.selected == NO )
        {
            self.btn_Finish.selected = YES;
            self.btn_NotFinish.selected = NO;
            self.viewMode = kFinish;
            [self updateList];
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_Finish.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
    }
}

- (void)onShowComment:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.viewMode == kNotFinish )
    {
        dic = self.arM_NotFinishList[btn.tag];
    }
    else
    {
        dic = self.arM_FinishList[btn.tag];
    }

    CommentListViewController *vc = [[CommentListViewController alloc]initWithNibName:@"CommentListViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onScrip:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.viewMode == kNotFinish )
    {
        dic = self.arM_NotFinishList[btn.tag];
    }
    else
    {
        dic = self.arM_FinishList[btn.tag];
    }
    
    //http://52.68.160.225:80/api/learn/insertIntegrationCourseArchiving.do?integrationCourseIdx=1&userIdx=1004

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
    NSDictionary *dic = nil;
    if( self.viewMode == kNotFinish )
    {
        dic = self.arM_NotFinishList[btn.tag];
    }
    else
    {
        dic = self.arM_FinishList[btn.tag];
    }

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

@end
