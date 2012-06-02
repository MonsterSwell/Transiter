//
//  TransitProvider.h
//  Transiter
//
//  Created by Alper Çuğun on 1/6/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TransitProvider : NSObject {
    NSArray *stops;
}

@property (readonly) NSArray *stops;

- (id)init;

- (NSArray *)stopsWithinRegion:(MKCoordinateRegion)mkcRegion;

@end
