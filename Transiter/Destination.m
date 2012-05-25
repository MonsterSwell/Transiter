//
//  Destination.m
//  Transiter
//
//  Created by Alper Çuğun on 19/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import "Destination.h"

@implementation Destination

@synthesize name;
@synthesize address;

@synthesize fsid;

@synthesize lat;
@synthesize lng;


- (id)initWithName:(NSString *)theName {
    if (self = [super init]) {
        self.name = theName;
        
        self.address = @"";
        self.fsid = nil;
        
        self.lat = nil;
        self.lng = nil;
    }
    
    return self;
}
@end
