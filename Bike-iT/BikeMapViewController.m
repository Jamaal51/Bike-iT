//
//  BikeMapViewController.m
//  
//
//  Created by Jamaal Sedayao on 4/1/16.
//
//

#import "BikeMapViewController.h"
#import "CustomView.h"

@interface BikeMapViewController ()
<
UITextFieldDelegate,
CLLocationManagerDelegate,
GMSAutocompleteViewControllerDelegate
>
@property (strong, nonatomic) IBOutlet UIView *bottomStatsView;
@property (strong, nonatomic) IBOutlet UIView *toAndFromView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *originButton;
@property (strong, nonatomic) IBOutlet UIButton *destinationButton;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic) CLLocation *currentLoc;
@property (nonatomic) CLLocation *updatedLoc;
@property (nonatomic) GMSPlace *otherOrigin;
@property (nonatomic) GMSPlace *destination;
@property (nonatomic) BOOL returnOrigin;
@property (nonatomic) BOOL returnDestination;

@property (nonatomic) GMSMarker *destinationMarker;
@property (nonatomic) GMSMarker *originMarker;

@property (nonatomic) NSArray *steps;
@property (nonatomic) NSMutableArray *polylineArray;
@property (nonatomic) GMSPath *path;
@property (nonatomic) GMSPolyline *polyline;
@property (nonatomic) NSString *totalDistance;
@property (nonatomic) NSString *totalDuration;
@property (nonatomic) NSMutableArray *directionsArray;
@property (nonatomic) NSMutableArray *distanceArray;
@property (nonatomic) NSMutableArray *durationArray;
@property (nonatomic) NSMutableArray *maneuverArray;
@property (nonatomic) NSMutableArray *numberArray;

@property (nonatomic) NSMutableArray *routeDirections; //Array of route steps
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bikeMapBottom;



@end

@implementation BikeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getCurrentLocation];
    
    //[self testCurrent];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (IBAction)startButtonTapped:(UIButton *)sender {
    
    [self trackCurrentLocation];
}

- (void)trackCurrentLocation{
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr subscribeToLocationUpdatesWithDesiredAccuracy:INTULocationAccuracyHouse
                                                    block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                        
                                                        if (status == INTULocationStatusSuccess) {
                                                            //NSString* currentLat = [self decimalFormatter:currentLocation.coordinate.latitude];
                                                            //NSString* currentLng = [self decimalFormatter:currentLocation.coordinate.longitude];
                                                            
                                                            double distance = [self checkDistanceBetweenLat1:currentLocation.coordinate.latitude lng1:currentLocation.coordinate.longitude];
                                                            
                                                            NSLog(@"Distance between points: %f", distance);
                                                        }
                                                        
                                                        else {
                                                            
                                                        }
                                                    }];

    
}

// referenced from https://rosettacode.org/wiki/Haversine_formula#Objective-C

- (double) checkDistanceBetweenLat1:(CLLocationDegrees)lat1 lng1:(CLLocationDegrees)lng1{
//                          lat2:(CLLocationDegrees)lat2 lng2:(CLLocationDegrees)lng2 {
    //degrees to radians
    double lat1rad = lat1 * M_PI/180;
    double lng1rad = lng1 * M_PI/180;
    
    //get next step coordinate in routeDirections array
    
    NSString *lat = self.routeDirections[0][@"startLat"];
    NSString *lng = self.routeDirections[0][@"startLng"];
    
    double latDouble = [lat doubleValue];
    double lngDouble = [lng doubleValue];
    
    double lat2rad = latDouble * M_PI/180;
    double lng2rad = lngDouble * M_PI/180;
    
    //deltas
    double dLat = lat2rad - lat1rad;
    double dLng = lng2rad - lng1rad;
    
    double a = sin(dLat/2) * sin(dLat/2) + sin(dLng/2) * sin(dLng/2) * cos(lat1rad) * cos(lat2rad);
    double c = 2 * asin(sqrt(a));
    double R = 6372.8;
    
    return R * c;
}

- (NSString*)decimalFormatter:(CLLocationDegrees)coordinate{
   
    NSNumber *coord = [NSNumber numberWithDouble:coordinate];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#######"];
    //NSLog(@"%@", [fmt stringFromNumber:[NSNumber numberWithFloat:25.342]]);

    NSString *fmtCoord = [fmt stringFromNumber:coord];
    
    return fmtCoord;
}

//lat = "40.7285609";
//lng = "-73.8878567;

//current
//40.7282598
//-73.8877261

#pragma mark - Animations

- (void) startJourneyButtonAnimation:(void(^)())block {
    
    [UIView animateWithDuration: 1.0 animations:^{
        CGRect newFrame = self.toAndFromView.frame;
        newFrame.origin.y -= 200;
        self.toAndFromView.frame = newFrame;
        
    }];
    
    [UIView animateWithDuration: 1.0 animations:^{
        CGRect newFrame3 = self.bottomView.frame;
        newFrame3.origin.x += 250;
        self.bottomView.frame = newFrame3;
        
    }];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:self options:nil];
    
    CGRect frame = self.mapView.frame;
    frame.origin.x += 400;
    
    CustomView *view = [[CustomView alloc]initWithFrame:frame];
    view.frame = frame;
    
    view = (CustomView *)[nib objectAtIndex:0];
    
    [self.mapView addSubview:view];
    
}

#pragma mark Networking

- (void)makeNewBikeDirectionsAPIRequestwithOrigin:(CLLocationCoordinate2D)coord1
                                      destination:(CLLocationCoordinate2D)coord2
                                completionHandler:(void(^)())block {
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=bicycling&sensor=true&key=AIzaSyAd1r6-rsY8RMiF4iXNjoF9quj999DSiaQ",coord1.latitude,coord1.longitude,coord2.latitude,coord2.longitude];
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:encodedString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        if  (responseObject!=nil){
            NSDictionary *json = responseObject;
            NSLog(@"JSON:%@",responseObject);
            
            NSArray *routes = json[@"routes"];
            
            if (routes.count > 0){
        
                self.steps = json[@"routes"][0][@"legs"][0][@"steps"];
                self.totalDistance = json[@"routes"][0][@"legs"][0][@"distance"][@"text"];
                self.totalDuration = json[@"routes"][0][@"legs"][0][@"duration"][@"text"];

                self.polylineArray = [[NSMutableArray alloc]init];
                self.routeDirections = [[NSMutableArray alloc] init];
                
                //iteratign through JSON routes
                double directionsCount = 0;
                NSString *maneuver;
                for (NSDictionary *step in self.steps){
                    NSString *htmlInstructions = [step objectForKey:@"html_instructions"];
                    NSString *taglessString = [htmlInstructions removeTags];
                    NSString *distance = step[@"distance"][@"text"];
                    NSString *duration = step[@"duration"][@"text"];
                    if (step[@"maneuver"] == nil){
                        maneuver = @"";
                    } else {
                        maneuver = step[@"maneuver"];
                    }
                    directionsCount++;
//                    NSString *startLocationLat = step[@"start_location"][@"lat"];
//                    NSString *startLocationLng = step[@"start_location"][@"lng"];
//                    NSString *endLocationLat = step[@"end_location"][@"lat"];
//                    NSString *endLocationLng = step[@"end_location"][@"lng"];
                    
                    CLLocationDegrees startLatDegree = [step[@"start_location"][@"lat"] doubleValue];
                    CLLocationDegrees startLngDegree = [step[@"start_location"][@"lng"] doubleValue];
                    CLLocationDegrees endLatDegree = [step[@"start_location"][@"lat"] doubleValue];
                    CLLocationDegrees endLngDegree = [step[@"start_location"][@"lng"] doubleValue];
                    
                    NSString *fmtStartLatString = [self decimalFormatter:startLatDegree];
                    NSString *fmtStartLngString = [self decimalFormatter:startLngDegree];
                    NSString *fmtEndLatString = [self decimalFormatter:endLatDegree];
                    NSString *fmtEndLngString = [self decimalFormatter:endLngDegree];
                    
                    self.path =[GMSPath pathFromEncodedPath:
                                    json[@"routes"][0][@"overview_polyline"][@"points"]];
                    self.polyline = [GMSPolyline polylineWithPath:self.path];
                    self.polyline.strokeWidth = 7;
                    self.polyline.strokeColor = [UIColor greenColor];
                    
                    [self.polylineArray addObject:self.polyline];
                    
                    for (GMSPolyline *polyline in self.polylineArray){
                        polyline.map = self.mapView;
                    }
                    
                    NSDictionary *routeStep = @{@"direction" : taglessString,
                                                @"distance" : distance,
                                                @"duration" : duration,
                                                @"maneuver" : maneuver,
                                                @"stepNum" : [NSNumber numberWithDouble:directionsCount],
                                                @"startLat" : fmtStartLatString,
                                                @"startLng" : fmtStartLngString,
                                                @"endLat:" : fmtEndLatString,
                                                @"endLng" : fmtEndLngString
                                                };
                    
                    [self.routeDirections addObject:routeStep];
                    
                }
                
            } else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Route!" message:@"This destination looks to be unbikable!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Gotcha" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                
                [self presentViewController:alert animated:true completion:nil];
                
                NSLog(@"Unbikable!");
            }
            
             NSLog(@"Route Directions Array: %@",self.routeDirections);

        }}
            failure:^(NSURLSessionTask *operation, NSError *error) {
            //NSLog(@"Error: %@", error);
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"Something went wrong. Try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Gotcha" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                
                [self presentViewController:alert animated:true completion:nil];

     }];

   // block();
}

#pragma mark Map Methods

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
    
    [locationMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                            timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                if (status == INTULocationStatusSuccess){
                                                    
                                                    self.currentLoc = currentLocation;
                                                    
                                                    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLoc.coordinate.latitude
                                                                                                            longitude:self.currentLoc.coordinate.longitude
                                                                                                                 zoom:16];
                                                    
                                                    
                                                    [self.mapView setCamera:camera];
                                                    
                                                    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.currentLoc.coordinate.latitude, self.currentLoc.coordinate.longitude);
                                                    self.originMarker = [GMSMarker markerWithPosition:position];
                                                    self.originMarker.title = @"Start";
                                                    self.originMarker.map = self.mapView;
                                                    
                                                } else if (status == INTULocationStatusTimedOut){
                                                    
                                                } else {
                                                    NSLog(@"Error");
                                                }
                                            }];
}

- (void) addMapMarker:(GMSPlace*)googlePlace isOrigin:(BOOL)origin{
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(googlePlace.coordinate.latitude, googlePlace.coordinate.longitude);
    
    if (origin == true){
        self.originMarker.map = nil;
        self.originMarker = [GMSMarker markerWithPosition:position];
        self.originMarker.title = [NSString stringWithFormat:@"%@", googlePlace.name];
        self.destinationMarker.appearAnimation = kGMSMarkerAnimationPop;
        self.originMarker.map = self.mapView;
        
    } else {
        self.destinationMarker.map = nil;
        self.destinationMarker = [GMSMarker markerWithPosition:position];
        self.destinationMarker.title = [NSString stringWithFormat:@"%@",googlePlace.name];
        //self.destinationMarker.icon = [UIImage imageNamed:@"icon2"];
        self.destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        self.destinationMarker.appearAnimation = kGMSMarkerAnimationPop;
        self.destinationMarker.map = self.mapView;
        
    }
}

- (void)updateMapCameraFromOrigin:(CLLocationCoordinate2D)coords1 toDestination:(CLLocationCoordinate2D)coords2{
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:coords1 coordinate:coords2];
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:20]];
  
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
    
    for (GMSPolyline *polyline in self.polylineArray){
        polyline.map = nil;
    }
    
    if (self.returnOrigin == TRUE){
        self.otherOrigin = place;
        [self.originButton setTitle: self.otherOrigin.name forState:UIControlStateNormal];
        
        [self addMapMarker:place isOrigin:true];
        
        NSLog(@"Origin: %@", self.otherOrigin.name);
        NSLog(@"Origin Coord: %f, %f", self.otherOrigin.coordinate.latitude, self.otherOrigin.coordinate.longitude);
        NSLog(@"Origin Address: %@", self.otherOrigin.formattedAddress);
        
        if (self.destination != nil){
            [self updateMapCameraFromOrigin:self.otherOrigin.coordinate toDestination:self.destination.coordinate];
            [self makeNewBikeDirectionsAPIRequestwithOrigin:self.otherOrigin.coordinate destination:self.destination.coordinate completionHandler:nil];
        }
        
    } else if (self.returnDestination == TRUE){
        self.destination = place;
        
        [self.destinationButton setTitle:self.destination.name forState:UIControlStateNormal];
        
        NSLog(@"Dest: %@", self.destination.name);
        NSLog(@"Dest Coord: %f, %f", self.destination.coordinate.latitude, self.destination.coordinate.longitude);
        NSLog(@"Dest Address: %@", self.destination.formattedAddress);
        
        CLLocationCoordinate2D origin;
        
        if (self.otherOrigin != nil){
            origin = self.otherOrigin.coordinate;
        } else {
            origin = self.currentLoc.coordinate;
        }
        
        [self addMapMarker:place isOrigin:false];
        
        [self updateMapCameraFromOrigin:origin toDestination:self.destination.coordinate];
        
        [self makeNewBikeDirectionsAPIRequestwithOrigin:origin destination:self.destination.coordinate completionHandler:nil];
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
        
        self.otherOrigin = likelihoodList.likelihoods.firstObject.place;
       
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.otherOrigin.coordinate.latitude
                                                                longitude:self.otherOrigin.coordinate.longitude
                                                                     zoom:16];
        
        
        [self.mapView setCamera:camera];
        

    }];
    
    
}


@end
