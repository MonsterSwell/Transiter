//
//  Destination.h
//  Transiter
//
//  Created by Alper Çuğun on 19/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Destination : NSObject <MKAnnotation> {
    NSString *title;
    NSString *address;
    
    NSString *fsid;
    
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, retain) NSString *address;

@property (nonatomic, retain) NSString *fsid;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)theTitle;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
