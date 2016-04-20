//
//  BikeMapViewController.m
//  
//
//  Created by Jamaal Sedayao on 4/1/16.
//
//

#import "BikeMapViewController.h"
#import "CustomView.h"
#import "CLLocation+Bearing.h"

@interface BikeMapViewController ()
<
UITextFieldDelegate,
CLLocationManagerDelegate,
GMSAutocompleteViewControllerDelegate,
GMSMapViewDelegate
>
@property (strong, nonatomic) IBOutlet UIView *bottomStatsView;
@property (strong, nonatomic) IBOutlet UIView *toAndFromView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *originButton;
@property (strong, nonatomic) IBOutlet UIButton *destinationButton;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@property (nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) INTULocationManager *locMgr;
@property (nonatomic) NSInteger locationID;
@property (nonatomic) NSInteger headingID;

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

@property (nonatomic) NSMutableArray *routeSteps; //Array of route steps
@property (nonatomic) NSMutableArray *completedSteps;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bikeMapBottom;



@end

@implementation BikeMapViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    self.mapView.myLocationEnabled = YES;
    
    self.locationID = 0;
    self.headingID = 1;
    
//    [self getCurrentLocation];
    
    //[self testCurrent];
}
//http://stackoverflow.com/questions/24112469/unable-to-get-current-location-coordinates-using-google-maps-api-for-ios
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mapView removeObserver:self forKeyPath:@"myLocation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
   
    while (self.currentLoc == nil) {
    
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]]){
        
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude longitude:self.mapView.myLocation.coordinate.longitude zoom:16];
        
        [self.mapView setCamera:camera];
        
//         NSLog(@"KVO triggered. Location Latitude: %f Longitude: %f",self.mapView.myLocation.coordinate.latitude,self.mapView.myLocation.coordinate.longitude);
        
        self.currentLoc = self.mapView.myLocation;
        
        }
    }
}

- (IBAction)startButtonTapped:(UIButton *)sender {
    
    [self updateCurrentLocation];
}

- (void)updateCurrentLocation{
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    
    [locMgr subscribeToLocationUpdatesWithDesiredAccuracy:INTULocationAccuracyHouse
                                                    block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                        
                                                        if (status == INTULocationStatusSuccess) {
                                                            
                                                            [path addCoordinate:currentLocation.coordinate];
                                                            
                                                            NSString *endLat = self.routeSteps[0][@"endLat"];
                                                            NSString *endLng = self.routeSteps[0][@"endLng"];
                                                            CLLocationDegrees endLatCoord = [endLat doubleValue];
                                                            CLLocationDegrees endLngCoord = [endLng doubleValue];
                                                            CLLocationCoordinate2D dest = CLLocationCoordinate2DMake(endLatCoord, endLngCoord);
                                                            CLLocation *destination = [[CLLocation alloc]initWithLatitude:endLatCoord longitude:endLngCoord];
                                                            
                                                            CGFloat distance2 = [currentLocation distanceFromLocation:destination];
                                                            CGFloat distanceFeet = distance2 * 3.28084;
                                                            
//                                                            CGFloat distance = [self directMetersFromCoordinate:currentLocation.coordinate toCoordinate:dest];
                                                            
                                                            CLLocation_Bearing *bearing = [[CLLocation_Bearing alloc]init];
                                                            
                                                            [bearing bearingFromLocation:currentLocation to:destination];
                                                            
                                                         //   NSLog(@"Bearing: %f",bearing.bearing);
                                                        
                                                            
                                                            GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:currentLocation.coordinate zoom:19 bearing:bearing.bearing viewingAngle:45];
                                                            [self.mapView setCamera:position];


                                                            if (distanceFeet < 10){
                                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Turn Coming Up!" message:@"Get ready to turn!" preferredStyle:UIAlertControllerStyleAlert];
                                                                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Gotcha" style:UIAlertActionStyleCancel handler:nil];
                                                                [alert addAction:cancel];
                                                                
                                                                [self presentViewController:alert animated:true completion:nil];
                                                                
                                                                NSLog(@"Turn!");
                                                            }
                                                            
                                                            [self.distanceLabel setText:[NSString stringWithFormat:@"%.2f Feet",distanceFeet]];
                                                            
                                                            NSLog(@"Origin Coord: %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
                                                            NSLog(@"Dest Coord: %f,%f",endLatCoord,endLngCoord);
                                                            NSLog(@"Distance between points: %f feet",distanceFeet);
                                                        }
                                                        
                                                        else {
                                                            
                                                        }
                                                    
    
                                                        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                                                        polyline.map = self.mapView;
                                                        polyline.strokeColor = [UIColor redColor];
                                                        polyline.strokeWidth = 5;
                                                        
                                                    
                                
                                                    }];
    
    
   
    [locMgr subscribeToHeadingUpdatesWithBlock:^(CLHeading *heading, INTUHeadingStatus status) {
        if (status == INTUHeadingStatusSuccess) {
            
            //[self.mapView animateToBearing:heading.trueHeading];
            
            // An updated heading is available
            //NSLog(@"'Heading updates' subscription block called with Current Heading:\n%@", heading);
        } else {
            // An error occurred, more info is available by looking at the specific status returned. The subscription will be canceled only if the device doesn't have heading support.
        }
    }];
    
}

- (void)moveToNextStepInRoute {
    
    
    
    
    
    
    
}


//referenced from http://www.codecodex.com/wiki/Calculate_distance_between_two_points_on_a_globe#Objective_C

- (CGFloat)directMetersFromCoordinate:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {
    
    static const double DEG_TO_RAD = 0.017453292519943295769236907684886;
    static const double EARTH_RADIUS_IN_METERS = 6372797.560856;
    
    double latitudeArc  = (from.latitude - to.latitude) * DEG_TO_RAD;
    double longitudeArc = (from.longitude - to.longitude) * DEG_TO_RAD;
    double latitudeH = sin(latitudeArc * 0.5);
    latitudeH *= latitudeH;
    double longitudeH = sin(longitudeArc * 0.5);
    longitudeH *= longitudeH;
    double tmp = cos(from.latitude*DEG_TO_RAD) * cos(to.latitude*DEG_TO_RAD);
    
    return EARTH_RADIUS_IN_METERS * 2.0 * asin(sqrt(latitudeH + tmp*longitudeH))*3.28084;

}

- (NSString*)decimalFormatter:(CLLocationDegrees)coordinate{
   
    NSNumber *coord = [NSNumber numberWithDouble:coordinate];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#######"];
    //NSLog(@"%@", [fmt stringFromNumber:[NSNumber numberWithFloat:25.342]]);

    NSString *fmtCoord = [fmt stringFromNumber:coord];
    
    return fmtCoord;
}

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
    
    for (GMSPolyline *polyline in self.polylineArray){
        polyline.map = nil;
    }


    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=bicycling&alternatives=true&sensor=true&key=AIzaSyAd1r6-rsY8RMiF4iXNjoF9quj999DSiaQ",coord1.latitude,coord1.longitude,coord2.latitude,coord2.longitude];
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSLog(@"String: %@",encodedString);
    
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
                self.routeSteps = [[NSMutableArray alloc] init];
                
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
                    NSString *startLocationLat = step[@"start_location"][@"lat"];
                    NSString *startLocationLng = step[@"start_location"][@"lng"];
                    NSString *endLocationLat = step[@"end_location"][@"lat"];
                    NSString *endLocationLng = step[@"end_location"][@"lng"];
                    
                    self.path =[GMSPath pathFromEncodedPath:
                                    json[@"routes"][0][@"overview_polyline"][@"points"]];
                    self.polyline = [GMSPolyline polylineWithPath:self.path];
                    self.polyline.strokeWidth = 5;
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
                                                @"startLat" : startLocationLat,
                                                @"startLng" : startLocationLng,
                                                @"endLat" : endLocationLat,
                                                @"endLng" : endLocationLng
                                                };
                    
                    [self.routeSteps addObject:routeStep];
                    
                }
                
            } else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Route!" message:@"This destination looks to be unbikable!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Gotcha" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                
                [self presentViewController:alert animated:true completion:nil];
                
                NSLog(@"Unbikable!");
            }
            
             NSLog(@"Route Directions Array: %@",self.routeSteps);

        }}
            failure:^(NSURLSessionTask *operation, NSError *error) {
            //NSLog(@"Error: %@", error);
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"Something went wrong. Try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Gotcha" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                
                [self presentViewController:alert animated:true completion:nil];

     }];

    [self.activity stopAnimating];
   // block();
}

#pragma mark Map Methods

- (void) setUpActivityView {
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.mapView addSubview:self.activity];
    
}

- (void) getCurrentLocation {
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                            timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                if (status == INTULocationStatusSuccess){
                                                    
                                                   // [self.activity stopAnimating];
                                                    
                                                    self.currentLoc = currentLocation;
                                                    
                                                    
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLoc.coordinate.latitude
                                                                                                                    longitude:self.currentLoc.coordinate.longitude
                                                                                                                         zoom:16];
                                                            
                                                            
                                                            [self.mapView setCamera:camera];
                                                    
                                                        });
                                                    
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
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc]init];
    filter.country = @"US";
    [controller setAutocompleteFilter:filter];
    [self presentViewController:controller animated:YES completion:nil];
    
    if (sender == self.originButton){
        self.returnOrigin = TRUE;
        self.returnDestination = FALSE;
        
    } else if (sender == self.destinationButton){
        self.returnDestination = TRUE;
        self.returnOrigin = FALSE;
    }
    
    [self.locMgr cancelLocationRequest:0];
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
