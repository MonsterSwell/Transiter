//
//  CurrentLocationAnnotation.m
//  Transiter
//
//  Created by Alper Çuğun on 29/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import "CurrentLocationAnnotation.h"

@implementation CurrentLocationAnnotation

@synthesize coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}

@end
