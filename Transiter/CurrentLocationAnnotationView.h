//
//  CurrentLocationAnnotationView.h
//  Transiter
//
//  Created by Alper Çuğun on 28/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CurrentLocationAnnotationView : MKAnnotationView

@property (readwrite) CLLocationCoordinate2D target;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateTarget:(CLLocationCoordinate2D)newTarget;

@end
