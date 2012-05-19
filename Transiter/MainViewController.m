//
//  ViewController.m
//  Transiter
//
//  Created by Alper Çuğun on 2/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize mapView;
@synthesize searchBar;

@synthesize visitList;
@synthesize searchTable;

@synthesize foursquare;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.281516;
    zoomLocation.longitude= -76.580806;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1000.0, 1000.0);
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    // 4
    [mapView setRegion:adjustedRegion animated:YES];
    
    
    self.visitList = [[NSMutableArray alloc] init];
    
    [self.visitList addObject:[[Destination alloc] init]];

    [self.searchTable reloadData];
    
    
    // Setup foursquare object
    self.foursquare = [[BZFoursquare alloc] initWithClientID:@"PE44U5EYTFAENZDA1JRMWVXA3EE22WCTOAZX1TFBLPWSA2GA" callbackURL:@"transiter://foursquare"];
    self.foursquare.version = @"20111119";
    self.foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    self.foursquare.sessionDelegate = self;
    
#ifndef DEBUG
    // Directly go for authentication
    if (![foursquare isSessionValid]) {
        NSLog(@"Going for foursquare auth");
        
        [foursquare startAuthorization];
    }
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UISearchDisplayDelegate methods
//
//- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
//    // TODO show the current hit list of venues
//    
//    // Foursquare venues should be autocompleted from where you already have been (read history)
//    NSLog(@"in begin search");
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    
//    self.visitListTable.hidden = YES;
//    
//    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(mockSearch:) userInfo:searchString repeats:NO];
//    return YES;
//}
//
//- (void)mockSearch:(NSTimer*)timer {
//    NSLog(@"Mock search called");
//    
//    [_data removeAllObjects];
//    int count = 1 + random() % 20;
//    for (int i = 0; i < count; i++) {
//        [_data addObject:timer.userInfo];
//    }
//    [self.searchDisplayController.searchResultsTableView reloadData];
//}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    NSLog(@"begun editing %@", self.searchBar.showsScopeBar);

    self.searchTable.hidden = NO;
//    self.searchDisplayController.searchContentsController.
    
    self.searchBar.showsCancelButton = YES;
    
    [self.searchTable reloadData];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    // Show visit list here
    
    [self.searchTable reloadData];
    
    self.searchTable.hidden = !self.searchTable.hidden;
    
    if (!self.searchTable.hidden) {
        [self.searchBar becomeFirstResponder];
    } else {
        [self.searchBar resignFirstResponder];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchTable.hidden = YES;
    [self.searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchTable.hidden = YES;
    
    self.searchBar.showsCancelButton = NO;
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"List of places to visit";
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"rows %d", visitList.count);
    
    return [visitList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"VisitListCell";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *visitLocation = [visitList objectAtIndex:indexPath.row];
    
    NSLog(@"location %@", visitLocation);
    
    cell.textLabel.text = visitLocation;
    return cell;
}

#pragma mark - BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    
}

#pragma mark - BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    NSLog(@"foursquare access token %@", foursquare.accessToken);
    
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"Foursquare auth failed");
}

@end
