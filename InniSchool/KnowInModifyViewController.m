//
//  KnowInModifyViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 17..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "KnowInModifyViewController.h"
#import "UIPlaceHolderTextView.h"

@interface KnowInModifyViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIView *v_Tag;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *tv_Contents;
@property (nonatomic, weak) IBOutlet UILabel *lb_OldTagDesc;
@end

@implementation KnowInModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"지식창고 수정하기";
    
    self.sv_Main.contentSize = CGSizeMake(0, self.sv_Main.frame.size.height);
    
    self.tv_Contents.placeholder = @"글을 작성해 주세요.";
    
    self.tv_Contents.layer.cornerRadius = 5.0f;
    self.tv_Contents.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tv_Contents.layer.borderWidth = 0.5f;
    
    self.v_Tag.layer.cornerRadius = 5.0f;
    self.v_Tag.backgroundColor = [UIColor colorWithHexString:@"1EADEB"];

    self.lb_Tag.text = [NSString stringWithFormat:@"#%@", [self.dic_Info objectForKey_YM:@"TagKeyword"]];
    
    NSString *str_Desc = [self.dic_Info objectForKey_YM:@"TagDescription"];
    self.tv_Contents.text = self.lb_OldTagDesc.text = [str_Desc gtm_stringByUnescapingFromHTML];
    
    CGRect frame = self.lb_Tag.frame;
    frame.size.width = [Util getTextSize:self.lb_Tag].width + 10;
    self.lb_Tag.frame = frame;

    frame = self.v_Tag.frame;
    frame.size.width = self.lb_Tag.frame.size.width;
    self.v_Tag.frame = frame;

    frame = self.lb_OldTagDesc.frame;
    frame.size.height = [Util getTextSize:self.lb_OldTagDesc].height;
    self.lb_OldTagDesc.frame = frame;
    
    self.sv_Main.contentSize = CGSizeMake(0, self.lb_OldTagDesc.frame.origin.y + self.lb_OldTagDesc.frame.size.height + 20);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self initNavi];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tv_Contents becomeFirstResponder];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:rate.floatValue animations:^{
        
//        self.v_Acc.frame = CGRectMake(self.v_Acc.frame.origin.x, self.v_Acc.frame.origin.y - keyboardSize.height,
//                                      self.v_Acc.frame.size.width, self.v_Acc.frame.size.height);
//        
        self.sv_Main.frame = CGRectMake(self.sv_Main.frame.origin.x, self.sv_Main.frame.origin.y,
                                        self.sv_Main.frame.size.width, self.view.frame.size.height - keyboardSize.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        
//        self.v_Acc.frame = CGRectMake(self.v_Acc.frame.origin.x, self.view.frame.size.height - self.v_Acc.frame.size.height,
//                                      self.v_Acc.frame.size.width, self.v_Acc.frame.size.height);
    }];
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
    lb_Title.text = @"위키 입력";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self leftCancelButton];
    self.navigationItem.rightBarButtonItem = [self rightDoneButton];
}

- (void)cancelButtonPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)doneButtonPress:(UIButton *)btn
{
    if( self.tv_Contents.text.length <= 0 )
    {
        ALERT_ONE(@"내용을 입력해 주세요");
        return;
    }
    
    __block NSString *str_TagIdx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"TagIdx"] integerValue]];
    
    //http://127.0.0.1:7080/api/tag/updateTagDescription.do?comBraRIdx=10001&userIdx=1004&tagIdx=2&tagDescription=권기룡에 대한 오해
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:str_TagIdx forKey:@"tagIdx"];
    [dicM_Params setObject:self.tv_Contents.text forKey:@"tagDescription"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"tag/updateTagDescription.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadOneKnow" object:str_TagIdx userInfo:nil];

                                                    [self dismissViewControllerAnimated:YES completion:^{
                                                       
                                                        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                        [window makeToast:@"입력 되었습니다"];
                                                    }];
                                                }
                                                    break;

                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                        }
                                    }];

}

@end
