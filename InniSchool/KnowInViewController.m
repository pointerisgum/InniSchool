//
//  KnowInViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 17..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "KnowInViewController.h"
#import "KnowInCell.h"
#import "KnowInModifyViewController.h"
#import "KnowInSearchViewController.h"
#import "ODRefreshControl.h"
#import "CommonEmptyView.h"

static const NSInteger kMoreListCount = 10;
static const NSInteger snEmptyTag = 871;

@interface KnowInViewController () <UISearchBarDelegate>
{
    NSInteger nStartRow;
}
@property (nonatomic, assign) NSInteger nSelectedSection;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) ODRefreshControl *refreshControl1;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation KnowInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"지식창고";
    
    nStartRow = 1;
    self.nSelectedSection = -1;
    
    self.refreshControl1 = [[ODRefreshControl alloc] initInScrollView:self.tbv_List];
    self.refreshControl1.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl1 addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_List addSubview:self.refreshControl1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadOneKnow:)
                                                 name:@"reloadOneKnow"
                                               object:nil];

    [self updateList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNavi];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)refresh:(UIRefreshControl *)sender
{
    [self.arM_List removeAllObjects];
    self.arM_List = nil;
    
    nStartRow = 1;
    
    [self updateList];
}

- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"지식창고";
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
        KnowInSearchViewController *vc = [[KnowInSearchViewController alloc]initWithNibName:@"KnowInSearchViewController" bundle:nil];
        vc.str_Keyword = self.searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/tag/selectTagList.do?comBraRIdx=10001&userIdx=1004&startRowNum=1&endRowNum=20
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nStartRow] forKey:@"startRowNum"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nStartRow + kMoreListCount] forKey:@"endRowNum"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"tag/selectTagList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        UIView *view = (UIView *)[self.tbv_List viewWithTag:snEmptyTag];
                                        if( view )
                                        {
                                            [view removeFromSuperview];
                                        }

                                        if( resulte )
                                        {
                                            if( self.arM_List == nil || self.arM_List.count <= 0 )
                                            {
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"TagList"]];
                                            }
                                            else
                                            {
                                                [self.arM_List addObjectsFromArray:[resulte objectForKey:@"TagList"]];
                                            }
                                            
                                            nStartRow = self.arM_List.count;
                                            nStartRow++;
                                            
                                            if( self.arM_List == nil || self.arM_List.count <= 0 )
                                            {
                                                [self showEmptyView];
                                            }
                                            
                                            [self.tbv_List reloadData];
                                            
                                            [self.refreshControl1 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                        }
                                    }];
}

- (void)showEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommonEmptyView" owner:self options:nil];
    CommonEmptyView *view = [topLevelObjects objectAtIndex:0];
    view.lb_Title.text = @"등록된 지식이 없습니다.";
    view.tag = snEmptyTag;
    view.center = self.tbv_List.center;
    [self.tbv_List addSubview:view];
}


#pragma mark - Noti
- (void)reloadOneKnow:(NSNotification *)noti
{
    //아이템 하나씩 가져오는 API 필요
    __block NSString *str_TagIdx = [noti object];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:str_TagIdx forKey:@"tagIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"tag/selectTagList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            if( self.nSelectedSection > -1 )
                                            {
                                                NSArray *ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"TagList"]];
                                                [self.arM_List replaceObjectAtIndex:self.nSelectedSection withObject:[ar firstObject]];
                                                [self.tbv_List reloadData];
                                            }
                                        }
                                    }];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView.contentOffset.y > scrollView.contentSize.height - self.tbv_List.frame.size.height - 20 )
    {
        [self updateList];
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arM_List.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KnowInCell";
    KnowInCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.tag = cell.btn_Modify.tag = indexPath.section;
    
    /*
     ExamCnt = 0;
     IntegrationCourseCnt = 0;
     RegDate = 20150515014436;
     SnsCnt = 1;
     TagDescription = "<null>";
     TagIdx = 68;
     TagKeyword = "\Uac00\Ub098\Ub2e4";
     */
    
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    cell.lb_Tag.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"TagKeyword"]];
    
    NSString *str_Desc = [dic objectForKey_YM:@"TagDescription"];
    cell.lb_Contents.text = [str_Desc gtm_stringByUnescapingFromHTML];
    
    [cell.btn_StudyCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"IntegrationCourseCnt"] integerValue]] forState:UIControlStateNormal];

    [cell.btn_SihumCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"ExamCnt"] integerValue]] forState:UIControlStateNormal];

    [cell.btn_MsgCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SnsCnt"] integerValue]] forState:UIControlStateNormal];

    [cell.btn_Modify addTarget:self action:@selector(onModify:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //프레임 조정
    CGRect frame = cell.lb_Tag.frame;
    frame.size.width = [Util getTextSize:cell.lb_Tag].width + 10;
    cell.lb_Tag.frame = frame;
    
    frame = cell.v_Tag.frame;
    frame.size.width = cell.lb_Tag.frame.size.width;
    cell.v_Tag.frame = frame;
    
    frame = cell.lb_Contents.frame;
    if( cell.lb_Contents.text.length <= 0 )
    {
        frame.size.height = 1.0f;
    }
    else
    {
        frame.size.height = [Util getTextSize:cell.lb_Contents].height;
    }
    cell.lb_Contents.frame = frame;
    
    frame = cell.v_Bottom.frame;
    frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 10;
    cell.v_Bottom.frame = frame;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnowInCell *cell = (KnowInCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    cell.lb_Tag.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"TagKeyword"]];
    cell.lb_Contents.text = [dic objectForKey_YM:@"TagDescription"];
    
    
    //프레임 조정
    CGRect frame = cell.lb_Tag.frame;
    frame.size.width = [Util getTextSize:cell.lb_Tag].width + 10;
    cell.lb_Tag.frame = frame;
    
    frame = cell.v_Tag.frame;
    frame.size.width = cell.lb_Tag.frame.size.width;
    cell.v_Tag.frame = frame;
    
    frame = cell.lb_Contents.frame;
    if( cell.lb_Contents.text.length <= 0 )
    {
        frame.size.height = 1.0f;
    }
    else
    {
        frame.size.height = [Util getTextSize:cell.lb_Contents].height;
    }
    cell.lb_Contents.frame = frame;
    
    frame = cell.v_Bottom.frame;
    frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 10;
    cell.v_Bottom.frame = frame;
    
    return cell.v_Bottom.frame.origin.y + cell.v_Bottom.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}


#pragma mark - IBAction
- (void)onModify:(UIButton *)btn
{
    self.nSelectedSection = btn.tag;
    
    NSDictionary *dic = self.arM_List[btn.tag];
    KnowInModifyViewController *vc = [[KnowInModifyViewController alloc]initWithNibName:@"KnowInModifyViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    
    NSLog(@"vc.str_Row : %@", vc.str_Row);
    
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

@end
