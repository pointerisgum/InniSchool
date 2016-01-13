//
//  NotiView.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 20..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "NotiView.h"
#import "MainNotiCell.h"
#import "AppDelegate.h"
#import "NotiViewController.h"

@implementation NotiView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateNotiView
{
    [self.tbv_List reloadData];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MainNotiCell";
    MainNotiCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    /*
     AttachFileList =             (
     {
     AttachFileFullURL = "http://52.68.160.225:80/api/file_upload/20150519232014.594803.jpg";
     AttachFileURL = "/file_upload/20150519232014.594803.jpg";
     AttachIdx = 13;
     }
     );
     BoardIdx = 20;
     CateCD = "<null>";
     CateName = "<null>";
     ComNM = "\Uc774\Ub2c8\Uc2a4\Ud504\Ub9ac \Ubcf8\Uc0ac";
     CompleteYN = N;
     Contents = bb;
     DeletableYN = Y;
     DeptName = "\Ubd80\Uc11c2";
     DutiesPositionParentIdx = 100;
     EditableYN = Y;
     NameKR = "\Uc774\Uc5e0\Uce90\Uc2a4\Ud2b8";
     RegDate = "2015.05.19";
     SecretYN = N;
     Title = aa;
     UserIdx = 1004;
     ViewCNT = 1;
     */
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    cell.lb_Title.text = [dic objectForKey_YM:@"Title"];

    cell.lb_Date.text = [NSString stringWithFormat:@"%@ | 조회 %@", [dic objectForKey_YM:@"RegDate"], [dic objectForKey_YM:@"ViewCNT"]];

//    cell.iv_Line.backgroundColor = [UIColor lightGrayColor];

    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NotiViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NotiViewController"];
    vc.str_DetailIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"BoardIdx"] integerValue]];
    vc.isDetail = YES;
    [self.vc_Parent.navigationController pushViewController:vc animated:YES];
}


@end
