//
//  Destination.h
//  Transiter
//
//  Created by Alper Çuğun on 19/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Destination : NSObject {
    NSString *name;
    NSString *address;
    
    CLLocationCoordinate2D *location;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;

@property (readwrite) CLLocationCoordinate2D *location;

- (id)initWithName:(NSString *)theName;

@end
