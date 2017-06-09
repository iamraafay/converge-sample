//
//  AccountSettingsViewController.m
//  Commerce Sample
//
//  Created by Rapoport, Julia on 11/20/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//


#import "AccountSettingsViewController.h"
#import "Flavor.h"
#import "ServerNames.h"

@interface AccountSettingsViewController ()

@property int labelVerticalPosition;
@property int textfieldVerticalPosition;

@property id<ECLAccountDelegate> delegate;
@property BOOL addedViews;

@end

@implementation AccountSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *serverSaved = [[_mainViewController flavor] serverType];
    
    ECLServerType serverTypes = [_mainViewController account].supportedServerTypes;
    
    [_serverTypeControl removeAllSegments];
    NSUInteger index = 0;
    NSUInteger savedIndex = 0;
    if ([self addServerTypeIfNeeded:ECLServerType_Demo supportedServerTypes:serverTypes serverSaved:serverSaved title:SERVER_NAME_DEMO index:&index]) {
        savedIndex = index - 1;
    }
    if ([self addServerTypeIfNeeded:ECLServerType_Production supportedServerTypes:serverTypes serverSaved:serverSaved title:SERVER_NAME_PRODUCTION index:&index]) {
        savedIndex = index - 1;
    }
    if ([self addServerTypeIfNeeded:ECLServerType_Alpha supportedServerTypes:serverTypes serverSaved:serverSaved title:SERVER_NAME_ALPHA index:&index]) {
        savedIndex = index - 1;
    }
    if ([self addServerTypeIfNeeded:ECLServerType_QA supportedServerTypes:serverTypes serverSaved:serverSaved title:SERVER_NAME_QA index:&index]) {
        savedIndex = index - 1;
    }
    if ([self addServerTypeIfNeeded:ECLServerType_UAT supportedServerTypes:serverTypes serverSaved:serverSaved title:SERVER_NAME_UAT index:&index]) {
        savedIndex = index - 1;
    }
    if ([self addServerTypeIfNeeded:ECLServerType_Development supportedServerTypes:serverTypes serverSaved:serverSaved title:SERVER_NAME_DEV index:&index]) {
        savedIndex = index - 1;
    }
    [self.serverTypeControl setSelectedSegmentIndex:savedIndex];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_addedViews == NO) {
        _addedViews = YES;
        NSMutableArray *views = [_mainViewController.flavor createSettingsView:self.viewContainer.frame.size.width];
        for (UIView *view in views){
            [self.viewContainer addSubview:view];
        }
    }
}

- (BOOL)addServerTypeIfNeeded:(ECLServerType)serverType supportedServerTypes:(ECLServerType)supportedServerTypes serverSaved:(NSString *)serverSaved title:(NSString *)title index:(NSUInteger *)index {
    BOOL matches = NO;
    if ((supportedServerTypes & serverType) != 0) {
        if ([serverSaved caseInsensitiveCompare:title] == NSOrderedSame) {
            matches = YES;
        }
        [_serverTypeControl insertSegmentWithTitle:title atIndex:(*index)++ animated:NO];
    }
    return matches;
}

- (void) passMainViewController: (MainViewController *) controller{
    _mainViewController = controller;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonTapped{
    for(UIView *view in [self.viewContainer subviews]){
        if ([view class] == [UITextField class]) {
            UITextField *field = (UITextField *)view;
            [[_mainViewController flavor] setUserDefault:[field restorationIdentifier] withValue:[field text]];
        }
    }
    NSInteger serverTypeIndex = self.serverTypeControl.selectedSegmentIndex;
    NSString *server = [_serverTypeControl titleForSegmentAtIndex:serverTypeIndex];
    [[_mainViewController flavor] setServerType:server];
    [[_mainViewController account] propertiesDidChange:_mainViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
*/

@end
