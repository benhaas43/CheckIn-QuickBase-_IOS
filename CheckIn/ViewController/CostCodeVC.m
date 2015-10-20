//
//  CostCodeVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "CostCodeVC.h"

@interface CostCodeVC ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    IBOutlet UISearchBar *codeSearchBar;
    IBOutlet UITableView * codeTableView;
    
    NSMutableArray * codeArray;
    
    NSArray * searchArray;
    
    BOOL isSearchMode;
}

@end

@implementation CostCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCodeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initCodeView{
    codeSearchBar.delegate = self;
    
    codeTableView.delegate = self;
    codeTableView.dataSource = self;
    
    [codeTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self loadData];
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadData{
    codeArray = [[NSMutableArray alloc] init];
    searchArray = [NSArray array];
    
}

#pragma  mark UITableView DataSource And Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"codeCell"];
    
//    id tempObj;
//    if (isSearchMode) {
//        tempObj = [searchArray objectAtIndex:indexPath.row];
//    }else{
//        tempObj = [codeArray objectAtIndex:indexPath.row];
//    }
    
    
    UILabel *  titleLabel = (UILabel *)[cell viewWithTag:111];
    
    titleLabel.text = [NSString stringWithFormat:@"Cost Code %ld", indexPath.row];
    return  cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (isSearchMode) {
        if (searchArray != nil) {
            return  [searchArray count];
        }
    }else{
        return 10;
        if (codeArray != nil) {
            return  [codeArray count];
        }
    }
    return 0;

}



#pragma mark UISearchBar Delegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    isSearchMode = YES;
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    isSearchMode = NO;
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO];
    
    [searchBar resignFirstResponder];
    
    [codeTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearchMode = YES;
    
    [self fetchSearchArray:searchText];
    
    [codeTableView reloadData];
}

-(void)fetchSearchArray:(NSString *)searchKey{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", searchKey];
    
    searchArray = [codeArray filteredArrayUsingPredicate:predicate];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
