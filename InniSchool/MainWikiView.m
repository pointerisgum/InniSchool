//
//  MainWikiView.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 20..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "MainWikiView.h"
#import "MainWikiCell.h"
#import "WikiDetailViewController.h"

@implementation MainWikiView

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
    static NSString *CellIdentifier = @"MainWikiCell";
    MainWikiCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    /*
     ResponseDTEndYN = N;
     ResponseEndDate = 20150531;
     ResponseStartDate = 20150430;
     ResponseYN = N;
     SurveyDeployIdx = 3;
     SurveyDeployUserCommentCNT = 1;
     SurveyDeployUserCommentYN = N;
     SurveyDeployViewCNT = 0;
     SurveyPaperCDIdx = 10;
     SurveyPaperCDNM = "\Uc124\Ubb38\Uc9c0 \Ubd84\Ub9581>\Uc124\Ubb38\Uc9c0 \Ubd84\Ub9581-1";
     SurveyPaperIdx = 1;
     SurveyPaperNM = "\Ud14c\Uc2a4\Ud2b8 \Uc124\Ubb38\Uc9c03\Uc785\Ub2c8\Ub2e4.";
     */
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    cell.lb_Title.text = [dic objectForKey_YM:@"SurveyPaperNM"];
    
    cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~ %@", [Util makeDate:[dic objectForKey_YM:@"ResponseStartDate"]], [Util makeDate:[dic objectForKey_YM:@"ResponseEndDate"]]];
    
    if( [[dic objectForKey_YM:@"ResponseDTEndYN"] isEqualToString:@"Y"] )
    {
        //종료된거면
        cell.iv_Gubun.hidden = NO;
        cell.iv_Comment.image = BundleImage(@"main_icon_talk.png");
    }
    else
    {
        cell.iv_Gubun.hidden = YES;
        cell.iv_Comment.image = BundleImage(@"main_icon_talk2.png");
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     @property (nonatomic, assign) BOOL isAlreadyComment;
     @property (nonatomic, strong) NSString *str_ResponesYn;
     @property (nonatomic, strong) NSString *str_Idx;
     */
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    WikiDetailViewController *vc = [[WikiDetailViewController alloc]initWithNibName:@"WikiDetailViewController" bundle:nil];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SurveyPaperIdx"] integerValue]];
    if( [[dic objectForKey_YM:@"SurveyDeployUserCommentYN"] isEqualToString:@"Y"] )
    {
        vc.isAlreadyComment = YES;
    }
    else
    {
        vc.isAlreadyComment = NO;
    }
    vc.str_ResponesYn = [dic objectForKey_YM:@"ResponseYN"];

    [self.vc_Parent.navigationController pushViewController:vc animated:YES];

}


@end
