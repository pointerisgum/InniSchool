//
//  FeedVoteExtendCell.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 11..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "FeedVoteExtendCell.h"
#import "VoteQeustionCell.h"
#import "VoteQeustionGraphCell.h"

@implementation FeedVoteExtendCell

- (void)awakeFromNib {
    // Initialization code
    
    self.nSelectRow = -1;
    
    self.tbv_List.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tbv_List.layer.borderWidth = .5f;
    
    self.btn_Vote.layer.cornerRadius = 5.0f;
    
    self.ar_Number = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X",@"Y", @"Z",nil];
    
    self.ar_GraphColor = [NSArray arrayWithObjects:
                          [UIColor colorWithHexString:@"DB6765"],
                          [UIColor colorWithHexString:@"23B1AF"],
                          [UIColor colorWithHexString:@"68AB59"],
                          [UIColor colorWithHexString:@"77578A"],
                          [UIColor colorWithHexString:@"1EADEB"],
                          [UIColor colorWithHexString:@"589079"],
                          nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    //투표를 했고 시크릿 모드가 아닐때만 그래프를 보여준다
    if( self.isVote && self.isSecret == NO )
    {
        static NSString *CellIdentifier = @"VoteQeustionGraphCell";
        VoteQeustionGraphCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        //    /*
        //     PollCnt = 0;
        //     PollContent = "\Uae40\Uce58\Ucc0c\Uac1c";
        //     PollNum = 1;
        //     PollRate = 0;
        //     SNSFeedIdx = 13;
        //     SNSPollIdx = 4;
        //     UserChoiceYN = N;
        //     */
        
        NSDictionary *dic = self.ar_List[indexPath.row];
        
        cell.lb_Number.text = self.ar_Number[indexPath.row];
        
        cell.lb_Title.text = [dic objectForKey_YM:@"PollContent"];
        
        //그래프 맥스는 160
        
        NSInteger nCnt = [[dic objectForKey_YM:@"PollCnt"] integerValue];
        NSInteger nPer = [[dic objectForKey_YM:@"PollRate"] integerValue];
        
        CGRect frame = cell.iv_Graph.frame;
        frame.size.width = 160 * (nPer * 0.01);
        cell.iv_Graph.frame = frame;
        
        cell.lb_VoteCnt.textColor = cell.iv_Graph.backgroundColor = self.ar_GraphColor[indexPath.row];
        
        cell.lb_VoteCnt.text = [NSString stringWithFormat:@"%ld명(%ld%%)", nCnt, nPer];
        
        //    NSInteger nUserSelecIdx = [[dic objectForKey_YM:@"UserChoiceYN"] integerValue];
        
        
        return cell;
    }
    else
    {
        //나만 보기 모드이면 투표를 했어도 결과가 아닌 문항이 보여져야 한다
        static NSString *CellIdentifier = @"VoteQeustionCell";
        VoteQeustionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        //    /*
        //     PollCnt = 0;
        //     PollContent = "\Uae40\Uce58\Ucc0c\Uac1c";
        //     PollNum = 1;
        //     PollRate = 0;
        //     SNSFeedIdx = 13;
        //     SNSPollIdx = 4;
        //     UserChoiceYN = N;
        //     */
        
        NSDictionary *dic = self.ar_List[indexPath.row];
        
        cell.lb_Number.text = self.ar_Number[indexPath.row];
        
        cell.lb_Title.text = [dic objectForKey_YM:@"PollContent"];
        
        if( self.isVote == NO )
        {
            //투표를 안했다면 선택 항목을 바꿀수 있어야 한다
            cell.btn_Check.selected = NO;

            cell.btn_Choise.tag = indexPath.row;
            [cell.btn_Choise addTarget:self action:@selector(onSelecteRow:) forControlEvents:UIControlEventTouchUpInside];

            if( indexPath.row == self.nSelectRow )
            {
                cell.btn_Check.selected = YES;
            }
        }
        else
        {
            //선택을 했다면 기존 선택값 고정
            NSString *str_MyChoise = [dic objectForKey_YM:@"UserChoiceYN"];
            if( [str_MyChoise isEqualToString:@"Y"] )
            {
                cell.btn_Check.selected = YES;
            }
            else
            {
                cell.btn_Check.selected = NO;
            }
        }
        
        return cell;
    }

    return nil;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.isVote && self.isSecret == NO )
    {
        return 53.0f;
    }
    else
    {
        return 35.0f;
    }
    
    return 0;
}


- (void)onSelecteRow:(UIButton *)btn
{
    self.nSelectRow = btn.tag;
    
    [self.tbv_List reloadData];
}

@end
