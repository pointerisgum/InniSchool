//
//  WeStudyViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 19..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "WeStudyViewController.h"
#import "ODRefreshControl.h"
#import "WeStudyCell.h"
#import "WeStudyFinishCell.h"
#import "WeStudyDetailViewController.h"
#import "WeStudySearchViewController.h"
#import "CommonEmptyView.h"

static const NSInteger snNotFinishEmptyTag = 761;
static const NSInteger snFinishEmptyTag = 762;

typedef NS_ENUM(NSUInteger, ViewMode){
    kNotFinish,
    kFinish
};

@interface WeStudyViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) ODRefreshControl *refreshControl1;
@property (nonatomic, strong) ODRefreshControl *refreshControl2;
@property (nonatomic, assign) ViewMode viewMode;
@property (nonatomic, strong) NSArray *ar_NotFinishList;
@property (nonatomic, strong) NSArray *ar_FinishList;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UITableView *tbv_NotFinishList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_FinishList;
@property (nonatomic, weak) IBOutlet UIButton *btn_NotFinish;
@property (nonatomic, weak) IBOutlet UIButton *btn_Finish;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bar;

@end

@implementation WeStudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"우리 함께해요";
    
    self.refreshControl1 = [[ODRefreshControl alloc] initInScrollView:self.tbv_NotFinishList];
    self.refreshControl1.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl1 addTarget:self action:@selector(ingRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_NotFinishList addSubview:self.refreshControl1];
    
    self.refreshControl2 = [[ODRefreshControl alloc] initInScrollView:self.tbv_FinishList];
    self.refreshControl2.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl2 addTarget:self action:@selector(allRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_FinishList addSubview:self.refreshControl2];
    
    self.viewMode = kNotFinish;
    
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
    lb_Title.text = @"우리 공부해요";
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
        WeStudySearchViewController *vc = [[WeStudySearchViewController alloc]initWithNibName:@"WeStudySearchViewController" bundle:nil];
        vc.str_Keyword = self.searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/exam/selectExamList.do?comBraRIdx=10001&userIdx=1004&tabType=1&userIp=127.8.1.3&searchKeyword=테&startRowNum=1&endRowNum=10
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[Util getIPAddress] forKey:@"userIp"];
    
    if( self.viewMode == kNotFinish )
    {
        [dicM_Params setObject:@"1" forKey:@"tabType"];
    }
    else
    {
        [dicM_Params setObject:@"2" forKey:@"tabType"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"exam/selectExamList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        UIView *view = (UIView *)[self.tbv_NotFinishList viewWithTag:snNotFinishEmptyTag];
                                        if( view )
                                        {
                                            [view removeFromSuperview];
                                        }
                                        
                                        view = (UIView *)[self.tbv_FinishList viewWithTag:snFinishEmptyTag];
                                        if( view )
                                        {
                                            [view removeFromSuperview];
                                        }

                                        if( resulte )
                                        {
                                            if( self.viewMode == kNotFinish )
                                            {
                                                self.ar_NotFinishList = [NSArray arrayWithArray:[resulte objectForKey:@"ExamList"]];
                                                
                                                if( self.ar_NotFinishList == nil || self.ar_NotFinishList.count <= 0 )
                                                {
                                                    [self showNotFinishEmptyView];
                                                }

                                                [self.tbv_NotFinishList reloadData];
                                                [self.refreshControl1 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                            }
                                            else
                                            {
                                                self.ar_FinishList = [NSArray arrayWithArray:[resulte objectForKey:@"ExamList"]];
                                                
                                                if( self.ar_FinishList == nil || self.ar_FinishList.count <= 0 )
                                                {
                                                    [self showFinishEmptyView];
                                                }

                                                [self.tbv_FinishList reloadData];
                                                [self.refreshControl2 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                                
                                            }
                                        }
                                    }];
}

- (void)showNotFinishEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommonEmptyView" owner:self options:nil];
    CommonEmptyView *view = [topLevelObjects objectAtIndex:0];
    view.lb_Title.text = @"응시하지 않은 시험이 없습니다.";
    view.tag = snNotFinishEmptyTag;
    view.center = self.tbv_NotFinishList.center;
    [self.tbv_NotFinishList addSubview:view];
}

- (void)showFinishEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommonEmptyView" owner:self options:nil];
    CommonEmptyView *view = [topLevelObjects objectAtIndex:0];
    view.lb_Title.text = @"응시한 시험이 없습니다.";
    view.tag = snFinishEmptyTag;
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
        return self.ar_NotFinishList.count;
    }
    else
    {
        return self.ar_FinishList.count;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.viewMode == kNotFinish )
    {
        static NSString *CellIdentifier = @"WeStudyCell";
        WeStudyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        /*
         CateName = "\Uc2dc\Ud5d8\Uc9c0\Ubd84\Ub9582>\Uc2dc\Ud5d8\Uc9c0\Ubd84\Ub9582-1";
         ExamDescription = "<null>";
         ExamPaperCateCD = 3001;
         ExamPaperIdx = 2;
         ExamPaperTitle = "\Ud14c\Uc2a4\Ud2b8\Uc2dc\Ud5d8\Uc9c02";
         ExamineeCnt = 3;
         OperationEndDay = "2015.05.31";
         OperationStartDay = "2015.05.01";
         Ranking = 0;
         ResultPattern = 534;
         ResultReviewYN = Y;
         RetryYN = Y;
         ScoreSearchEndDay = "2015.06.31";
         ScoreSearchStartDay = "2015.05.30";
         TookExamYN = N;
         */
        
        NSDictionary *dic = self.ar_NotFinishList[indexPath.section];
        cell.lb_ExamCnt.text = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"ExamineeCnt"] integerValue]];
        
        [self setDefaultCellInfo:cell withInfo:dic];
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"WeStudyFinishCell";
        WeStudyFinishCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        NSDictionary *dic = self.ar_FinishList[indexPath.section];
        
        NSString *str_ResultShowYn = [dic objectForKey_YM:@"ResultReviewYN"];
        if( [str_ResultShowYn isEqualToString:@"Y"] )
        {
            //등수
            cell.lb_ExamCnt.text = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"Ranking"] integerValue]];
        }
        else
        {
            cell.lb_ExamCnt.text = @"?";
        }
        
        cell.lb_TotalExamCnt.text = [NSString stringWithFormat:@"%ld명", [[dic objectForKey_YM:@"ExamineeCnt"] integerValue]];

        [self setDefaultCellInfo:cell withInfo:dic];
        
        return cell;
    }
    
    return nil;
}

- (void)setDefaultCellInfo:(WeStudyCell *)cell withInfo:(NSDictionary *)dic
{
    cell.lb_Title.text = [dic objectForKey_YM:@"ExamPaperTitle"];
    cell.lb_Depth.text = [dic objectForKey_YM:@"CateName"];
    cell.lb_Date.text = [NSString stringWithFormat:@"시험기간 : %@ ~ %@", [dic objectForKey_YM:@"OperationStartDay"], [dic objectForKey_YM:@"OperationEndDay"]];
    
    NSMutableString *strM_Tag = [NSMutableString string];
    NSArray *ar_Tag = [dic objectForKey:@"TagList"];
    for( NSInteger i = 0; i < ar_Tag.count; i++ )
    {
        NSDictionary *dic_Tag = ar_Tag[i];
        [strM_Tag appendFormat:@"#"];
        [strM_Tag appendString:[dic_Tag objectForKey_YM:@"TagKeyword"]];
        [strM_Tag appendString:@" "];
    }
    
    if( [strM_Tag hasSuffix:@" "] )
    {
        [strM_Tag deleteCharactersInRange:NSMakeRange([strM_Tag length]-1, 1)];
    }
    
    cell.lb_Tag.text = strM_Tag;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WeStudyDetailViewController *vc = [[WeStudyDetailViewController alloc]initWithNibName:@"WeStudyDetailViewController" bundle:nil];
    
    NSDictionary *dic = nil;
    if( self.viewMode == kNotFinish )
    {
        dic = self.ar_NotFinishList[indexPath.section];
        vc.isShowResult = NO;
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"ExamPaperIdx"] integerValue]];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        dic = self.ar_FinishList[indexPath.section];
        
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"ExamPaperIdx"] integerValue]];

        NSString *str_RetryYn = [dic objectForKey_YM:@"RetryYN"];
        if( [str_RetryYn isEqualToString:@"Y"] )
        {
            //재응시가 가능하다면 재응시 여부를 묻는 얼렛창 띄우기
            UIAlertView *alert = CREATE_ALERT(nil, @"이 시험은 재응시가 가능합니다.\n재응시 하시겠습니까?", @"예", @"아니요");
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if( buttonIndex == 0 )
                {
                    vc.isShowResult = NO;
                }
                else
                {
                    vc.isShowResult = YES;
                }
                
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
        else
        {
            vc.isShowResult = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_NotFinish.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointZero;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self updateList];
                                 
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
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_Finish.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self updateList];
                                 
                             }];
        }
    }
}

@end
