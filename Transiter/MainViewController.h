//
//  ViewController.h
//  Transiter
//
//  Created by Alper Çuğun on 2/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Destination.h"

#import "BZFoursquare.h"

#define METERS_PER_MILE 1609.344

@interface MainViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, BZFoursquareRequestDelegate, BZFoursquareSessionDelegate> {
    
    NSMutableArray *visitList;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *visitList;
@property (strong, nonatomic) IBOutlet UITableView *searchTable;

@property (nonatomic, strong) BZFoursquare *foursquare;


@end
