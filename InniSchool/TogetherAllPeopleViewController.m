//
//  TogetherAllPeopleViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 19..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "TogetherAllPeopleViewController.h"
#import "TogetherAllPeopleCell.h"

@interface TogetherAllPeopleViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation TogetherAllPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"우리 함께해요 완료자 리스트";
    
    [self initNavi];
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
    lb_Title.text = @"참여한 사람";
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

}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TogetherAllPeopleCell";
    TogetherAllPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    /*
     ComNM		사용자 지점, 매장명
     DeptName		사용자 부서명
     
     
     
     ComNM = "\Uc774\Ub2c8\Uc2a4\Ud504\Ub9ac \Ubcf8\Uc0ac";
     DeptName = "\Ubd80\Uc11c2";
     DutiesPositionParentIdx = 100;
     FullImgURL = "http://52.68.160.225:80/api/file_upload/test_1(15).jpg";
     ImgURL = "/file_upload/test_1(15).jpg";
     NameKR = "\Uc774\Uc5e0\Uce90\Uc2a4\Ud2b8";
     */
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
    [cell.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_small.png") usingCache:NO];
    
    cell.iv_User.userInteractionEnabled = YES;
    
    //서버에서 유저 idx값이 안넘어와서 뺌
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTap:)];
//    [tap setNumberOfTapsRequired:1];
//    [cell.iv_User addGestureRecognizer:tap];

    cell.lb_Name.text = [dic objectForKey_YM:@"NameKR"];
    
//    cell.lb_Desc.text = [NSString stringWithFormat:@"%@(%@)", [dic objectForKey:@"DeptName"], [dic objectForKey:@"ComNM"]];
    cell.lb_Desc.text = [dic objectForKey:@"ComNM"];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIGesture
- (void)profileTap:(UIGestureRecognizer *)gesture
{
    NSDictionary *dic = self.ar_List[gesture.view.tag];
    
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ShowUserInfo" owner:self options:nil];
    ShowUserInfo *view = [topLevelObjects objectAtIndex:0];
    view.str_Idx = [dic objectForKey_YM:@"RegUserIdx"];
    [view updateList];
    
    view.alpha = NO;
    
    view.v_Container.center = self.navigationController.view.center;
    
    [self.navigationController.view addSubview:view];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         view.alpha = YES;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

@end
