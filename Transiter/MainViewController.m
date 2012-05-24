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

@synthesize destinationList;
@synthesize searchResultList;

@synthesize searchTable;

@synthesize foursquare;

@synthesize fsRequest;
@synthesize fsMeta;
@synthesize fsNotifications;
@synthesize fsResponse;

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
    
    
    self.destinationList = [[NSMutableArray alloc] init];
    self.searchResultList = [[NSMutableArray alloc] init];
    
    [self.destinationList addObject:[[Destination alloc] initWithName:@"Work"]];
    [self.destinationList addObject:[[Destination alloc] initWithName:@"Home"]];
    
    [self.searchResultList addObject:[[Destination alloc] initWithName:@"Bar"]];
    
//    [self.searchTable reloadData];
    
    
    // Setup foursquare object
    self.foursquare = [[BZFoursquare alloc] initWithClientID:@"PE44U5EYTFAENZDA1JRMWVXA3EE22WCTOAZX1TFBLPWSA2GA" callbackURL:@"transiter://foursquare"];
    self.foursquare.version = @"20111119";
    self.foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    self.foursquare.sessionDelegate = self;
    
    // Directly go for authentication
    if (![foursquare isSessionValid]) {
        NSLog(@"Going for foursquare auth");
        
        [foursquare startAuthorization];
    }
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

- (void)cancelRequest {
    if (self.fsRequest) {
        self.fsRequest.delegate = nil;
        [self.fsRequest cancel];
        self.fsRequest = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)prepareForRequest {
    [self cancelRequest];
    self.fsMeta = nil;
    self.fsNotifications = nil;
    self.fsResponse = nil;
}

- (void)searchVenues {
    [self prepareForRequest];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"40.7,-74", @"ll", nil];
    self.fsRequest = [self.foursquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [self.fsRequest start];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    NSLog(@"begun editing %@", self.searchBar.showsScopeBar);

    self.searchTable.hidden = NO;
//    self.searchDisplayController.searchContentsController.
    
    self.searchBar.showsCancelButton = YES;
    
    [self searchVenues];
    
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Add a destination";
    } else {
        return @"List of places to visit";
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return [searchResultList count];
    } else {
        return [destinationList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    Destination *destination;
    
    if (indexPath.section == 0) {
        CellIdentifier = @"SearchCell";
        destination = [searchResultList objectAtIndex:indexPath.row];
    } else {
        CellIdentifier = @"DestinationCell";
        destination = [destinationList objectAtIndex:indexPath.row];
    }
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // NSLog(@"location %@", destination.name);
    
    cell.textLabel.text = destination.name;
    return cell;
}

#pragma mark - BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    self.fsMeta = request.meta;
    self.fsNotifications = request.notifications;
    self.fsResponse = request.response;
    self.fsRequest = nil;
    
    NSLog(@"%@", self.fsResponse);
    
    // TODO update tableview, with search results
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
