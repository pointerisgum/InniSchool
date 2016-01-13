//
//  VoteWriteViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 14..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "VoteWriteViewController.h"
#import "VoteWriteCell.h"

@interface VoteWriteViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSArray *ar_Number;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UITextField *tf_Title;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_AddItem;
@property (nonatomic, weak) IBOutlet UIButton *btn_ShowOnlyMe;
@property (nonatomic, weak) IBOutlet UIView *v_Acc;
@end

@implementation VoteWriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initNavi];
    
    self.tf_Title.layer.cornerRadius = 5.0f;
    self.tf_Title.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tf_Title.layer.borderWidth = 0.5f;

    self.btn_AddItem.layer.cornerRadius = 5.0f;
    self.btn_AddItem.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_AddItem.layer.borderWidth = 0.5f;

    [self.tf_Title setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Title.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, self.tf_Title.frame.size.height)];

    self.arM_List = [NSMutableArray array];
    self.ar_Number = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X",@"Y", @"Z",nil];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        if( IS_3_5Inch )
        {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, 150, 0.0);
        }
        else
        {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, 80, 0.0);
        }
        
    }
    else
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    [UIView animateWithDuration:rate.floatValue animations:^{

        self.v_Acc.frame = CGRectMake(self.v_Acc.frame.origin.x, self.v_Acc.frame.origin.y - keyboardSize.height,
                                      self.v_Acc.frame.size.width, self.v_Acc.frame.size.height);
        
        self.sv_Main.frame = CGRectMake(0, 0, self.sv_Main.frame.size.width, self.v_Acc.frame.origin.y);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{

        self.v_Acc.frame = CGRectMake(self.v_Acc.frame.origin.x, self.view.frame.size.height - self.v_Acc.frame.size.height,
                                      self.v_Acc.frame.size.width, self.v_Acc.frame.size.height);
        
        self.sv_Main.frame = CGRectMake(0, 0, self.sv_Main.frame.size.width, self.v_Acc.frame.origin.y);
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
    lb_Title.text = @"작성하기";
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
    if( self.tf_Title.text.length <= 0 )
    {
        ALERT_ONE(@"제목을 입력해 주세요");
        return;
    }
    
    NSArray *ar_VoteList = [NSMutableArray arrayWithArray:[self getVoteList]];

    if( ar_VoteList.count <= 0 )
    {
        ALERT_ONE(@"항목을 입력해 주세요");
        return;
    }
    
    if( ar_VoteList.count < 2 )
    {
        ALERT_ONE(@"투표 항목은 최소 2개는\n입력하셔야 합니다.");
        return;
    }
    
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:self.tf_Title.text forKey:@"title"];
    [dicM setObject:ar_VoteList forKey:@"list"];
    if( self.btn_ShowOnlyMe.selected )
    {
        [dicM setObject:@"Y" forKey:@"isOnly"];
    }
    else
    {
        [dicM setObject:@"N" forKey:@"isOnly"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notiVoteUpdate" object:dicM userInfo:nil];

    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
    
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
//    [dicM_Params setObject:@"1004" forKey:@"contentType"];
//    [dicM_Params setObject:@"" forKey:@"snsContent"];
//    
//    NSInteger nCategoryIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCodeIdx"] integerValue];
//    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCategoryIdx] forKey:@"cateCodeIdx"];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsPost.do"
//                                        param:dicM_Params
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [self.view endEditing:YES];
//                                        
//                                        if( resulte )
//                                        {
//
//                                        }
//                                    }];
//    
//    
//    
//    //http://127.0.0.1:7080/api/sns/insertSnsPollContent.do
//    //comBraRIdx=10001
//    //userIdx=1004
//    //snsFeedIdx=13
//    //pollContent=김치찌개
//    //pollNum=1
//    
//    NSArray *ar_VoteList = [NSMutableArray arrayWithArray:[self getVoteList]];
//    
//    NSInteger nCategoryIdx = [[self.dic_SelectCategory objectForKey_YM:@"CateCodeIdx"] integerValue];
//    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCategoryIdx] forKey:@"cateCodeIdx"];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsPollContent.do"
//                                        param:dicM_Params
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [self.view endEditing:YES];
//                                        
//                                        if( resulte )
//                                        {
//
//                                        }
//                                    }];
    

}

- (void)updateFrame
{
    CGRect frame = self.tbv_List.frame;
    frame.size.height = (self.arM_List.count + 1) * 44;
    self.tbv_List.frame = frame;
    
    frame = self.btn_AddItem.frame;
    frame.origin.y = self.tbv_List.frame.origin.y + self.tbv_List.frame.size.height + 10;
    self.btn_AddItem.frame = frame;
    
    frame = self.btn_ShowOnlyMe.frame;
    frame.origin.y = self.btn_AddItem.frame.origin.y + self.btn_AddItem.frame.size.height + 15;
    self.btn_ShowOnlyMe.frame = frame;
    
    self.sv_Main.contentSize = CGSizeMake(0, self.btn_ShowOnlyMe.frame.origin.y + self.btn_ShowOnlyMe.frame.size.height + 20);
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self updateFrame];
    
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arM_List.count + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VoteWriteCell";
    VoteWriteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    cell.tf_Question.delegate = self;
    
    cell.tf_Question.tag = cell.btn_Delete.tag = indexPath.row;
    
    cell.lb_Number.text = self.ar_Number[indexPath.row];

    if( self.arM_List.count <= indexPath.row )
    {
        return cell;
    }
    
    cell.tf_Question.text = self.arM_List[indexPath.row];
    
    [cell.btn_Delete addTarget:self action:@selector(onDeleteItem:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == self.tf_Title )
    {
        [self.view endEditing:YES];
    }
    else
    {
        [self goAddItem:nil];
    }

    return YES;
}


#pragma mark - IBAction
- (void)onDeleteItem:(UIButton *)btn
{
    [self.arM_List removeObjectAtIndex:btn.tag];
    [self.tbv_List reloadData];
}

- (IBAction)goAddItem:(id)sender
{
    [self.arM_List removeAllObjects];
    
    self.arM_List = [NSMutableArray arrayWithArray:[self getVoteList]];
    
    [self.tbv_List reloadData];
}

- (NSArray *)getVoteList
{
    NSMutableArray *arM = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.tbv_List numberOfSections]; i++)
    {
        NSInteger rows =  [self.tbv_List numberOfRowsInSection:i];
        for (int row = 0; row < rows; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:i];
            VoteWriteCell *cell = (VoteWriteCell *)[self.tbv_List cellForRowAtIndexPath:indexPath];
            for (id subView in cell.contentView.subviews)
            {
                if ([subView isKindOfClass:[UITextField class]])
                {
                    UITextField *tf = (UITextField *)subView;
                    if( tf.text.length > 0 )
                    {
                        [arM addObject:tf.text];
                    }
                }
            }
        }
    }
    
    return arM;
}

- (IBAction)goShowOnlyMe:(id)sender
{
    self.btn_ShowOnlyMe.selected = !self.btn_ShowOnlyMe.selected;
}

@end
