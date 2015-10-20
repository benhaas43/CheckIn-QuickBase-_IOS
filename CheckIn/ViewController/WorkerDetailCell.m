//
//  WorkerDetailCell.m
//  CheckIn
//
//  Created by heliumsoft on 8/27/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "WorkerDetailCell.h"


@implementation WorkerDetailCell

- (void)awakeFromNib {
    // Initialization code
    
    self.profileImageView.layer.cornerRadius = 10;
    editTimeButton.layer.cornerRadius = 5;
    containerView.layer.cornerRadius = 5;
    containerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    containerView.layer.borderWidth = 1.2f;
    
    [selectView.layer setBorderColor:[UIColor grayColor].CGColor];
    [selectView.layer setBorderWidth:1];
    [selectView.layer setCornerRadius:3];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)onEditTime:(id)sender{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(editTime:)]) {
        [self.delegate editTime:self.indexPath];
    }
}

-(IBAction)onEditCostCode:(id)sender{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(editCostCode:)]) {
        [self.delegate editCostCode:self.indexPath];
    }

}

-(void)renderCellWithWorker:(Worker *)worker
{
    
    self.nameLabel.text = worker.name;
    [self.profileImageView setImage:[UIImage imageNamed:@"Worker"]];
    
    if (worker.startPic != nil) {
        [self.profileImageView setImage:worker.startPic];
    }else{
    
        NSString * checkInImageUrlStr = [NSString stringWithFormat:@"%@/%@/a/r%@/e%@/v0",APP_BASE_URL, TABLE_TIMESHEET_DB_ID, worker.idString, FIELD_CHECK_IN_PIC_FID];
        NSURL * imageURL = [NSURL URLWithString:checkInImageUrlStr];
        [self.profileImageView setImageURL:imageURL];
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * dateFormatStr = @"EEE. MM/dd/yyyy";
    NSString * timeFormatStr = @"hh:mm a";
    
    [formatter setDateFormat:dateFormatStr];
    
    self.dateLabel.text = @"";
    self.startLabel.text = @"";
    self.endLabel.text = @"";
    self.totalLabel.text = @"";
    
    if (worker.startTime != nil) {
        
        self.dateLabel.text = [formatter stringFromDate:worker.startTime];
    }
    
    [formatter setDateFormat:timeFormatStr];
    if (worker.startTime != nil) {
        self.startLabel.text = [formatter stringFromDate:worker.startTime];
        
    }
    
    if (worker.endTime != nil) {
        
        self.endLabel.text = [formatter stringFromDate:worker.endTime];
        int  interval = (int)[worker.endTime timeIntervalSinceDate:worker.startTime];
        self.totalLabel.text = [NSString stringWithFormat:@"%d:%d hrs", interval/3600, (interval%3600)/60]; // [NSString stringWithFormat:@"%.2f hrs", interval/3600.0f];
    }
    
    self.codeLabel.text = worker.cost_code;
}

@end
