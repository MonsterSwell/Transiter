//
//  ViewController.h
//  Transiter
//
//  Created by Alper Çuğun on 2/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Destination.h"
#import "CurrentLocationAnnotationView.h"

#import "BZFoursquare.h"

#define METERS_PER_MILE 1609.344

@interface MainViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, BZFoursquareRequestDelegate, BZFoursquareSessionDelegate,
    CLLocationManagerDelegate, MKMapViewDelegate> {
    
    NSMutableArray *destinationList;
    NSMutableArray *searchResultList;
    
    BZFoursquareRequest *fsRequest;
    NSDictionary *fsMeta;
    NSArray *fsNotifications;
    NSDictionary *fsResponse;
        
    CLLocationManager *locationManager;
    CLLocationCoordinate2D location;
        
    CurrentLocationAnnotationView *claView;
        
    NSMutableArray *overlays;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *destinationList;
@property (strong, nonatomic) NSMutableArray *searchResultList;

@property (strong, nonatomic) IBOutlet UITableView *searchTable;

@property (nonatomic, strong) BZFoursquare *foursquare;

@property(nonatomic,strong) BZFoursquareRequest *fsRequest;
@property(nonatomic,copy) NSDictionary *fsMeta;
@property(nonatomic,copy) NSArray *fsNotifications;
@property(nonatomic,copy) NSDictionary *fsResponse;

@property (readwrite) CLLocationCoordinate2D location;

@property (nonatomic, strong) CurrentLocationAnnotationView *claView;

@property (strong, nonatomic) NSMutableArray *overlays;

@end
