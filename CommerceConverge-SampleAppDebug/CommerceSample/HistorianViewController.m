//
//  HistorianViewController.m
//  Commerce Sample
//
//  Created by Rapoport, Julia on 10/16/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "HistorianViewController.h"
#import "MainViewController.h"
#import "FlavorIncludes.h"
#import "TransactionDetailViewController.h"
#import <CommerceDataTypes/CommerceDataTypes.h>

@interface HistorianViewController () <ECLTransactionSearchDelegate>

@property id<ECLHistorianProtocol> historian;
@property id<ECLTransactionSearchCriteriaProtocol> searchCriteria;
@property ECLTransactionSearchResults *searchResults;
@property NSIndexPath *selectedIndex;
-(BOOL)textFieldShouldReturn:(UITextField*)textField;

@end

@implementation HistorianViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _historian = [_account historian];
    _searchCriteria = [_historian transactionSearchCriteria];

    // Do any additional setup after loading the view.
    if ([_searchCriteria availabilityOfSearchingForFirstName]== ECLCriteriaAvailability_Never) {
        _firstNameLabel.hidden = YES;
        _firstNameTextField.hidden = YES;
    }
    if ([_searchCriteria availabilityOfSearchingForTaxed] == ECLCriteriaAvailability_Never) {
        _taxedLabel.hidden = YES;
        _taxedSwitch.hidden = YES;
    }
    if ([_searchCriteria availabilityOfSearchingForHavingGratuity] == ECLCriteriaAvailability_Never) {
        _tippedLabel.hidden = YES;
        _tippedSwitch.hidden = YES;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy"];
    if (_searchCriteria.from != nil) {
        _fromLabel.text = [df stringFromDate:_searchCriteria.from];
    }
    if (_searchCriteria.to != nil) {
        _toLabel.text = [df stringFromDate:_searchCriteria.to];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideKeyboard];
    
}

-(void)hideKeyboard{
    [self.lastFourDigits resignFirstResponder];
    [self.fromLabel resignFirstResponder];
    [self.toLabel resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(IBAction)searchHistory{
    [self hideKeyboard];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy"];
    NSDate *toDate = [df dateFromString:_toLabel.text];
    NSDate *fromDate = [df dateFromString:_fromLabel.text];
    
    [_searchCriteria setLastFourDigitsOfCardNumber:_lastFourDigits.text];
    [_searchCriteria setFrom:fromDate];
    [_searchCriteria setTo:toDate];
    if (_taxedSwitch.isOn) {
        [_searchCriteria setTaxFilter:YES];
    } else {
        [_searchCriteria setTaxFilter:NO];
    }
    if (_tippedSwitch.isOn) {
        [_searchCriteria setTipFilter:YES];
    } else {
        [_searchCriteria setTipFilter:NO];
    }
    [_searchCriteria setFirstName:_firstNameTextField.text];
    
    [_historian search:_searchCriteria delegate:self];
}

-(void) accountFromPastView:(id<ECLAccountProtocol>)account{
    [self setAccount:account];
}

- (void)transactionSearchDidSucceed:(id<ECLTransactionSearchCriteriaProtocol>)criteria results:(ECLTransactionSearchResults *)results{
    _searchResults = results;
    [_errorLabel setHidden:YES];
    [_resultsTable reloadData];
    [_resultsTable setHidden:NO];
}
- (void)transactionSearchDidFail:(id<ECLTransactionSearchCriteriaProtocol>)criteria error:(NSError *)error{
    [_errorLabel setHidden:NO];
    _errorLabel.text = error.debugDescription;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return [_searchResults count];
}


- (UIFont *)fontForCell {
    return [UIFont boldSystemFontOfSize:18.0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = @"1\n2\n3\n4";
    UIFont *cellFont = [self fontForCell];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];//[_resultsTable cellForRowAtIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy HH::mm:ss"];
    ECLTransactionSearchResult *result = _searchResults[indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"Date: %@\n%@\n%@\nAmount: %@", [df stringFromDate:result.utcDateTime], [ECLDebugDescriptions descriptionOfTransactionType:result.type], [ECLDebugDescriptions descriptionOfTenderType:result.tenderType], [ECLMoneyUtil stringFromMoney:result.amount withSymbol:YES withSeparators:NO]]];
     
    [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    cell.textLabel.font = [self fontForCell];
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath;
    [self performSegueWithIdentifier:@"transactionDetailSegue" sender:self];
}


//#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"transactionDetailSegue"]) {
        TransactionDetailViewController *transactionViewController = (TransactionDetailViewController *)segue.destinationViewController;
        [transactionViewController accountFromPastView:_account];
        [transactionViewController transactionToDisplay:[_searchResults objectAtIndexedSubscript:_selectedIndex.row]];
        transactionViewController.receiptFeatures = _receiptFeatures;
    }
}

- (IBAction)unwindToHistorian:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
