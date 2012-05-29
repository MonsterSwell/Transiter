//
//  CurrentLocationAnnotation.h
//  Transiter
//
//  Created by Alper Çuğun on 29/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CurrentLocationAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
