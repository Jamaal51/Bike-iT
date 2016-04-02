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
CLLocationManagerDelegate,
GMSAutocompleteViewControllerDelegate
>
@property (strong, nonatomic) IBOutlet UIView *toAndFromView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *originButton;
@property (strong, nonatomic) IBOutlet UIButton *destinationButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString *currentLocationString;

@property (nonatomic) GMSPlace *origin;
@property (nonatomic) GMSPlace *destination;
@property (nonatomic) BOOL returnOrigin;
@property (nonatomic) BOOL returnDestination;

@end

@implementation BikeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapView insertSubview:self.toAndFromView aboveSubview:self.mapView];
    [self.mapView insertSubview:self.bottomView aboveSubview:self.mapView];
    
    [self getCurrentLocation];
    
    //[self testCurrent];
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
                                                                                                                 zoom:16];
                                                    
                                                    
                                    
                                                    
                                                    [self.mapView setCamera:camera];
                                                    
                                                    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
                                                    GMSMarker *marker = [GMSMarker markerWithPosition:position];
                                                    marker.title = @"You're Here";
                                                    marker.map = self.mapView;
                                            
                                                    NSLog(@"Our Location: %@",self.currentLocationString);
                                                    
                                                } else if (status == INTULocationStatusTimedOut){
                                                    
                                                } else {
                                                    NSLog(@"Error");
                                                }
                                            }];
}

#pragma mark - AutoComplete Delegates

- (IBAction)callAutocomplete:(id)sender {
    GMSAutocompleteViewController *controller = [[GMSAutocompleteViewController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
    
    if (sender == self.originButton){
        self.returnOrigin = TRUE;
        self.returnDestination = FALSE;
        
    } else if (sender == self.destinationButton){
        self.returnDestination = TRUE;
        self.returnOrigin = FALSE;
    }
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (self.returnOrigin == TRUE){
        self.origin = place;
        [self.originButton setTitle: self.origin.name forState:UIControlStateNormal];
        NSLog(@"Origin: %@", self.origin.name);
        NSLog(@"Origin Coord: %f, %f", self.origin.coordinate.latitude, self.origin.coordinate.longitude);
        NSLog(@"Origin Address: %@", self.origin.formattedAddress);
    } else if (self.returnDestination == TRUE){
        self.destination = place;
        [self.destinationButton setTitle:self.destination.name forState:UIControlStateNormal];
        NSLog(@"Dest: %@", self.destination.name);
        NSLog(@"Dest Coord: %f, %f", self.destination.coordinate.latitude, self.destination.coordinate.longitude);
        NSLog(@"Dest Address: %@", self.destination.formattedAddress);
    }
    
}


- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Current Place Method

- (void) testCurrent {
    
    GMSPlacesClient *placesClient = [[GMSPlacesClient alloc]init];
    
    [placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            NSLog(@"Current Place address %@", place.formattedAddress);
            NSLog(@"Current Place attributions %@", place.attributions);
            NSLog(@"Current PlaceID %@", place.placeID);
        }
        
    }];
}


@end
