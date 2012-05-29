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

@synthesize cla;
@synthesize claView;

@synthesize overlays;

- (void)viewDidLoad
{
    [super viewDidLoad];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D zoomLocation; // TODO cache the user's last known location
    zoomLocation.latitude = 52.492706;
    zoomLocation.longitude= 13.354797;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1000.0, 1000.0);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    [mapView setRegion:adjustedRegion animated:YES];
    
//    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.destinationList = [[NSMutableArray alloc] init];
    self.searchResultList = [[NSMutableArray alloc] init];
    
    self.overlays = [[NSMutableArray alloc] init];
    
    
    [self updateViews];
    
    // Setup foursquare object
    // See foursquare example: https://github.com/baztokyo/foursquare-ios-api/blob/master/FSQDemo/FSQDemo/FSQMasterViewController.m
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateViews {
    if (destinationList.count) {
        Destination *dest = [destinationList objectAtIndex:0];
        self.searchBar.placeholder = dest.title;
    
        // Update the MKMapViews to reflect all the destinations in the list
        
        
        // Add the overlays to the map
        
    } else {
        self.searchBar.placeholder = @"Add places to go…";
    }
}

- (void)redrawOverlays {
//    NSLog(@"In redraw overlays");
    
    // TODO maybe not redraw all, but for now
    
    [mapView removeOverlays:overlays];
    
    for (int i = 0; i < destinationList.count; i++) {
        CLLocationCoordinate2D coords[2];
        
        if (i == 0) {
            coords[0] = self.cla.coordinate;
            
            Destination *dest2 = [destinationList objectAtIndex:0];
            coords[1] = dest2.coordinate;
        } else {
            Destination *dest = [destinationList objectAtIndex:i-1];
            coords[0] = dest.coordinate;
            
            Destination *dest2 = [destinationList objectAtIndex:i];
            coords[1] = dest2.coordinate;
        }
        
        MKPolyline *line = [MKPolyline polylineWithCoordinates:coords count:2];
        
        [mapView addOverlay:line];
        [overlays addObject:line];
    }
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
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f,%f", self.cla.coordinate.latitude, self.cla.coordinate.longitude], @"ll", self.searchBar.text, @"query", nil];
    
    self.fsRequest = [self.foursquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [self.fsRequest start];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location manager location: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.cla.coordinate, 1000.0, 1000.0);
//    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
//    [mapView setRegion:adjustedRegion animated:YES];
    
    [mapView setCenterCoordinate:newLocation.coordinate];
    
    if (self.cla) {
        self.cla.coordinate = newLocation.coordinate;
        [self.claView setNeedsDisplay];
        
        // TODO check if we're there yet
        if ([self.claView hasTarget] && [self.claView distanceToTarget] < 50) {
            // Remove this destination, set the target as the next destination
            [self.destinationList removeObjectAtIndex:0];
            
            Destination *newDest = [self.destinationList objectAtIndex:0];
            [self.claView updateTarget:newDest.coordinate];
            
            // TODO check in on foursquare on the venue
        }
    } else {
        self.cla = [[CurrentLocationAnnotation alloc] initWithLocation:newLocation.coordinate];
        [self.mapView addAnnotation:self.cla];
    }
    
    // Update overlay
    [self redrawOverlays];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"MapView User location: %f,%f", self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[CurrentLocationAnnotation class]]) {
        self.claView = [[CurrentLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        return self.claView;
    }
    
    static NSString *annIdentifier = @"DestinationAnnotation";
    
    MKAnnotationView *aView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:annIdentifier];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annIdentifier];
        
        aView.canShowCallout = YES;
    }
    
    return aView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *aView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
        
        aView.strokeColor = [UIColor blueColor];
        aView.lineWidth = 2;
        
        return aView;
    } else {
        return nil;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchTable.hidden = NO;
    
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchVenues];
    
    // TODO if we can speed search up, do it on every textChange
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
    
    [self cancelRequest];
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
        if (searchResultList.count == 0) {
            return @"Search for a destination";
        } else {
            return @"Add a destination";
        }   
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the data
        [destinationList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateViews];
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
    
    cell.textLabel.text = destination.title;
    cell.detailTextLabel.text = destination.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // Add the selection to the destination list
        Destination *dest = [searchResultList objectAtIndex:indexPath.row];
        
        [destinationList addObject:dest];
        [mapView addAnnotation:dest];
        
        if (![self.claView hasTarget]) {
            Destination *target = [destinationList objectAtIndex:0];
            [claView updateTarget:target.coordinate];
        }
        
        [self redrawOverlays];
        
        // Empty the search results
        [searchResultList removeAllObjects];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [tableView reloadData];
        
        [self updateViews];
        
        self.searchBar.text = @"";
    }
}

#pragma mark - BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    self.fsMeta = request.meta;
    self.fsNotifications = request.notifications;
    self.fsResponse = request.response;
    self.fsRequest = nil;
    
    // Foursquare API call https://developer.foursquare.com/docs/venues/search
    NSArray *venues = [self.fsResponse objectForKey:@"venues"];
    
    [searchResultList removeAllObjects];
    
    for (NSDictionary *venue in venues) {
        NSString *fsid = [venue objectForKey:@"id"];
        NSString *name = [venue objectForKey:@"name"];
        
        NSDictionary *loc = [venue objectForKey:@"location"];
        
        CLLocationCoordinate2D coord;
        coord.latitude = [[loc objectForKey:@"lat"] doubleValue];
        coord.longitude = [[loc objectForKey:@"lng"] doubleValue];
        
        NSString *address = [loc objectForKey:@"address"];
        NSString *city = [loc objectForKey:@"city"];
//        NSString *country = [loc objectForKey:@"Germany"];
//        int distance = (int)[loc objectForKey:@"distance"];
        
        Destination *dest = [[Destination alloc] initWithTitle:name];
        dest.fsid = fsid;
        dest.coordinate = coord;
        dest.address = [NSString stringWithFormat:@"%@, %@", address, city];
        
        [searchResultList addObject:dest];
    }
    
    [self.searchTable reloadData];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    
}

#pragma mark - BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    NSLog(@"foursquare access token %@", self.foursquare.accessToken);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.foursquare.accessToken forKey:@"fstoken"];
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"Foursquare auth failed");
}

@end
