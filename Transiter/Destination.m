//
//  Destination.m
//  Transiter
//
//  Created by Alper Çuğun on 19/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import "Destination.h"

@implementation Destination

@synthesize title;
@synthesize address;

@synthesize fsid;

@synthesize coordinate;

- (id)initWithTitle:(NSString *)theTitle {
    if (self = [super init]) {
        title = theTitle;
        
        address = @"";
        fsid = nil;
    }
    
    return self;
}

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    if (self = [super init]) {
        coordinate = coord;
        
        title = @"";
        address = @"";
        fsid = nil;
    }
    
    return self;
}
@end
