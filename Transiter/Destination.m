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
@synthesize location;

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
    }
}
@end
