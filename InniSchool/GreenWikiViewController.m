//
//  GreenWikiViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GreenWikiViewController.h"
#import "ODRefreshControl.h"
#import "WikiCell.h"
#import "WikiDetailViewController.h"
#import "WikiCommentViewController.h"
#import "WikiSearchViewController.h"
#import "CommonEmptyView.h"

static const NSInteger snIngEmptyTag = 870;
static const NSInteger snAllEmptyTag = 871;

typedef NS_ENUM(NSUInteger, ViewMode){
    kIng,
    kAll
};

@interface GreenWikiViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) ODRefreshControl *refreshControl1;
@property (nonatomic, strong) ODRefreshControl *refreshControl2;
@property (nonatomic, assign) ViewMode viewMode;
@property (nonatomic, strong) NSArray *ar_IngList;
@property (nonatomic, strong) NSArray *ar_AllList;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UITableView *tbv_IngList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_AllList;
@property (nonatomic, weak) IBOutlet UIButton *btn_Ing;
@property (nonatomic, weak) IBOutlet UIButton *btn_All;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bar;

@end

@implementation GreenWikiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"그린위키";
    
    self.refreshControl1 = [[ODRefreshControl alloc] initInScrollView:self.tbv_IngList];
    self.refreshControl1.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl1 addTarget:self action:@selector(ingRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_IngList addSubview:self.refreshControl1];
    
    self.refreshControl2 = [[ODRefreshControl alloc] initInScrollView:self.tbv_AllList];
    self.refreshControl2.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl2 addTarget:self action:@selector(allRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_AllList addSubview:self.refreshControl2];
    
    self.viewMode = kIng;

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.sv_Main addGestureRecognizer:swipeLeft];
    [self.sv_Main addGestureRecognizer:swipeRight];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self initNavi];

    if( self.viewMode == kIng )
    {
        self.sv_Main.contentOffset = CGPointZero;
    }
    else
    {
        self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
    }
    
    [self updateList];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)ingRefresh:(UIRefreshControl *)sender
{
    [self updateList];
}

- (void)allRefresh:(UIRefreshControl *)sender
{
    [self updateList];
}

- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"그린위키";
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
        WikiSearchViewController *vc = [[WikiSearchViewController alloc]initWithNibName:@"WikiSearchViewController" bundle:nil];
        vc.str_Keyword = self.searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/survey/selectSurveyList.do
    //comBraRIdx=10001
    //userIdx=1004
    //tabType=0
    //userIp=112.121.223.1
    //startRowNum=1
    //endRowNum=10
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    if( self.viewMode == kIng )
    {
        [dicM_Params setObject:@"0" forKey:@"tabType"];
    }
    else
    {
        [dicM_Params setObject:@"1" forKey:@"tabType"];
    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/selectSurveyList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {

                                        UIView *view = (UIView *)[self.tbv_IngList viewWithTag:snIngEmptyTag];
                                        if( view )
                                        {
                                            [view removeFromSuperview];
                                        }
                                        
                                        view = (UIView *)[self.tbv_AllList viewWithTag:snAllEmptyTag];
                                        if( view )
                                        {
                                            [view removeFromSuperview];
                                        }

                                        if( resulte )
                                        {
                                            if( self.viewMode == kIng )
                                            {
                                                self.ar_IngList = [NSArray arrayWithArray:[resulte objectForKey:@"SurveyList"]];

                                                if( self.ar_IngList == nil || self.ar_IngList.count <= 0 )
                                                {
                                                    [self showIngEmptyView];
                                                }

                                                [self.tbv_IngList reloadData];
                                                [self.refreshControl1 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                            }
                                            else
                                            {
                                                self.ar_AllList = [NSArray arrayWithArray:[resulte objectForKey:@"SurveyList"]];

                                                if( self.ar_AllList == nil || self.ar_AllList.count <= 0 )
                                                {
                                                    [self showAllEmptyView];
                                                }

                                                [self.tbv_AllList reloadData];
                                                [self.refreshControl2 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];

                                            }
                                        }
                                    }];
}

- (void)showIngEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommonEmptyView" owner:self options:nil];
    CommonEmptyView *view = [topLevelObjects objectAtIndex:0];
    view.lb_Title.text = @"진행중인 그린위키가 없습니다.";
    view.tag = snIngEmptyTag;
    view.center = self.tbv_IngList.center;
    [self.tbv_IngList addSubview:view];
}

- (void)showAllEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommonEmptyView" owner:self options:nil];
    CommonEmptyView *view = [topLevelObjects objectAtIndex:0];
    view.lb_Title.text = @"그린위키가 없습니다.";
    view.tag = snAllEmptyTag;
    view.center = self.tbv_IngList.center;
    [self.tbv_AllList addSubview:view];
}


#pragma mark - UIGesture
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    [self.view endEditing:YES];
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if( self.viewMode == kIng )
        {
            [self goMenuToggle:self.btn_All];
        }
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if( self.viewMode == kAll )
        {
            [self goMenuToggle:self.btn_Ing];
        }
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( self.viewMode == kIng )
    {
        return self.ar_IngList.count;
    }
    else
    {
        return self.ar_AllList.count;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WikiCell";
    WikiCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.tag = cell.btn_CommentCnt.tag = indexPath.section;

    /*
     ResponseDTEndYN = N;
     ResponseEndDate = 20150531;
     ResponseStartDate = 20150430;
     SurveyDeployIdx = 1;
     SurveyDeployUserCommentCNT = 9;
     SurveyDeployUserCommentYN = Y;
     SurveyDeployViewCNT = 0;
     SurveyPaperCDIdx = 10;
     SurveyPaperCDNM = "\Uc124\Ubb38\Uc9c0 \Ubd84\Ub9581>\Uc124\Ubb38\Uc9c0 \Ubd84\Ub9581-1";
     SurveyPaperIdx = 1;
     SurveyPaperNM = "\Ud14c\Uc2a4\Ud2b8 \Uc124\Ubb38\Uc9c01\Uc785\Ub2c8\Ub2e4.";
     */
    
    NSDictionary *dic = nil;
    if( self.viewMode == kIng )
    {
        dic = self.ar_IngList[indexPath.section];
    }
    else
    {
        dic = self.ar_AllList[indexPath.section];
    }
    
    
    //타이틀
    /*
     //타이틀
     NSString *str_Title = [dic objectForKey_YM:@"SurveyPaperNM"];
     cell.lb_Title.text = [str_Title gtm_stringByEscapingForAsciiHTML];
     
     //카테고리
     NSString *str_Category = [dic objectForKey_YM:@"SurveyPaperCDNM"];
     cell.lb_Category.text = [str_Category gtm_stringByEscapingForAsciiHTML];
     */
    
    cell.lb_Title.text = [dic objectForKey_YM:@"SurveyPaperNM"];
    
    //카테고리
    cell.lb_Category.text = [dic objectForKey_YM:@"SurveyPaperCDNM"];
    
    //응답기간
    cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~ %@", [Util makeDate:[dic objectForKey_YM:@"ResponseStartDate"]], [Util makeDate:[dic objectForKey_YM:@"ResponseEndDate"]]];
    
    //뷰카운트
    [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"SurveyDeployViewCNT"] integerValue]] forState:UIControlStateNormal];
    
    //커멘트 카운트
    [cell.btn_CommentCnt setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"SurveyDeployUserCommentCNT"] integerValue]] forState:UIControlStateNormal];
    
    //종료일 경우 타이틀 맥스값 240
    //종료가 아닐 경우 타이틀 맥스값 280
    
    //응답 기간 유무
//    CGFloat fTitleWidth = [Util getTextSize:cell.lb_Title].width + 5;
    
    cell.btn_End.layer.cornerRadius = 3.0f;
    
    if( [[dic objectForKey_YM:@"ResponseDTEndYN"] isEqualToString:@"Y"] )
    {
        //응답기간이 끝남
        //종료버튼 show
//        fTitleWidth = [Util getTextSize:cell.lb_Title].width + 5;
//        if( fTitleWidth > 240 )
//        {
//            fTitleWidth = 240.0f;
//        }
//
////        cell.btn_End.hidden = NO;
//        
//        CGRect frame = cell.btn_End.frame;
//        frame.size.width = 30.0f;
//        cell.btn_End.frame = frame;
        
        [cell.btn_End setTitle:@"종료" forState:UIControlStateNormal];
        [cell.btn_End setBackgroundColor:[UIColor colorWithHexString:@"285830"]];
    }
    else
    {
        //응답기간중
        //종료버튼 hidden
//        fTitleWidth = [Util getTextSize:cell.lb_Title].width + 5;
//        if( fTitleWidth > 230 )
//        {
//            fTitleWidth = 230.0f;
//        }

//        cell.btn_End.hidden = NO;
        
        NSString *str_ResponeYn = [dic objectForKey_YM:@"ResponseYN"];
        if( [str_ResponeYn isEqualToString:@"Y"] )
        {
//            CGRect frame = cell.btn_End.frame;
//            frame.size.width = 48.0f;
//            cell.btn_End.frame = frame;

            //응시
            [cell.btn_End setTitle:@"응시완료" forState:UIControlStateNormal];
            [cell.btn_End setBackgroundColor:[UIColor colorWithHexString:@"3BA426"]];
        }
        else
        {
//            CGRect frame = cell.btn_End.frame;
//            frame.size.width = 39.0f;
//            cell.btn_End.frame = frame;

            //미응시
            [cell.btn_End setTitle:@"미응시" forState:UIControlStateNormal];
            [cell.btn_End setBackgroundColor:[UIColor colorWithHexString:@"C78349"]];
        }
    }
    
//    CGRect frame = cell.lb_Title.frame;
//    frame.size.width = fTitleWidth;
//    cell.lb_Title.frame = frame;
//    
//    frame = cell.btn_End.frame;
//    frame.origin.x = cell.lb_Title.frame.origin.x + cell.lb_Title.frame.size.width + 5;
//    cell.btn_End.frame = frame;

    
    //설문지에 댓글을 작성했었다면
    if( [[dic objectForKey_YM:@"SurveyDeployUserCommentYN"] isEqualToString:@"Y"] )
    {
        cell.btn_CommentCnt.selected = YES;
    }
    else
    {
        cell.btn_CommentCnt.selected = NO;
    }
    
    [cell.btn_CommentCnt addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%ld", indexPath.section);
    
    NSDictionary *dic = nil;
    if( self.viewMode == kIng )
    {
        dic = self.ar_IngList[indexPath.section];
    }
    else
    {
        dic = self.ar_AllList[indexPath.section];
    }
    
    WikiDetailViewController *vc = [[WikiDetailViewController alloc]initWithNibName:@"WikiDetailViewController" bundle:nil];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyDeployIdx"] integerValue]];
    if( [[dic objectForKey_YM:@"SurveyDeployUserCommentYN"] isEqualToString:@"Y"] )
    {
        vc.isAlreadyComment = YES;
    }
    else
    {
        vc.isAlreadyComment = NO;
    }
    vc.str_ResponesYn = [dic objectForKey_YM:@"ResponseYN"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}


#pragma mark - IBAction
- (IBAction)goMenuToggle:(id)sender
{
    if( sender == self.btn_Ing )
    {
        if( self.btn_Ing.selected == NO )
        {
            self.btn_Ing.selected = YES;
            self.btn_All.selected = NO;
            self.viewMode = kIng;
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_Ing.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointZero;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self updateList];
                                 
                             }];
        }
    }
    else
    {
        if( self.btn_All.selected == NO )
        {
            self.btn_All.selected = YES;
            self.btn_Ing.selected = NO;
            self.viewMode = kAll;
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_All.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self updateList];
                                 
                             }];
        }
    }
}

- (void)onComment:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.viewMode == kIng )
    {
        dic = self.ar_IngList[btn.tag];
    }
    else
    {
        dic = self.ar_AllList[btn.tag];
    }
    
    WikiCommentViewController *vc = [[WikiCommentViewController alloc]initWithNibName:@"WikiCommentViewController" bundle:nil];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyPaperIdx"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
