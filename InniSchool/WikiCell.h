//
//  WikiCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WikiCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Category;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_ViewCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_CommentCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_End;
@end
