//
//  CommentListViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 4..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "CommentListViewController.h"
#import "CommentListCell.h"
#import "CommentModifyViewController.h"

static NSInteger snEmptyTag = 90;

@interface CommentListViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldYAlignContratint;
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, strong) CommentListCell *prototypeCell;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UITextField *tf_Comment;
@property (nonatomic, weak) IBOutlet UIView *v_Acc;
@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"댓글 리스트";
    
    [self initNavi];
    
    [self.tf_Comment setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Comment.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_Comment.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self updateList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"댓글";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)updateList
{
    //http://211.232.113.65:7080/api/learn/selectIntegrationCourseCommentList.do?integrationCourseIdx=1&userIdx=1004
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/selectIntegrationCourseCommentList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        UIView *view = (UIView *)[self.tbv_List viewWithTag:snEmptyTag];
                                        [view removeFromSuperview];

                                        if( resulte )
                                        {
                                            self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"IntegrationCourseCommentList"]];
                                        }
                                                                                
                                        [self.tbv_List reloadData];
                                        
                                        if( self.ar_List == nil || self.ar_List.count <= 0 )
                                        {
                                            [self showEmptyView];
                                        }
                                    }];
}
 
- (void)showEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommentEmpty" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snEmptyTag;
    view.center = self.tbv_List.center;
    [self.tbv_List addSubview:view];
}


#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    }
    else
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    self.keyboardHeight.constant = keyboardSize.height;
    
    __weak typeof(self) weakself = self;

    [UIView animateWithDuration:rate.floatValue animations:^{

        [weakself.view layoutIfNeeded];
    }];
    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tbv_List scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardHeight.constant = 0;

    __weak typeof(self) weakself = self;

    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{

        [weakself.view layoutIfNeeded];
    }];
}


#pragma mark UITableViewDataSource
- (CommentListCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        static NSString *CellIdentifier = @"CommentListCell";
        CommentListCell *cell = [self.tbv_List dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            _prototypeCell = [topLevelObjects objectAtIndex:0];
        }
    }
    
    return _prototypeCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentListCell";
    CommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (IS_IOS8_OR_ABOVE)
    //    {
    //        return UITableViewAutomaticDimension;
    //    }
    
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    
    [self.prototypeCell updateConstraintsIfNeeded];
    [self.prototypeCell layoutIfNeeded];
    
    CGFloat fHeight = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return fHeight;
}

- (void)configureCell:(CommentListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     ComNM = "\Uc774\Ub2c8\Uc2a4\Ud504\Ub9ac \Ubcf8\Uc0ac";
     CourseCommentIdx = 81;
     DeletableYN = Y;
     DeptName = "\Ubd80\Uc11c2";
     DutiesPositionParentIdx = 100;
     EditCharDate = "<null>";
     EditableYN = Y;
     EditorIdx = "<null>";
     FullImgURL = "null/UPLOAD/MEMBER/AAA.JPG";
     ImgURL = "/UPLOAD/MEMBER/AAA.JPG";
     IntegrationCourseIdx = 1;
     NameKR = "\Uc774\Uc5e0\Ud14c\Uc2a4\Ud2b8";
     RegCharDate = 20150430;
     RegUserIdx = 1004;
     ReportedYN = N;
     UserComments = "<null>";
     */

    if( indexPath.row % 2 )
    {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    //유저 이미지
    NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
    [cell.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_small.png") usingCache:NO];
    cell.iv_User.userInteractionEnabled = YES;
    cell.iv_User.tag = indexPath.row;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTap:)];
    [tap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:tap];

    
    //글쓴이
    cell.lb_Writer.text = [dic objectForKey_YM:@"NameKR"];
    
    //매장명 | 등록날짜
    
    
    
    
    NSString *strCom = @"";
    
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
            strCom = str_Dept;
        }
        else
        {
            strCom = @"본사";
        }
    }
    else
    {
        strCom = [dic objectForKey_YM:@"ComNM"];
    }

    
    
    
    
    
    
    
    cell.lb_SubTitle.text = [NSString stringWithFormat:@"%@ | %@", strCom, [Util makeDate:[dic objectForKey_YM:@"RegCharDate"]]];
    
    //내용
    cell.lb_Contents.numberOfLines = 0;
    cell.lb_Contents.text = [dic objectForKey_YM:@"UserComments"];
    
    //버튼들
    cell.btn_Delete.tag = cell.btn_Modify.tag = cell.btn_Report.tag = indexPath.row;
    cell.iv_Seper.hidden = cell.btn_Delete.hidden = cell.btn_Modify.hidden = cell.btn_Report.hidden = YES;
    
    NSString *str_IsMyContents = [dic objectForKey_YM:@"EditableYN"];
    if( [str_IsMyContents isEqualToString:@"Y"] )
    {
        //내가 쓴 댓글이면
        cell.btn_Delete.hidden = NO;
//        cell.iv_Seper.hidden = cell.btn_Delete.hidden = cell.btn_Modify.hidden = NO;
        [cell.btn_Delete addTarget:self action:@selector(onDeleteComment:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_Modify addTarget:self action:@selector(onModify:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        //다른사람이 쓴 댓글이면
        cell.btn_Report.hidden = NO;
        [cell.btn_Report addTarget:self action:@selector(onReport:) forControlEvents:UIControlEventTouchUpInside];
    }
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


#pragma mark - UITextFeildDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}


#pragma mark - IBAction
- (IBAction)goAddComment:(id)sender
{
    if( self.tf_Comment.text.length <= 0 )
    {
        return;
    }
    
    //http://211.232.113.65:7080/api/learn/insertIntegrationCourseComment.do?integrationCourseIdx=1&userIdx=1004&userComments=new test comments
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:self.tf_Comment.text forKey:@"userComments"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/insertIntegrationCourseComment.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSDictionary *dic = [resulte objectForKey:@"ResultInfo"];
                                            NSInteger nCode = [[dic objectForKey_YM:@"ResultCode"] integerValue];
                                            if( nCode == 1 )
                                            {
                                                
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:@"오류"];
                                            }

                                            self.tf_Comment.text = @"";
                                            [self.view endEditing:YES];
                                            
                                            [self updateList];
                                            
                                            [UIView animateWithDuration:0.3f
                                                             animations:^{
                                                                
                                                                 self.tbv_List.contentOffset = CGPointZero;
                                                             } completion:^(BOOL finished) {
                                                                 
                                                             }];
                                        }
                                    }];
}

- (void)onDeleteComment:(UIButton *)btn
{
    UIAlertView *alert = CREATE_ALERT(nil, @"댓글을 삭제하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            //http://211.232.113.65:7080/api/learn/deleteIntegrationCourseComment.do?courseCommentIdx=1&userIdx=1004
            NSDictionary *dic = self.ar_List[btn.tag];
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:[dic objectForKey_YM:@"CourseCommentIdx"] forKey:@"courseCommentIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/deleteIntegrationCourseComment.do"
                                                param:dicM_Params
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                if( resulte )
                                                {
                                                    NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                    if( nCode == 1 )
                                                    {
                                                        
                                                    }
                                                    else
                                                    {
                                                        [self.navigationController.view makeToast:@"오류"];
                                                    }
                                                    
                                                    [self updateList];
                                                }
                                            }];
        }
    }];
}

- (void)onReport:(UIButton *)btn
{
    UIAlertView *alert = CREATE_ALERT(nil, @"신고하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             //http://211.232.113.65:7080/api/learn/insertIntegrationCourseCommentReport.do?courseCommentIdx=4&userIdx=1004
             NSDictionary *dic = self.ar_List[btn.tag];
             NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
             [dicM_Params setObject:[dic objectForKey_YM:@"CourseCommentIdx"] forKey:@"courseCommentIdx"];
             [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
             
             [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/insertIntegrationCourseCommentReport.do"
                                                 param:dicM_Params
                                             withBlock:^(id resulte, NSError *error) {
                                                 
                                                 if( resulte )
                                                 {
                                                     NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                     if( nCode == 1 )
                                                     {
                                                         [self.navigationController.view makeToast:@"신고 되었습니다. 관리자의 확인 후 삭제 처리 여부가 결정됩니다."];
                                                     }
                                                     else if( nCode == 2 )
                                                     {
                                                         [self.navigationController.view makeToast:@"이미 신고하셨습니다. 관리자의 확인 후 삭제 처리 여부가 결정됩니다."];
                                                     }
                                                     else
                                                     {
                                                         [self.navigationController.view makeToast:@"오류"];
                                                     }

                                                     [self updateList];
                                                 }
                                             }];
         }
     }];
}

- (void)onModify:(UIButton *)btn
{
    CommentModifyViewController *vc = [[CommentModifyViewController alloc]initWithNibName:@"CommentModifyViewController" bundle:nil];
    vc.dic_Info = self.ar_List[btn.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
