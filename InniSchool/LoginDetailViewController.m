//
//  LoginDetailViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 27..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "LoginDetailViewController.h"

@interface LoginDetailViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UITextField *tf_Id;
@property (nonatomic, weak) IBOutlet UITextField *tf_Pw;
@property (nonatomic, weak) IBOutlet UIButton *btn_AutoLogin;
@end

@implementation LoginDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.iv_Bg.image = self.i_Bg;
    
    [self.tf_Id setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Id.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_Id.frame.size.height)];
    
    [self.tf_Pw setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Pw.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_Pw.frame.size.height)];
    
    self.btn_AutoLogin.selected = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AutoLogin"] boolValue];
    
    if( self.btn_AutoLogin.selected )
    {
        self.tf_Id.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    }
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
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


#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:rate.floatValue animations:^{
        
        if( IS_3_5Inch )
        {
            self.sv_Main.contentOffset = CGPointMake(0, 190);
        }
        else
        {
            self.sv_Main.contentOffset = CGPointMake(0, keyboardSize.height);
        }
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        
        self.sv_Main.contentOffset = CGPointMake(0, 0);
        
    }completion:^(BOOL finished) {
        
    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}


#pragma mark - IBAction
- (IBAction)goLogin:(id)sender
{
    //http://52.68.160.225:80/api/member/selectLoginCheck.do?userId=emcast&userPass=emcast1&accessDevice=645&accessIp=211.232.113.65

    if( self.tf_Id.text.length <= 0 )
    {
        ALERT_ONE(@"아이디를 입력해주세요");
        return;
    }

    if( self.tf_Pw.text.length <= 0 )
    {
        ALERT_ONE(@"비밀번호를 입력해주세요");
        return;
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:self.tf_Id.text forKey:@"userId"];
    [dicM_Params setObject:self.tf_Pw.text forKey:@"userPass"];
    [dicM_Params setObject:@"644" forKey:@"accessDevice"];  //644는 iOS
    [dicM_Params setObject:[Util getIPAddress] forKey:@"accessIp"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"member/selectLoginCheck.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [GMDCircleLoader hide];

                                        if( resulte )
                                        {
                                            /*
                                             UserInfo =     {
                                             LoginCheckResult =         {
                                             LoginCheckResultCode = 1;
                                             UserIdx = 1009;
                                             };
                                             UserInfoDetail =         {
                                             AdminConfirm = "<null>";
                                             AdminFlag = 9;
                                             ComBraRIdx = 10001;
                                             ComIdx = 10004;
                                             ComNM = "\Uc774\Ub2c8\Uc2a4\Ud504\Ub9ac \Ubcf8\Uc0ac";
                                             CooperationCD = "<null>";
                                             DeptCdIdx = "<null>";
                                             DeptName = "<null>";
                                             DutiesPositionIdx = "<null>";
                                             DutiesPositionNM = "<null>";
                                             DutiesPositionParentIdx = "<null>";
                                             DutiesPositionParentNM = "<null>";
                                             EditDate = "<null>";
                                             ImgURL = "<null>";
                                             JoinCharDate = 20150422;
                                             JoinDate = "<null>";
                                             LeaveDate = "<null>";
                                             MemGrade = "<null>";
                                             MemState = 604;
                                             MemType = 596;
                                             NameENGF = "<null>";
                                             NameENGL = "<null>";
                                             NameKR = "\Uc774\Uc5e0\Uce90\Uc2a4\Ud2b8";
                                             PassEditDate = "<null>";
                                             Sabun = "<null>";
                                             UserId = emcast;
                                             UserIdx = 1009;
                                             ZipCD = "<null>";
                                             };
                                             };
                                             */
                                            
                                            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:resulte];
                                            NSDictionary *dic_Info = [dic objectForKey:@"UserInfo"];
                                            NSDictionary *dic_Check = [dic_Info objectForKey:@"LoginCheckResult"];
                                            NSInteger nResultCode = [[dic_Check objectForKey:@"LoginCheckResultCode"] integerValue];
                                            NSLog(@"nResultCode : %@", [dic_Check objectForKey:@"LoginCheckResultCode"]);
                                            if( nResultCode == 1 )
                                            {
                                                [self.view endEditing:YES];
                                                
                                                //1이면 성공
                                                NSDictionary *dic_Detail = [dic_Info objectForKey:@"UserInfoDetail"];
                                                [[NSUserDefaults standardUserDefaults] setObject:self.tf_Id.text forKey:@"userId"];
                                                [[NSUserDefaults standardUserDefaults] setObject:self.tf_Pw.text forKey:@"userPw"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic_Check objectForKey_YM:@"UserIdx"] forKey:@"userIdx"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic_Detail objectForKey_YM:@"ComBraRIdx"] forKey:@"comBraRIdx"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsLogin"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                //싱글턴에 유저정보 저장
                                                [UserData sharedData].dicM_UserInfo = [NSMutableDictionary dictionaryWithDictionary:[dic_Info objectForKey:@"UserInfoDetail"]];
                                                
                                                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                [appDelegate showOnlyMainView];
                                            }
                                            else if( nResultCode == 0 )
                                            {
                                                /*
                                                 로그인 정보 확인 결과
                                                 0 : 비밀번호 맞지 않음
                                                 1 : 확인 성공
                                                 2 : 인증실패
                                                 3 : 존재하지 않는 ID로그인 정보 확인 결과
                                                 */
                                                
                                                //0이면 실패
                                                ALERT_ONE(@"비밀번호를 확인해 주세요");
                                            }
                                            else if( nResultCode == 2 )
                                            {
                                                ALERT_ONE(@"인증실패");
                                            }
                                            else if( nResultCode == 3 )
                                            {
                                                ALERT_ONE(@"존재하지 않는 ID 입니다");
                                            }
                                            else if( nResultCode == 7 )
                                            {
                                                ALERT_ONE(@"이용정지된 아이디 입니다");
                                            }
                                            else if( nResultCode == 8 )
                                            {
                                                ALERT_ONE(@"퇴사처리된 아이디 입니다");
                                            }
                                            else
                                            {
                                                ALERT_ONE(@"로그인에 실패 하였습니다\n계정을 다시 확인하여 주세요");
                                            }
                                        }
                                        else
                                        {
                                            ALERT_ONE(@"로그인인 실패");
                                        }
                                    }];
}

- (IBAction)goAutoLogin:(id)sender
{
    self.btn_AutoLogin.selected = !self.btn_AutoLogin.selected;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.btn_AutoLogin.selected] forKey:@"AutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

@end
