//
//  SearchResultViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 6..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "SearchResultViewController.h"
#import "StudyCell.h"
#import "StudyDetailViewController.h"
#import "CommentListViewController.h"

static NSInteger snEmptyViewTag = 99;

@interface SearchResultViewController ()
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if( self.isLibSearch )
    {
        self.screenName = @"학습 자료실 검색";
    }
    else
    {
        self.screenName = @"이달의 강의 검색";
    }


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
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
    if( self.isLibSearch )
    {
        [dicM_Params setObject:@"2" forKey:@"pageType"];    //0:전체 / 1:이달의 강의 / 2:자료실
        
        if( self.str_Depth )
        {
            [dicM_Params setObject:self.str_Depth forKey:@"processCD"];
        }
    }
    else
    {
        [dicM_Params setObject:@"1" forKey:@"pageType"];    //0:전체 / 1:이달의 강의 / 2:자료실
    }
    [dicM_Params setObject:self.str_Keyword forKey:@"searchKeyword"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        UIView *view = (UIView *)[self.tbv_List viewWithTag:snEmptyViewTag];
                                        [view removeFromSuperview];

                                        if( resulte )
                                        {
                                            self.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
                                            [self.tbv_List reloadData];
                                        }
                                        
                                        if( self.ar_List == nil || self.ar_List.count <= 0 )
                                        {
                                            [self showEmpyView];
                                        }
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];
    
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
    if( [str_IsFinish isEqualToString:@"Y"] )
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];
    
//    [Common studyViewCountUp:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"IntegrationCourseIdx"] integerValue]]];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StudyDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"StudyDetailViewController"];
    vc.dic_Info = dic;
    [self.navigationController pushViewController:vc animated:YES];
    
    //    [self performSegueWithIdentifier:@"Detail" sender:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StudyCell *cell = (StudyCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dic = self.ar_List[cell.tag];
    
    NSString *str_IsFinish = [dic objectForKey_YM:@"CertificatedYN"];
    if( [str_IsFinish isEqualToString:@"Y"] )
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


- (void)onShowComment:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];

    CommentListViewController *vc = [[CommentListViewController alloc]initWithNibName:@"CommentListViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onScrip:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
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
    NSDictionary *dic = self.ar_List[btn.tag];
    
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
