//
//  CLLocation+Bearing.h
//  Bike-iT
//
//  Created by Jamaal Sedayao on 4/20/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocation_Bearing : NSObject

@property (nonatomic) double bearing;

-(double)bearingFromLocation:(CLLocation *)current to:(CLLocation *)destinationLocation;

//referenced from http://stackoverflow.com/questions/3925942/cllocation-category-for-calculating-bearing-w-haversine-function

@end
