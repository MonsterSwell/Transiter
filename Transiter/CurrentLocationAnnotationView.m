//
//  CurrentLocationAnnotationView.m
//  Transiter
//
//  Created by Alper Çuğun on 28/5/12.
//  Copyright (c) 2012 Aardverschuiving Media. All rights reserved.
//

#import "CurrentLocationAnnotationView.h"

@implementation CurrentLocationAnnotationView

@synthesize target;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        // Set the frame size to the appropriate values.
        CGRect  myFrame = self.frame;
        myFrame.size.width = 100;
        myFrame.size.height = 40;
        self.frame = myFrame;
        
        // The opaque property is YES by default. Setting it to
        // NO allows map content to show through any unrendered
        // parts of your view.
        self.opaque = NO;
        
        self.target = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (void)updateTarget:(CLLocationCoordinate2D)newTarget {
    self.target = newTarget;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGRect myFrame = self.bounds;
    
//    CGContextSetLineWidth(context, 10);
//    CGRectInset(myFrame, 5, 5);
    
    CLLocationCoordinate2D currentLocation = self.annotation.coordinate;
    
    NSLog(@"current location %f, %f", currentLocation.latitude, currentLocation.longitude);
    
    [[UIColor redColor] set];
    
    NSString *text;
    if (CLLocationCoordinate2DIsValid(self.target)) {
        // Calculate distance
        
        CLLocation *here = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
        CLLocation *there = [[CLLocation alloc] initWithLatitude:target.latitude longitude:target.longitude];
        
        int distance = [here distanceFromLocation:there];
        
        text = [NSString stringWithFormat:@"%dm", distance];
    } else {
        text = @"No target";
    }
    
    [text drawAtPoint:CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f) withFont:[UIFont boldSystemFontOfSize:10.0f]];
    
//    UIRectFrame(myFrame);
}


@end
