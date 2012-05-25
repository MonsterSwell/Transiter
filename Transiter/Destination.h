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
    
    NSString *fsid;
    
    NSString *lat;
    NSString *lng;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;

@property (nonatomic, retain) NSString *fsid;

@property (nonatomic, retain) NSString *lat;
@property (nonatomic, retain) NSString *lng;

- (id)initWithName:(NSString *)theName;

@end
