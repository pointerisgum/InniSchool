//
//  WeStudySearchViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 19..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "WeStudySearchViewController.h"
#import "WeStudyCell.h"
#import "WeStudyFinishCell.h"
#import "WeStudyDetailViewController.h"

static NSInteger snEmptyViewTag = 99;

@interface WeStudySearchViewController ()
@property (nonatomic, strong) NSMutableArray *ar_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation WeStudySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"우리 함께해요 검색";
    
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
    //http://127.0.0.1:7080/api/exam/selectExamList.do?comBraRIdx=10001&userIdx=1004&tabType=1&userIp=127.8.1.3&searchKeyword=테&startRowNum=1&endRowNum=10
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[Util getIPAddress] forKey:@"userIp"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
    [dicM_Params setObject:self.str_Keyword forKey:@"searchKeyword"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"exam/selectExamList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        UIView *view = (UIView *)[self.tbv_List viewWithTag:snEmptyViewTag];
                                        [view removeFromSuperview];
                                        
                                        [self.ar_List removeAllObjects];
                                        self.ar_List = nil;
                                        
                                        if( resulte )
                                        {
                                            self.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"ExamList"]];
                                        }
                                        
                                        if( self.ar_List == nil || self.ar_List.count <= 0 )
                                        {
                                            [self showEmpyView];
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
    NSDictionary *dic = self.ar_List[indexPath.section];
    
    //응시여부
    NSString *str_IsStartYn = [dic objectForKey_YM:@"TookExamYN"];
    
    if( [str_IsStartYn isEqualToString:@"Y"] == NO )
    {
        //미응시
        
        static NSString *CellIdentifier = @"WeStudyCell";
        WeStudyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.lb_ExamCnt.text = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"ExamineeCnt"] integerValue]];
        
        [self setDefaultCellInfo:cell withInfo:dic];
        
        return cell;
    }
    else
    {
        //응시
        static NSString *CellIdentifier = @"WeStudyFinishCell";
        WeStudyFinishCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];
    
    //응시여부
    NSString *str_IsStartYn = [dic objectForKey_YM:@"TookExamYN"];

    WeStudyDetailViewController *vc = [[WeStudyDetailViewController alloc]initWithNibName:@"WeStudyDetailViewController" bundle:nil];
    
    if( [str_IsStartYn isEqualToString:@"Y"] == NO )
    {
        vc.isShowResult = NO;
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"ExamPaperIdx"] integerValue]];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
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

@end
