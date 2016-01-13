//
//  StudyLibViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 7..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "StudyLibViewController.h"
#import "SearchResultViewController.h"
#import "ScripDetailViewController.h"
#import "StudyLibTwoDepthViewController.h"

@interface StudyLibScripCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab;
@end

@implementation StudyLibScripCell

@end


@interface StudyLibDepthCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@end

@implementation StudyLibDepthCell

@end


@interface StudyLibViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation StudyLibViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"학습 자료실";
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
    lb_Title.text = @"학습 자료실";
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
        vc.isLibSearch = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateList
{
    //http://211.232.113.65:7080/api/learn/selectProcessCodeList.do?comBraRIdx=10001&userIdx=1004&codeLevel=2&processParentIdx=1
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1" forKey:@"codeLevel"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectProcessCodeList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"ProcessCodeList"]];
                                            [self.tbv_List reloadData];
                                        }
                                    }];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.ar_List.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 )
    {
        static NSString *CellIdentifier = @"StudyLibScripCell";
        StudyLibScripCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];

        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        [cell.btn_Tab addTarget:self action:@selector(onScripTap:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"StudyLibDepthCell";
        StudyLibDepthCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];

        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }

        /*
         CodeLevel = 1;
         CodeNM = "\Uc0c1\Ud488\Uacfc\Uc815";
         ProcessCDIdx = 1;
         ProcessParentIdx = 9999002;
         */
        
        NSDictionary *dic = self.ar_List[indexPath.section - 1];
        cell.lb_Title.text = [dic objectForKey_YM:@"CodeNM"];
        
        cell.btn_Tab.tag = indexPath.section - 1;
        
        [cell.btn_Tab addTarget:self action:@selector(onDepthTap:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 5)];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0f;
}


- (void)onScripTap:(UIButton *)btn
{
    ScripDetailViewController *vc = [[ScripDetailViewController alloc]initWithNibName:@"ScripDetailViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onDepthTap:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    StudyLibTwoDepthViewController *vc = [[StudyLibTwoDepthViewController alloc]initWithNibName:@"StudyLibTwoDepthViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
