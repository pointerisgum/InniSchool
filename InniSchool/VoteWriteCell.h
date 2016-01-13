//
//  VoteWriteCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 14..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteWriteCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Number;
@property (nonatomic, weak) IBOutlet UITextField *tf_Question;
@property (nonatomic, weak) IBOutlet UIButton *btn_Delete;
@end
