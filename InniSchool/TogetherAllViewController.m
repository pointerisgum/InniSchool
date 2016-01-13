//
//  TogetherAllViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 18..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "TogetherAllViewController.h"
#import "TogetherListCell.h"
#import "TogetherViewController.h"

@interface TogetherAllViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation TogetherAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"우리 함께해요 전체 리스트";
    
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
    lb_Title.text = @"우리 함께해요";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/mission/selectMissionList.do?comBraRIdx=10001&userIdx=1004&searchType=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"searchType"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mission/selectMissionList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"MissionList"]];
                                            [self.tbv_List reloadData];
                                        }
                                    }];

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
    static NSString *CellIdentifier = @"TogetherListCell";
    TogetherListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    /*
     CompletedUserCnt = 1;
     CompletedYN = N;
     GetPoint = 10;
     MissionIdx = 11;
     MissionTitle = "\Ub2e4\Uac19\Uc774 \Ud48b\Uc720\Uc5b4\Ud578\Uc811";
     RN = 1;
     TodoEndDay = 20150531;
     TodoEndTime = 20;
     TodoStartDay = 20150429;
     TodoStartTime = 08;
     */

    NSDictionary *dic = self.arM_List[indexPath.section];
    
    cell.lb_Date.text = [NSString stringWithFormat:@"%@ %@:00 ~ %@ %@:00", [Util makeDate:[dic objectForKey_YM:@"TodoStartDay"]], [dic objectForKey_YM:@"TodoStartTime"],
                         [Util makeDate:[dic objectForKey_YM:@"TodoEndDay"]], [dic objectForKey_YM:@"TodoEndTime"]];
    
    [cell.btn_Point setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"GetPoint"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_PeopleCnt setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"CompletedUserCnt"] integerValue]] forState:UIControlStateNormal];

    cell.lb_Contents.text = [dic objectForKey_YM:@"MissionTitle"];
    
    //서버에 요청해야 할 사항
    if( [[dic objectForKey_YM:@"CompletedYN"] isEqualToString:@"Y"] )
    {
        //완료 미션일 시
        cell.btn_IsVote.hidden = NO;
    }
    else
    {
        //미완일시
        cell.btn_IsVote.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TogetherViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TogetherViewController"];
    vc.isSubMode = YES;
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:self.arM_List[indexPath.section]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}


@end
