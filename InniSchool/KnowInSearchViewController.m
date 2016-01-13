//
//  KnowInSearchViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 17..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "KnowInSearchViewController.h"
#import "KnowInCell.h"
#import "KnowInModifyViewController.h"

static NSInteger snEmptyViewTag = 99;

@interface KnowInSearchViewController ()
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation KnowInSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"지식창고 검색";
    
    [self initNavi];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    lb_Title.text = @"검색 결과";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
}


- (void)updateList
{
    //http://127.0.0.1:7080/api/tag/selectTagList.do?comBraRIdx=10001&userIdx=1004&startRowNum=1&endRowNum=20
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1" forKey:@"startRowNum"];
    [dicM_Params setObject:@"100" forKey:@"endRowNum"];
    [dicM_Params setObject:self.str_Keyword forKey:@"searchKeyword"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"tag/selectTagList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"TagList"]];
                                            
                                            if( self.ar_List == nil || self.ar_List.count <= 0 )
                                            {
                                                [self showEmpyView];
                                            }
                                        }
                                        
                                        [self.tbv_List reloadData];
                                    }];
}

- (void)showEmpyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"StudySearchEmpty" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snEmptyViewTag;
    view.center = self.tbv_List.center;
    [self.tbv_List addSubview:view];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.ar_List.count;
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];
    
    cell.lb_Tag.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"TagKeyword"]];
    
    NSString *str_Desc = [dic objectForKey_YM:@"TagDescription"];
    cell.lb_Contents.text = [str_Desc gtm_stringByUnescapingFromHTML];

    [cell.btn_StudyCnt setTitle:[NSString stringWithFormat:@"  %ld", [[dic objectForKey_YM:@"IntegrationCourseCnt"] integerValue]] forState:UIControlStateNormal];
    
    [cell.btn_SihumCnt setTitle:[NSString stringWithFormat:@"  %ld", [[dic objectForKey_YM:@"ExamCnt"] integerValue]] forState:UIControlStateNormal];
    
    [cell.btn_MsgCnt setTitle:[NSString stringWithFormat:@"  %ld", [[dic objectForKey_YM:@"SnsCnt"] integerValue]] forState:UIControlStateNormal];
    
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];
    
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
    NSDictionary *dic = self.ar_List[btn.tag];
    KnowInModifyViewController *vc = [[KnowInModifyViewController alloc]initWithNibName:@"KnowInModifyViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    vc.str_Row = [NSString stringWithFormat:@"%ld", btn.tag + 1];
    
    NSLog(@"vc.str_Row : %@", vc.str_Row);
    
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

@end
