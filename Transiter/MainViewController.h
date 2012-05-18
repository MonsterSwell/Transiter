//
//  ViewController.h
//  Transiter
//
//  Created by Alper Çuğun on 2/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "BZFoursquare.h"

#define METERS_PER_MILE 1609.344

@interface MainViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, BZFoursquareRequestDelegate, BZFoursquareSessionDelegate> {
    
    NSMutableArray *_data;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) BZFoursquare *foursquare;


@end
