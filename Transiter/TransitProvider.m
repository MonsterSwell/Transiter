//
//  TransitProvider.m
//  Transiter
//
//  Created by Alper Çuğun on 1/6/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import "TransitProvider.h"

@implementation TransitProvider

@synthesize stops;

- (id)init {
    if (self = [super init]) {
        NSString *stopsPath = [[NSBundle mainBundle] pathForResource:@"govi" ofType:@"json"];
        
        NSLog(@"path %@", stopsPath);
        
        stops = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:stopsPath] options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"Read stops %@", stops);
    }
    
    return self;
}

- (NSArray *)stopsWithinRegion:(MKCoordinateRegion)mkcRegion {
    
}

@end
