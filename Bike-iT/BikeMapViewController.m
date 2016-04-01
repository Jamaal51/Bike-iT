//
//  BikeMapViewController.m
//  
//
//  Created by Jamaal Sedayao on 4/1/16.
//
//

#import "BikeMapViewController.h"

@interface BikeMapViewController ()
<
UITextFieldDelegate,
CLLocationManagerDelegate
>
//views
@property (strong, nonatomic) IBOutlet UIView *toAndFromView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString *currentLocationString;
@end

@implementation BikeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapView insertSubview:self.toAndFromView aboveSubview:self.mapView];
    
    [self getCurrentLocation];
}

- (void)getCurrentLocation {
    
        //instantiate CLLocation
        if (self.locationManager == nil){
            self.locationManager = [[CLLocationManager alloc]init];
        }
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    
    INTULocationManager *locationMgr = [INTULocationManager sharedInstance];
    
    [locationMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                            timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                if (status == INTULocationStatusSuccess){
                                                    // NSLog(@"Current Location: %@", currentLocation);
                                                    self.currentLocationString = [NSString stringWithFormat:@"ll=%f,%f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
                                                    
                                                    
                                                    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude
                                                                                                            longitude:currentLocation.coordinate.longitude
                                                                                                                 zoom:12];
                                                    
                                                    
                                                    
                                                      // self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
                                                    
                                                    [self.mapView setCamera:camera];
                                                    
                                                

                                                    
                                                    NSLog(@"Our Location: %@",self.currentLocationString);
                                                    
                                                } else if (status == INTULocationStatusTimedOut){
                                                    
                                                } else {
                                                    NSLog(@"Error");
                                                }
                                            }];
}


@end
