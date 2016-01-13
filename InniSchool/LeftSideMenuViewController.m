//
//  LeftSideMenuViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 27..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "LeftSideMenuViewController.h"

@interface SideMenuCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *btn_Item;
@end

@implementation SideMenuCell

@end

@interface LeftSideMenuViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_UserName;
@property (nonatomic, weak) IBOutlet UILabel *lb_UserDesc;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIView *v_LastObj;
@end

@implementation LeftSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.iv_User.layer.masksToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;

    self.sv_Main.backgroundColor = [UIColor colorWithHexString:@"2B302B"];
    
//    self.arM_List = [NSMutableArray array];
//    [self.arM_List addObject:@"이달의 강의"];
//    [self.arM_List addObject:@"학습 자료실"];
//    [self.arM_List addObject:@"그린튜브"];
//    [self.arM_List addObject:@"그린위키"];
//    [self.arM_List addObject:@"지식창고"];
//    [self.arM_List addObject:@"우리 함께해요"];
//    [self.arM_List addObject:@"우리 공부해요"];
//    [self.arM_List addObject:@"문의사항"];
//    [self.arM_List addObject:@"공지사항"];
//    [self.arM_List addObject:@"환경설정"];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSideMenuOpen)
                                                 name:@"WillOpenMenu"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allDeSelect)
                                                 name:@"AllDeSelect"
                                               object:nil];

    

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

- (void)allDeSelect
{
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        SideMenuCell *cell = (SideMenuCell *)[self.tbv_List cellForRowAtIndexPath:indexPath];
        for( id subView in cell.contentView.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn = (UIButton *)subView;
                btn.selected = NO;
            }
        }
    }
}

- (void)onSideMenuOpen
{
    self.screenName = @"글로벌 메뉴";
    
    [self updateList];
}

- (void)updateList
{
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"common/selectMenuUseYnList.do"
                                        param:nil
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.arM_List = [NSMutableArray array];
                                            NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"MenuList"]];
                                            
                                            for( NSInteger i = 0; i < ar.count; i++ )
                                            {
                                                NSDictionary *dic = ar[i];
                                                
//                                                if( [[dic objectForKey_YM:@"MenuName"] isEqualToString:@"지식창고"] )
//                                                {
//                                                    continue;
//                                                }
                                                
                                                //아래는 서버에서 받아와서 보여주는거
                                                if( [[dic objectForKey_YM:@"UseYN"] isEqualToString:@"Y"] )
                                                {
                                                    [self.arM_List addObject:dic];
                                                }
                                                
                                                
//                                                이거는 그냥 내가 다 보여주고 싶어서 함
//                                                [self.arM_List addObject:dic];
                                            }
                                        }
                                        
                                        [self.tbv_List reloadData];
                                        
                                        CGRect frame = self.tbv_List.frame;
                                        frame.size.height = self.arM_List.count * 40;
                                        self.tbv_List.frame = frame;
                                        
                                        frame = self.v_LastObj.frame;
                                        frame.origin.y = self.tbv_List.frame.origin.y + self.tbv_List.frame.size.height;
                                        self.v_LastObj.frame = frame;
                                        
                                        self.sv_Main.contentSize = CGSizeMake(0, self.v_LastObj.frame.origin.y + self.v_LastObj.frame.size.height);
                                    }];
    
    [self updateUserInfo];
}

- (void)updateUserInfo
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"member/selectUserInfo.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSDictionary *dic = [resulte objectForKey:@"UserInfo"];
                                            
                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                            [self.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_big.png") usingCache:NO];
                                            
                                            self.lb_UserName.text = [dic objectForKey_YM:@"NameKR"];
                                            
                                            //ComNM : 작성자 지점, 매장명
                                            //DeptName : 작성자 부서명
//                                            self.lb_UserDesc.text = [dic objectForKey_YM:@"ComNM"];
                                            
                                            
                                            NSInteger nDutiesPositionParentIdx = [[dic objectForKey_YM:@"DutiesPositionParentIdx"] integerValue];
                                            if( nDutiesPositionParentIdx == 1000 )
                                            {
                                                NSString *str_Dept = [dic objectForKey_YM:@"DeptName"];
                                                if( str_Dept == nil )
                                                {
                                                    str_Dept = [dic objectForKey_YM:@"DeptNM"];
                                                }
                                                
                                                if( str_Dept.length > 0 )
                                                {
                                                    self.lb_UserDesc.text = str_Dept;
                                                }
                                                else
                                                {
                                                    self.lb_UserDesc.text = @"본사";
                                                }
                                            }
                                            else
                                            {
                                                self.lb_UserDesc.text = [dic objectForKey_YM:@"ComNM"];
                                            }
                                        }
                                    }];

    [self updateBg];
}

- (void)updateBg
{
    //http://127.0.0.1:7080/api/mypage/selectProfileBackground.do
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mypage/selectProfileBackground.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSDictionary *dic = [resulte objectForKey:@"ProfileBackgroundInfo"];
                                            
                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                            [self.iv_Bg setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"") usingCache:NO];
                                        }
                                    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arM_List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SideMenuCell";
    SideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    NSDictionary *dic = self.arM_List[indexPath.row];

    cell.btn_Item.tag = [[dic objectForKey_YM:@"MenuIdx"] integerValue];
    [cell.btn_Item addTarget:self action:@selector(onMoveToPage:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btn_Item.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    NSString *str_Title = [dic objectForKey_YM:@"MenuName"];
    [cell.btn_Item setTitle:[NSString stringWithFormat:@"  %@", str_Title] forState:UIControlStateNormal];
    
    NSString *str_NormalImageName = [NSString stringWithFormat:@"icon_menu%ld.png", indexPath.row + 1];
    NSString *str_HightlightImageName = [NSString stringWithFormat:@"icon_menu%ld_s.png", indexPath.row + 1];
    [cell.btn_Item setImage:BundleImage(str_NormalImageName) forState:UIControlStateNormal];
    [cell.btn_Item setImage:BundleImage(str_HightlightImageName) forState:UIControlStateHighlighted];
    [cell.btn_Item setImage:BundleImage(str_HightlightImageName) forState:UIControlStateSelected];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - IBAction
- (void)onMoveToPage:(UIButton *)btn
{
    [self allDeSelect];
    
    btn.selected = YES;
    
    if( btn.tag == 1 )
    {
        //이달의 강의
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"StudyNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 2 )
    {
        //학습자료실
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"StudyLibNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 3 )
    {
        //그린튜브
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"GreenTubeNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 4 )
    {
        //그린위키
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"WikiNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 5 )
    {
        //지식창고
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"KnowInNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 6 )
    {
        //우리 함께해요
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"TogetherNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 7 )
    {
        //우리 공부해요
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"WeStudyNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 8 )
    {
        //문의사항
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"AskingNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 9 )
    {
        //공지사항
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }
    else if( btn.tag == 10 )
    {
        //환경설정
        UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingNavi"];
        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
    }

}

- (IBAction)goHome:(id)sender
{
    UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavi"];
    [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
}

- (IBAction)goMyPage:(id)sender
{
    UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPageNavi"];
    [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
}

- (IBAction)goLogOut:(id)sender
{
    UIAlertView *alert = CREATE_ALERT(nil, @"로그아웃 하시겠습니까?", @"예", @"아니오");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            [Common removeUserInfo];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AllDeSelect" object:nil userInfo:nil];

            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"IsLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UINavigationController *loginNavi = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavi"];
            [Util setLoginNaviBar:loginNavi.navigationBar];
            [self.sideMenuViewController setMainViewController:loginNavi animated:YES closeMenu:YES];
        }
    }];
}

@end
