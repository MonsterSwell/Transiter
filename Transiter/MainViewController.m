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

@synthesize location;

- (void)viewDidLoad
{
    [super viewDidLoad];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fsToken = [defaults stringForKey:@"fstoken"];
    self.foursquare.accessToken = fsToken;
    
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
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f,%f", self.location.latitude, self.location.longitude], @"ll", self.searchBar.text, @"query", nil];
    
    self.fsRequest = [self.foursquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [self.fsRequest start];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.location = newLocation.coordinate;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.location, 1000.0, 1000.0);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    [mapView setRegion:adjustedRegion animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    NSLog(@"begun editing %@", self.searchBar.showsScopeBar);

    self.searchTable.hidden = NO;
//    self.searchDisplayController.searchContentsController.
    
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchVenues];
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
    cell.detailTextLabel.text = destination.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // Add the selection to the destination list
        [destinationList addObject:[searchResultList objectAtIndex:indexPath.row]];
        
        // Empty the search results
        [searchResultList removeAllObjects];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [tableView reloadData];
    }
}

#pragma mark - BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    self.fsMeta = request.meta;
    self.fsNotifications = request.notifications;
    self.fsResponse = request.response;
    self.fsRequest = nil;
    
    // Foursquare API call https://developer.foursquare.com/docs/venues/search
    NSLog(@"request finished");
    NSArray *venues = [self.fsResponse objectForKey:@"venues"];
    
    for (NSDictionary *venue in venues) {
        NSLog(@"%@", venue);
        NSString *fsid = [venue objectForKey:@"id"];
        NSString *name = [venue objectForKey:@"name"];
        
        NSDictionary *loc = [venue objectForKey:@"location"];
        
        NSLog(@"location: %@", loc);
        
        NSString *lat = [loc objectForKey:@"lat"];
        NSString *lng = [loc objectForKey:@"lng"];
        
        NSString *address = [loc objectForKey:@"address"];
        NSString *city = [loc objectForKey:@"city"];
        NSString *country = [loc objectForKey:@"Germany"];
        NSInteger distance = [loc objectForKey:@"distance"];
        
        Destination *dest = [[Destination alloc] initWithName:name];
        dest.fsid = fsid;
        dest.lat = lat;
        dest.lng = lng;
        dest.address = [NSString stringWithFormat:@"%@, %@", address, city];
        
        NSLog(@"added object %@", name);
        [searchResultList addObject:dest];
    }
    
    [self.searchTable reloadData];
    
    // TODO update tableview, with search results
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    
}

#pragma mark - BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    NSLog(@"foursquare access token %@", foursquare.accessToken);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:foursquare.accessToken forKey:@"fstoken"];
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"Foursquare auth failed");
}

@end
