//
//  WikiSearchViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 17..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "WikiSearchViewController.h"
#import "WikiCell.h"
#import "WikiDetailViewController.h"
#import "WikiCommentViewController.h"

static NSInteger snEmptyViewTag = 99;

@interface WikiSearchViewController ()
@property (nonatomic, strong) NSMutableArray *ar_List;
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation WikiSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"그린위키 검색";
    
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
    //http://127.0.0.1:7080/api/survey/selectSurveyList.do?comBraRIdx=10001&userIdx=1004&tabType=0&userIp=112.121.223.1&startRowNum=1&endRowNum=10
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
    [dicM_Params setObject:self.str_Keyword forKey:@"searchKeyword"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/selectSurveyList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        UIView *view = (UIView *)[self.tbv_List viewWithTag:snEmptyViewTag];
                                        [view removeFromSuperview];
                                        
                                        [self.ar_List removeAllObjects];
                                        self.ar_List = nil;
                                        
                                        if( resulte )
                                        {
                                            self.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"SurveyList"]];
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];

    //타이틀
    cell.lb_Title.text = [dic objectForKey_YM:@"SurveyPaperNM"];
    
    //카테고리
    cell.lb_Category.text = [dic objectForKey_YM:@"SurveyPaperCDNM"];
    
    //응답기간
    cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~ %@", [dic objectForKey_YM:@"ResponseStartDate"], [dic objectForKey_YM:@"ResponseEndDate"]];
    
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];

    WikiDetailViewController *vc = [[WikiDetailViewController alloc]initWithNibName:@"WikiDetailViewController" bundle:nil];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyPaperIdx"] integerValue]];
    if( [[dic objectForKey_YM:@"SurveyDeployUserCommentYN"] isEqualToString:@"Y"] )
    {
        vc.isAlreadyComment = YES;
    }
    else
    {
        vc.isAlreadyComment = NO;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}


#pragma mark - IBAction
- (void)onComment:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];

    WikiCommentViewController *vc = [[WikiCommentViewController alloc]initWithNibName:@"WikiCommentViewController" bundle:nil];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyPaperIdx"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
