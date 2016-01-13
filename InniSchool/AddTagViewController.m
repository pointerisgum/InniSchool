//
//  AddTagViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 13..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "AddTagViewController.h"

static const CGFloat kCellHeight = 30.f;

@interface AddTagViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *arM_Tag;
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UITextField *tf_Tag;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_TagList;
@end

@implementation AddTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.screenName = @"그린튜브 태그 수정";
    
    [self initNavi];
    
    [self.tf_Tag becomeFirstResponder];
    
    self.tf_Tag.layer.cornerRadius = 5.0f;
    self.tf_Tag.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tf_Tag.layer.borderWidth = 0.5f;

    self.tbv_List.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tbv_List.layer.borderWidth = 0.5f;
    
    self.sv_TagList.layer.cornerRadius = 5.0f;
    self.sv_TagList.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sv_TagList.layer.borderWidth = 0.5f;

    [self.tf_Tag setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_Tag.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_Tag.frame.size.height)];

    [self.tf_Tag addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if( self.ar_TagList )
    {
        self.arM_Tag = [NSMutableArray arrayWithArray:self.ar_TagList];
        [self updateTagList];
    }
    else
    {
        self.arM_Tag = [NSMutableArray array];
    }
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
    lb_Title.text = @"태그 입력";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
    self.navigationItem.rightBarButtonItem = [self rightDoneButton];
}

- (void)doneButtonPress:(UIButton *)btn
{
    if( self.arM_Tag.count <= 0 && self.isModifyMode == NO )
    {
        [self.navigationController.view makeToast:@"태그를 입력해 주세요"];
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"notiTagList" object:self.arM_Tag userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateTagList
{
    for( UIView *subView in self.sv_TagList.subviews )
    {
        if( subView.tag > 0 )
        {
            [subView removeFromSuperview];
        }
    }
    
    CGFloat fLastX = 0.0f;
    for( NSInteger i = 0; i < self.arM_Tag.count; i++ )
    {
        NSString *str_Tag = @"";
        id obj = self.arM_Tag[i];
        if( [obj isKindOfClass:[NSString class]] )
        {
            //직접 등록한 태그
            str_Tag = self.arM_Tag[i];
        }
        else if( [obj isKindOfClass:[NSDictionary class]] )
        {
            //기존에 있던 태그
            str_Tag = [obj objectForKey_YM:@"TagKeyword"];
        }
        
        UILabel *lb = [[UILabel alloc]init];
        lb.font = [UIFont fontWithName:@"Helvetica" size:14];
        lb.textColor = [UIColor whiteColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.text = str_Tag;
        
        CGSize textSize = [[lb text] sizeWithAttributes:@{NSFontAttributeName:[lb font]}];

        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(fLastX + 5, 4, textSize.width + 10, 22)];
        view.layer.cornerRadius = 5.0f;
        lb.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        view.tag = i + 1;
        view.backgroundColor = [UIColor colorWithHexString:@"1EADEB"];
        [view addSubview:lb];
        
        fLastX = view.frame.origin.x + view.frame.size.width;
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = lb.frame;
        btn.tag = view.tag;
        [btn addTarget:self action:@selector(onTagDelete:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:BundleImage(@"btn_delete2_photo.png") forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.imageEdgeInsets = UIEdgeInsetsMake(-9, 0, 0, -10);
        [view addSubview:btn];
        
        [self.sv_TagList addSubview:view];
        
        self.sv_TagList.contentSize = CGSizeMake(fLastX + 5, 0);
    }
}


#pragma mark - UITableviewDelegate & dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( self.ar_List.count > 4 )
    {
        CGRect frame = self.tbv_List.frame;
        if( IS_3_5Inch )
        {
            frame.size.height = kCellHeight * 3;
        }
        else
        {
            frame.size.height = kCellHeight * 5;
        }
        self.tbv_List.frame = frame;
    }
    else
    {
        CGRect frame = self.tbv_List.frame;
        frame.size.height = kCellHeight * self.ar_List.count;
        self.tbv_List.frame = frame;
    }
    
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F7F8F9"];
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.textLabel.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"TagKeyword"]];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"1EADEB"];
    
    UIImageView *iv_UnderLine = (UIImageView *)[cell.contentView viewWithTag:999];
    if( iv_UnderLine )
    {
        [iv_UnderLine removeFromSuperview];
    }
    
    if( indexPath.row < self.ar_List.count - 1 )
    {
        UIImageView *iv_UnderLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, kCellHeight - 1, tableView.frame.size.width, .5f)];
        iv_UnderLine.tag = 999;
        iv_UnderLine.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:iv_UnderLine];
    }
    
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    [self.arM_Tag addObject:dic];
    [self updateTagList];
    
    self.tf_Tag.text = @"";
    self.ar_List = nil;
    [self.tbv_List reloadData];

    
//    NSString *str_Tag = [dic objectForKey_YM:@"TagKeyword"];
//    
//    if( str_Tag.length > 0 )
//    {
//        if( [str_Tag hasPrefix:@"#"] == NO )
//        {
//            [self.arM_Tag addObject:[NSString stringWithFormat:@"#%@", str_Tag]];
//        }
//        else
//        {
//            [self.arM_Tag addObject:str_Tag];
//        }
//        
//        [self updateTagList];
//        
//        self.tf_Tag.text = @"";
//        self.ar_List = nil;
//        [self.tbv_List reloadData];
//    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField.text.length > 1 )
    {
        NSMutableString *strM_Tag = [NSMutableString stringWithString:textField.text];
        if( [strM_Tag hasPrefix:@"#"] )
        {
            [strM_Tag deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        
        [self.arM_Tag addObject:strM_Tag];
        
        [self updateTagList];
        
        textField.text = @"";

//        if( [textField.text hasPrefix:@"#"] == NO )
//        {
//            [self.arM_Tag addObject:[NSString stringWithFormat:@"#%@", textField.text]];
//        }
//        else
//        {
//            [self.arM_Tag addObject:textField.text];
//        }
//        
//        [self updateTagList];
//        
//        textField.text = @"";
    }
    
    return YES;
}


#pragma mark - Noti
- (void)textFieldDidChange:(UITextField *)tf
{
    if( tf.text.length > 0 )
    {
        //http://127.0.0.1:7080/api/sns/selectTagKeywordList.do?comBraRIdx=10001&tagKeyword=민&tagIdxs=1,2,3,4
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:tf.text forKey:@"tagKeyword"];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectTagKeywordList.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                /*
                                                 TagIdx = 28;
                                                 TagKeyword = aa;
                                                 */
                                                
                                                self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"TagKeywordList"]];
                                                [self.tbv_List reloadData];
                                                
                                            }
                                        }];
    }
    else
    {
        self.ar_List = nil;
        [self.tbv_List reloadData];
    }
}


#pragma mark - Selector
- (void)onTagDelete:(UIButton *)btn
{
    [self.arM_Tag removeObjectAtIndex:btn.tag - 1];
    [self updateTagList];
}

@end
