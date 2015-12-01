//
//  ReviewVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "ReviewVC.h"
#import "WorkerDetailCell.h"

#import "EditTimeVC.h"
#import "CostCodeVC.h"

@interface ReviewVC ()<UITableViewDataSource, UITableViewDelegate, WorkerDetailCellDelegate, UIPickerViewDelegate, UIPickerViewDataSource >
{
    IBOutlet UILabel * dateLabel;
 
    IBOutlet UITableView * workerTableView;
    
    NSMutableArray * workerArray;
    
    NSDate * currentDate;
    
    NSIndexPath * selectedPath;
    
    IBOutlet UIView * costCodeCotainerView;
    IBOutlet UIView * costCodeSubView;
    
    IBOutlet UIPickerView * costCodePicker;
    
    IBOutlet UIButton * saveButton;
    IBOutlet UIButton * cancelButton;
    
    NSArray *costCodes;
}

@end

@implementation ReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentDate = [NSDate date];
    dateLabel.text = [self getDateLabelStr];
    
    costCodes = @[@"02 Project Management",@"12 Branch Rough",@"14 Branch Wire",@"15 Busduct",@"16 Cable Tray",@"27 Demolition",@"40 Feeder Rough",@"42 Feeder Wire",@"44 Fire Alarm",@"52 Generator",@"70 Lighting Fixtures",@"92 Supervision",@"96 Switchgear",@"102 Trenching",@"104 Trim",@"304 Drawings",@"308 Engineering",@"309 Job Site Storage Power",@"310 Filed Office Expense",@"312 Field Truck",@"318 Permit",@"323 Temporary Power",@"329 Warranty",@"698 Fire Stop"];
    
    [self initReviewView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [workerTableView reloadData];
}

-(void)initReviewView{
    workerTableView.delegate = self;
    workerTableView.dataSource = self;
    
    costCodePicker.delegate = self;
    costCodePicker.dataSource = self;
    
    saveButton.layer.cornerRadius = 5;
    saveButton.layer.borderColor = [UIColor redColor].CGColor;
    saveButton.layer.borderWidth = 1;
    
    cancelButton.layer.cornerRadius = 5;
    cancelButton.layer.borderColor = [UIColor colorWithRed:0 green:122/255.0f blue:1 alpha:1].CGColor;
    cancelButton.layer.borderWidth = 1;
    
    
    [costCodeCotainerView setHidden:YES];
    [workerTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self loadData];
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onNext:(id)sender{
    dateLabel.text = [self getDateLabelStr];
    currentDate = [currentDate dateByAddingTimeInterval:3600 * 24 * 1]; // adding 1 days
    [self loadData];
}

-(IBAction)onBefore:(id)sender{
    dateLabel.text = [self getDateLabelStr];
    currentDate = [currentDate dateByAddingTimeInterval:3600 * 24 * (-1)]; // adding 1 days
    [self loadData];
}

-(void)loadData{
    workerArray = [[NSMutableArray alloc] init];
    
    NSString * query = [NSString stringWithFormat:@"{'%@'.EX.'%@'}AND{'%@'.IR.'%@'}",FIELD_CHECK_IN_PROJECT_FID, APP.currentProject.projectID, FIELD_CHECK_IN_START_TIME_FID, [self getDateStr:currentDate]]; // Current Project ID
    
    NSString * clist = [NSString stringWithFormat:@"3.%@.%@.%@.%@.%@.%@.%@.%@",FIELD_CHECK_IN_WORKER_FID,FIELD_CHECK_IN_EMPLOYEE_NAME_FID,FIELD_CHECK_IN_START_TIME_FID, FIELD_CHECK_IN_END_TIME_FID, FIELD_CHECK_IN_PIC_START_FID, FIELD_CHECK_IN_PIC_END_FID, FIELD_CHECK_OUT_FLAG_FID, FIELD_CHECK_IN_COST_CODE_FID];

    [workerTableView reloadData];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";

    
    [QuickBase QB_DoQueryForDBID:TABLE_TIMESHEET_DB_ID clist:clist query:query callbackBlock:^(NSData *xml, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error && xml != nil) {
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
           
            
            if (tempDic != nil) {
                
                NSDictionary * records = [[tempDic objectForKey:@"table"] objectForKey:@"records"];
                
                if (records != nil) {
                    NSArray * tempArray = [records objectForKey:@"record"];
                    
                    if (tempArray != nil) {
                        
                        if ([tempArray isKindOfClass:[NSDictionary class]]) {
                            NSDictionary * tempClockInDic = (NSDictionary *)tempArray;
                            [self addWorkerToList:tempClockInDic];
                            
                        }else{
                            
                            for (NSDictionary * recordDic in tempArray) {
                                [self addWorkerToList:recordDic];
                            }
                        }
                    }
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [workerTableView reloadData];
                
                return ;
            }
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            
            return ;
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }];

    
}

-(void)addWorkerToList:(NSDictionary *)recordDic{
    
    Worker * tempWorker = [[Worker alloc] init];
    [tempWorker initWithEmployeeDictionary:recordDic];
    
    [workerArray addObject:tempWorker];
}

#pragma  mark UITableView DataSource And Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    WorkerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workerDetailCell"];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    [cell renderCellWithWorker:[workerArray objectAtIndex:indexPath.row]];
    
    return  cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (workerArray != nil) {
        return  [workerArray count];
    }

    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


#pragma mark WorkerDetailCell Delegate

-(void)editTime:(NSIndexPath *)indexpath
{
    selectedPath = indexpath;
    [self performSegueWithIdentifier:@"gotoEditTime" sender:nil];
}

-(void)editCostCode:(NSIndexPath *)indexpath
{
    selectedPath = indexpath;
    [self showCostCodePicker];
    
   // [self performSegueWithIdentifier:@"gotoEditCostCode" sender:nil];
}


-(NSString *)getDateStr:(NSDate *)date{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    
    return [dateFormatter stringFromDate:date];
}

-(NSString *)getDateLabelStr{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE. MM/dd/yyyy"];
    
    return [dateFormatter stringFromDate:currentDate];
}

#pragma mark UIPickerView


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (costCodes != nil) {
        return [costCodes count];
    }
    
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [costCodes objectAtIndex:row];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark CostCode Action

-(IBAction)onSave:(id)sender{
    NSInteger tempIndex = [costCodePicker selectedRowInComponent:0];
    NSString * selectedCostCode = [costCodes objectAtIndex:tempIndex];
    
    Worker *tempWorker = [workerArray objectAtIndex:selectedPath.row];
    [self updateCostCodeToQB:tempWorker withCostCode:selectedCostCode];
    
    }

-(IBAction)onCancel:(id)sender{
    [self hideCostCodePicker];
    
}

-(void)updateCostCodeToQB:(Worker *)worker withCostCode:(NSString *)costCode{
    NSMutableDictionary * recordDic = [[NSMutableDictionary alloc] init];
    
    [recordDic setObject:costCode forKey:FIELD_CHECK_IN_COST_CODE_FID]; // Cost Code
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving...";
    
    [QuickBase QB_EditRecord:worker.idString toDBID:TABLE_TIMESHEET_DB_ID values:recordDic  callbackBlock:^(NSData *xml, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
          
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if ([[tempDic objectForKey:NO_ERROR_KEY] isEqualToString:NO_ERROR]) {
              //  NSString * rid = [tempDic objectForKey:@"rid"];
                worker.cost_code = costCode;
                WorkerDetailCell * tempCell = (WorkerDetailCell *) [workerTableView cellForRowAtIndexPath:selectedPath];
                tempCell.codeLabel.text = costCode;
                [self hideCostCodePicker];
            }
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }];

}

-(void)showCostCodePicker{
    
    [costCodeCotainerView setHidden:NO];
    [costCodeCotainerView setAlpha:0.0];
    Worker * tempWorker = [workerArray objectAtIndex:selectedPath.row];
    NSInteger tempIndex = 0;
    if (tempWorker.cost_code != nil && ![tempWorker.cost_code isEqualToString:@""]) {
        tempIndex = [costCodes indexOfObject:tempWorker.cost_code];
    }
    
    [costCodePicker selectRow:tempIndex inComponent:0 animated:NO];
    
    [UIView animateWithDuration:0.3 animations:^{

        [costCodeCotainerView setAlpha:1.0f];
    }];
}

-(void)hideCostCodePicker{
    [UIView animateWithDuration:0.3 animations:^{
        [costCodeCotainerView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        [costCodeCotainerView setHidden:YES];
       
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"gotoEditCostCode"]) {
        CostCodeVC * vc = (CostCodeVC *)(segue.destinationViewController);
        vc.worker = [workerArray objectAtIndex:selectedPath.row];
    }else if([segue.identifier isEqualToString:@"gotoEditTime"]){
        EditTimeVC * vc = (EditTimeVC *)(segue.destinationViewController);
        vc.worker = [workerArray objectAtIndex:selectedPath.row];
    }
}


@end
