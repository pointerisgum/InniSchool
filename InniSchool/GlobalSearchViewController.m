//
//  GlobalSearchViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 26..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GlobalSearchViewController.h"
#import "StudyCell.h"
#import "GlobalStudySearchCell.h"
#import "GlobalKnowSearchCell.h"
#import "GlobalSearchHeaderCell.h"
#import "StudyDetailViewController.h"
#import "GlobalSearchEmptyCell.h"
#import "KnowInModifyViewController.h"

@interface GlobalSearchViewController ()
{
    BOOL isStudyEmpty;
    BOOL isLibEmpty;
    BOOL isKnowEmpty;
}
@property (nonatomic, strong) NSArray *ar_StudyList;
@property (nonatomic, strong) NSArray *ar_LibList;
@property (nonatomic, strong) NSArray *ar_KnowList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation GlobalSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"통합 검색";
    
    [self initNavi];
    
    [self updateList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadOneKnow:)
                                                 name:@"reloadOneKnow"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    lb_Title.text = @"통합검색결과";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
//    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
    self.navigationItem.rightBarButtonItem = [self rightCloseButton];

}

- (void)closeButtonPress:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateList
{
    [self updateStudy];
    [self updateLib];
    [self updateKnow];
}

- (void)updateStudy
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
    [dicM_Params setObject:@"1" forKey:@"pageType"];    //0:전체 / 1:이달의 강의 / 2:자료실
    [dicM_Params setObject:self.str_Keyword forKey:@"searchKeyword"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        isStudyEmpty = NO;
                                        
                                        if( resulte )
                                        {
                                            self.ar_StudyList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
                                        }
                                        
                                        if( self.ar_StudyList == nil || self.ar_StudyList.count <= 0 )
                                        {
                                            isStudyEmpty = YES;
                                        }
                                        
                                        [self.tbv_List reloadData];
                                    }];
}

- (void)updateLib
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"tabType"];
    [dicM_Params setObject:@"2" forKey:@"pageType"];    //0:전체 / 1:이달의 강의 / 2:자료실
    [dicM_Params setObject:self.str_Keyword forKey:@"searchKeyword"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        isLibEmpty = NO;
                                        
                                        if( resulte )
                                        {
                                            self.ar_LibList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseList"]];
                                        }
                                        
                                        if( self.ar_LibList == nil || self.ar_LibList.count <= 0 )
                                        {
                                            isLibEmpty = YES;
                                        }
                                        
                                        [self.tbv_List reloadData];
                                    }];
}

- (void)updateKnow
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
                                        
                                        isKnowEmpty = NO;
                                        
                                        if( resulte )
                                        {
                                            self.ar_KnowList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"TagList"]];
                                        }
                                        
                                        if( self.ar_KnowList == nil || self.ar_KnowList.count <= 0 )
                                        {
                                            isKnowEmpty = YES;
                                        }

                                        [self.tbv_List reloadData];
                                    }];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //지식창고 숨기는 요청으로 인해 리턴을 2로 바꿈 기존엔 3이였음
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            if( isStudyEmpty )
            {
                return 1;
            }
            else
            {
                return self.ar_StudyList.count;
            }

        case 1:
            if( isLibEmpty )
            {
                return 1;
            }
            else
            {
                return self.ar_LibList.count;
            }

        case 2:
            if( isKnowEmpty )
            {
                return 1;
            }
            else
            {
                return self.ar_KnowList.count;
            }

        default:
            return 0;
            break;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 || indexPath.section == 1 )
    {
        if( indexPath.section == 0 && isStudyEmpty )
        {
            static NSString *CellIdentifier = @"GlobalSearchEmptyCell";
            GlobalSearchEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }

            cell.iv_Icon.image = BundleImage(@"icon_guide_013.png");
            
            return cell;
        }

        if( indexPath.section == 1 && isLibEmpty )
        {
            static NSString *CellIdentifier = @"GlobalSearchEmptyCell";
            GlobalSearchEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.iv_Icon.image = BundleImage(@"icon_guide_014.png");
            
            return cell;
        }

        static NSString *CellIdentifier = @"GlobalStudySearchCell";
        GlobalStudySearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        NSDictionary *dic = nil;
        if( indexPath.section == 0 )
        {
            dic = self.ar_StudyList[indexPath.row];
        }
        else
        {
            dic = self.ar_LibList[indexPath.row];
        }
        
        
//        cell.backgroundColor = [UIColor clearColor];
//        cell.contentView.backgroundColor = [UIColor whiteColor];
//        cell.contentView.layer.cornerRadius = 5.0f;
        
//        cell.v_Status.hidden = YES;

        
        CGRect frame = cell.contentView.frame;
        frame.size.height = cell.iv_Thumb.frame.origin.y + cell.iv_Thumb.frame.size.height + 7;
        frame = cell.contentView.frame;
        
        
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
        
        return cell;
    }
    else
    {
        if( indexPath.section == 2 && isKnowEmpty )
        {
            static NSString *CellIdentifier = @"GlobalSearchEmptyCell";
            GlobalSearchEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.iv_Icon.image = BundleImage(@"icon_guide_015.png");
            
            return cell;
        }

        static NSString *CellIdentifier = @"GlobalKnowSearchCell";
        GlobalKnowSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.v_Bottom.hidden = YES;
        
        cell.btn_Modify.tag = indexPath.row;
        
        NSDictionary *dic = self.ar_KnowList[indexPath.row];
        
        cell.lb_Tag.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"TagKeyword"]];
        
        cell.lb_Contents.text = [dic objectForKey_YM:@"TagDescription"];
                
        [cell.btn_Modify addTarget:self action:@selector(onModify:) forControlEvents:UIControlEventTouchUpInside];

        CGRect frame = cell.lb_Tag.frame;
        frame.size.width = [Util getTextSize:cell.lb_Tag].width + 10;
        cell.lb_Tag.frame = frame;

        frame = cell.v_Tag.frame;
        frame.size.width = cell.lb_Tag.frame.size.width;
        cell.v_Tag.frame = frame;

        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if( indexPath.section == 0 || indexPath.section == 1 )
    {
        NSDictionary *dic = nil;
        if( indexPath.section == 0 )
        {
            if( self.ar_StudyList.count <= 0 )
            {
                return;
            }
            
            dic = self.ar_StudyList[indexPath.row];
        }
        else
        {
            if( self.ar_LibList.count <= 0 )
            {
                return;
            }

            dic = self.ar_LibList[indexPath.row];
        }

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StudyDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"StudyDetailViewController"];
        vc.dic_Info = dic;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 114;

//    switch (indexPath.section)
//    {
//        case 0:
//        case 1:
//            return 98;
//            
//        case 2:
//            return 100;
//    }
//    
//    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"GlobalSearchHeaderCell";
    GlobalSearchHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    switch (section)
    {
        case 0:
            cell.iv_Icon.image = BundleImage(@"icon_searchresult_study.png");
            cell.lb_Title.text = @"이달의 강의";
            break;

        case 1:
            cell.iv_Icon.image = BundleImage(@"icon_searchresult_data.png");
            cell.lb_Title.text = @"학습 자료실";
            break;
    
        case 2:
            cell.iv_Icon.image = BundleImage(@"icon_searchresult_tag.png");
            cell.lb_Title.text = @"지식창고";
            break;
            
        default:
            break;
    }

    return cell;
}

- (void)onModify:(UIButton *)btn
{
    NSDictionary *dic = self.ar_KnowList[btn.tag];
    KnowInModifyViewController *vc = [[KnowInModifyViewController alloc]initWithNibName:@"KnowInModifyViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    vc.str_Row = [NSString stringWithFormat:@"%ld", btn.tag + 1];
    
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void)reloadOneKnow:(NSNotification *)noti
{
    [self updateKnow];
}

@end
