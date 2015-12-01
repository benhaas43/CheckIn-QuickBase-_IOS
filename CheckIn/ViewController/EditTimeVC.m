//
//  EditTimeVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "EditTimeVC.h"

@interface EditTimeVC ()
{
    IBOutlet UIView * containerView1;
    IBOutlet UILabel * nameLabel;
    IBOutlet UILabel * dateLabel;
    IBOutlet UILabel * startLabel;
    IBOutlet UILabel * endLabel;
    
    IBOutlet UIView * containerView2;
    IBOutlet UILabel * totalLabel;
  
    IBOutlet UIView * checkInView;
    IBOutlet UIImageView * checkInImageView;
    IBOutlet UILabel * checkInTimeLabel;
    
    IBOutlet UIView * checkOutView;
    IBOutlet UIImageView * checkOutImageView;
    IBOutlet UILabel * checkOutTimeLabel;
    
    
    IBOutlet UIButton * saveButton;
    
    IBOutlet UIView * selectTimeView;
    IBOutlet UIDatePicker * datePicker;
    
    IBOutlet UILabel * selectViewTitleLabel;
    
    NSMutableArray * profileImages;
    
    BOOL isStartTimeEdit;
}


@end

@implementation EditTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initProfileView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initProfileView{
    
    containerView1.layer.cornerRadius = 5 ;
    containerView1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    containerView1.layer.borderWidth = 1.2f;
    
    containerView2.layer.cornerRadius = 5 ;
    containerView2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    containerView2.layer.borderWidth = 1.2f;
    saveButton.layer.cornerRadius = 5;
    
    checkInImageView.layer.cornerRadius  = 10;
    checkOutImageView.layer.cornerRadius  = 10;
    
    [selectTimeView setHidden:YES];
    
    nameLabel.text = self.worker.name;
    
    dateLabel.text = @"";
    startLabel.text = @"";
    endLabel.text = @"";
    totalLabel.text = @"";
    
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * dateFormatStr = @"EEE. MM/dd/yyyy";
    [formatter setDateFormat:dateFormatStr];
    
    if (self.worker.startTime != nil) {
        
        dateLabel.text = [formatter stringFromDate:self.worker.startTime];
    }
    
    if (self.worker.startPic != nil) {
        [checkInImageView setImage:self.worker.startPic];
    }
    
    if (self.worker.endPic != nil) {
        [checkOutImageView setImage:self.worker.endPic];
    }
    
   
    
    if (self.worker.picStartTime != nil) {
        checkInTimeLabel.text = [Worker fetchTimeStr:self.worker.picStartTime];
    }

    if (self.worker.picEndTime != nil) {
        checkOutTimeLabel.text = [Worker fetchTimeStr:self.worker.endTime];
        
    }
    
    
    [self updateDateView];
}

-(void)updateDateView
{
    
    if (self.worker.startTime != nil) {
        startLabel.text = [Worker fetchTimeStr:self.worker.startTime];
        
    }
    
    if (self.worker.endTime != nil) {
        
        endLabel.text = [Worker fetchTimeStr:self.worker.endTime];
        int interval = (int)[self.worker.endTime timeIntervalSinceDate:self.worker.startTime];
        totalLabel.text = [NSString stringWithFormat:@"%d:%d hrs", interval/3600, (interval%3600)/60]; //[NSString stringWithFormat:@"%.2f hrs", interval/3600.0f];
    }
    
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onSave:(id)sender{
    
    NSMutableDictionary * recordDic = [[NSMutableDictionary alloc] init];
    
    [recordDic setObject:[Worker fetchDateTimeStrWithEDT:self.worker.startTime] forKey:FIELD_CHECK_IN_START_TIME_FID]; // Start Time
    [recordDic setObject:[Worker fetchDateTimeStrWithEDT:self.worker.endTime] forKey:FIELD_CHECK_IN_END_TIME_FID]; // End Time
 //   [recordDic setObject:[self fetchHourWorked] forKey:FIELD_CHECK_IN_HOURWORKED_FID]; // HourWorked
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving...";

    
    [QuickBase QB_EditRecord:self.worker.idString toDBID:TABLE_TIMESHEET_DB_ID values:recordDic  callbackBlock:^(NSData *xml, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
           
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if ([[tempDic objectForKey:NO_ERROR_KEY] isEqualToString:NO_ERROR]) {
             //   NSString * rid = [tempDic objectForKey:@"rid"];
                [[[UIAlertView alloc] initWithTitle:@"Saved!" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];

                
            }
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }];
    
    [self onBack:nil];

}

-(IBAction)onCancelTime:(id)sender{
    [selectTimeView setHidden:YES];
}

-(IBAction)onSaveTime:(id)sender{
    
    if (isStartTimeEdit) {
        self.worker.startTime = datePicker.date;
    }else{
        self.worker.endTime = datePicker.date;
    }
    
    [self updateDateView];
    [selectTimeView setHidden:YES];
}

-(IBAction)onEditStartTime:(id)sender{
    isStartTimeEdit = YES;
    
    [selectTimeView setHidden:NO];
    selectViewTitleLabel.text = @"Start Time";
    datePicker.date = self.worker.startTime;
    datePicker.datePickerMode = UIDatePickerModeTime;
}


-(IBAction)onEditEndTime:(id)sender{
    
    isStartTimeEdit = NO;
    
    [selectTimeView setHidden:NO];
    selectViewTitleLabel.text = @"End Time";
    if (self.worker.endTime == nil) {
        datePicker.date = self.worker.startTime;
    }else{
        datePicker.date = self.worker.endTime;
    }
    
    datePicker.datePickerMode = UIDatePickerModeTime;
}


-(NSString *)fetchHourWorked{
    int interval = (int)[self.worker.endTime timeIntervalSinceDate:self.worker.startTime];
    return [NSString stringWithFormat:@"%d:%d", interval/3600, (interval%3600)/60];
}


@end
