//
//  CLLocation+Bearing.m
//  Bike-iT
//
//  Created by Jamaal Sedayao on 4/20/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

#import "CLLocation+Bearing.h"

double DegreesToRadians(double degrees) {return degrees * M_PI / 180.0;};
double RadiansToDegrees(double radians) {return radians * 180.0/M_PI;};

@implementation CLLocation_Bearing

-(double)bearingFromLocation:(CLLocation *)current to:(CLLocation *)destinationLocation{
    
    double lat1 = DegreesToRadians(current.coordinate.latitude);
    double lon1 = DegreesToRadians(current.coordinate.longitude);
    
    double lat2 = DegreesToRadians(destinationLocation.coordinate.latitude);
    double lon2 = DegreesToRadians(destinationLocation.coordinate.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    
    if(radiansBearing < 0.0){
        radiansBearing += 2*M_PI;
    }
    
    self.bearing = RadiansToDegrees(radiansBearing);
    
    return self.bearing;
}

@end
