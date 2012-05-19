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
    
    _data = [[NSMutableArray alloc] initWithCapacity:1];
    
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

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    // TODO show the current hit list of venues
    
    // Foursquare venues should be autocompleted from where you already have been (read history)
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(mockSearch:) userInfo:searchString repeats:NO];
    return NO;
}

- (void)mockSearch:(NSTimer*)timer {
    NSLog(@"Mock search called");
    
    [_data removeAllObjects];
    int count = 1 + random() % 20;
    for (int i = 0; i < count; i++) {
        [_data addObject:timer.userInfo];
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"begun editing %@", self.searchBar.showsScopeBar);
    
    
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
    cell.textLabel.text = [NSString stringWithFormat:@"Row %d: %@", indexPath.row, [_data objectAtIndex:indexPath.row]];
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
