//
//  GreenTubeModifyViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GreenTubeModifyViewController.h"
#import "UIPlaceHolderTextView.h"
#import "AddTagViewController.h"

@interface GreenTubeModifyViewController ()
@property (nonatomic, strong) NSArray *ar_TagList;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *tv_Contents;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tag;
@end

@implementation GreenTubeModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"그린튜브 수정하기";
    
    [self initNavi];
    
    self.tv_Contents.layer.cornerRadius = 5.0f;
    self.tv_Contents.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tv_Contents.layer.borderWidth = 0.5f;
    
    self.tv_Contents.placeholder = @"내용을 입력해 주세요.";
    [self.tv_Contents becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiTagList:)
                                                 name:@"notiTagList"
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

- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"수정하기";
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
    
    //http://127.0.0.1:7080/api/sns/updateSnsPost.do?
    //comBraRIdx=10001
    //userIdx=1004
    //snsFeedIdx=13
    //title=좋아하는 요리는
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:self.str_Idx forKey:@"snsFeedIdx"];
    [dicM_Params setObject:self.tv_Contents.text forKey:@"snsContent"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/updateSnsPost.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [self.view endEditing:YES];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode) {
                                                case 1:
                                                {
                                                    [self sendTagToServer:self.str_Idx];
                                                    
                                                    [GMDCircleLoader show];

                                                    [self performSelector:@selector(onDismissDelay) withObject:nil afterDelay:1.0f];
                                                }
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                        }
                                    }];
}

- (void)onDismissDelay
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if( self.str_Row )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadOneSnsFeed" object:self.str_Row userInfo:nil];
        }
        
    }];
    
    [GMDCircleLoader hide];
}

- (void)sendTagToServer:(NSString *)str_FeedIdx
{
    //http://127.0.0.1:7080/api/sns/insertSnsTagKeyword.do?
    //snsFeedIdx=12
    //tagKeyword=자연보호
    
    for( NSInteger i = 0; i < self.ar_TagList.count; i++ )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
        [dicM_Params setObject:str_FeedIdx forKey:@"snsFeedIdx"];
        
        id obj = self.ar_TagList[i];
        if( [obj isKindOfClass:[NSString class]] )
        {
            NSString *str_Tag = (NSString *)obj;
            [dicM_Params setObject:str_Tag forKey:@"tagKeyword"];
        }
        else
        {
            NSDictionary *dic = (NSDictionary *)obj;
            NSInteger nTagIdx = [[dic objectForKey_YM:@"TagIdx"] integerValue];
            NSString *str_TagIdx = [NSString stringWithFormat:@"%ld", nTagIdx];
            [dicM_Params setObject:str_TagIdx forKey:@"tagIdx"];
        }
        
        //http://127.0.0.1:7080/api/sns/insertSnsTagKeyword.do?comBraRIdx=10001&userIdx=1004&snsFeedIdx=12&tagKeyword=자연보호
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsTagKeyword.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [self.view endEditing:YES];
                                            
                                            if( resulte )
                                            {
//                                                if( self.str_Row )
//                                                {
//                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadOneSnsFeed" object:self.str_Row userInfo:nil];
//                                                }
//                                                else
//                                                {
//                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadDetailSnsFeed" object:self.str_Row userInfo:nil];
//                                                }
//                                                [self dismissViewControllerAnimated:YES completion:^{
//                                                    
//                                                    if( self.str_Row )
//                                                    {
//                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadOneSnsFeed" object:self.str_Row userInfo:nil];
//                                                    }
//                                                    
//                                                }];
                                            }
                                        }];
    }
    
    
}

- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"searchType"];
    [dicM_Params setObject:self.str_Idx forKey:@"snsFeedIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"SNSList"]];
                                            NSDictionary *dic = [ar firstObject];
                                            self.tv_Contents.text = [dic objectForKey_YM:@"SNSContent"];
                                            
                                            
                                            
                                            NSMutableString *strM_Tag = [NSMutableString string];
                                            self.ar_TagList = [NSArray arrayWithArray:[dic objectForKey:@"SNSTagList"]];
                                            for( NSInteger i = 0; i < self.ar_TagList.count; i++ )
                                            {
                                                NSDictionary *dic_Tag = self.ar_TagList[i];
                                                [strM_Tag appendFormat:@"#"];
                                                [strM_Tag appendString:[dic_Tag objectForKey_YM:@"TagKeyword"]];
                                                [strM_Tag appendString:@" "];
                                            }
                                            
                                            if( [strM_Tag hasSuffix:@" "] )
                                            {
                                                [strM_Tag deleteCharactersInRange:NSMakeRange([strM_Tag length]-1, 1)];
                                            }
                                            
                                            self.lb_Tag.text = strM_Tag;
                                            
                                            if( self.ar_TagList.count > 0 )
                                            {
                                                self.btn_Tag.selected = YES;
                                            }
                                            else
                                            {
                                                self.btn_Tag.selected = NO;
                                            }

                                        }
                                    }];
}

- (void)notiTagList:(NSNotification *)noti
{
    //기존거와 비교해서 없으면 태그 삭제
    NSArray *ar_NewTag = [NSArray arrayWithArray:noti.object];
    for( NSInteger i = 0; i < self.ar_TagList.count; i++ )
    {
        BOOL isDelete = YES;
        id obj = self.ar_TagList[i];
        if( [obj isKindOfClass:[NSDictionary class]] == NO )
        {
            continue;
        }
        
        NSDictionary *dic = self.ar_TagList[i];
        NSInteger nTagIdx = [[dic objectForKey_YM:@"TagIdx"] integerValue];
        
        for( NSInteger j = 0; j < ar_NewTag.count; j++ )
        {
            id objSub = ar_NewTag[j];
            if( [objSub isKindOfClass:[NSDictionary class]] == NO )
            {
                continue;
            }
            
            NSDictionary *dic_New = ar_NewTag[j];
            NSInteger nNewTagIdx = [[dic_New objectForKey_YM:@"TagIdx"] integerValue];
            if( nTagIdx == nNewTagIdx )
            {
                isDelete = NO;
                break;
            }
        }
        
        if( isDelete )
        {
            //http://127.0.0.1:7080/api/sns/deleteSnsTagKeyword.do?comBraRIdx=10001&userIdx=1004&snsFeedIdx=13&tagIdx=50
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
            [dicM_Params setObject:self.str_Idx forKey:@"snsFeedIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nTagIdx] forKey:@"tagIdxList"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/deleteSnsTagKeyword.do"
                                                param:dicM_Params
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                if( resulte )
                                                {

                                                }
                                            }];
        }
    }
    
    
    self.ar_TagList = [NSArray arrayWithArray:noti.object];
    [self updateTagText];
}

- (void)updateTagText
{
    if( self.ar_TagList.count > 0 )
    {
        self.btn_Tag.selected = YES;
    }
    else
    {
        self.btn_Tag.selected = NO;
    }
    
    NSMutableString *strM_Tag = [NSMutableString string];
    for( NSInteger i = 0; i < self.ar_TagList.count; i++ )
    {
        id obj = self.ar_TagList[i];
        if( [obj isKindOfClass:[NSString class]] )
        {
            NSString *str_Tag = (NSString *)obj;
            [strM_Tag appendString:[NSString stringWithFormat:@"#%@", str_Tag]];
            [strM_Tag appendString:@" "];
        }
        else
        {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *str_Tag = [dic objectForKey_YM:@"TagKeyword"];
            [strM_Tag appendString:[NSString stringWithFormat:@"#%@", str_Tag]];
            [strM_Tag appendString:@" "];
        }
    }
    
    if( [strM_Tag hasSuffix:@" "] )
    {
        [strM_Tag deleteCharactersInRange:NSMakeRange([strM_Tag length]-1, 1)];
    }
    
    self.lb_Tag.text = strM_Tag;
}

- (IBAction)goAddTag:(id)sender
{
    AddTagViewController *vc = [[AddTagViewController alloc]initWithNibName:@"AddTagViewController" bundle:nil];
    vc.ar_TagList = self.ar_TagList;
    vc.isModifyMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
