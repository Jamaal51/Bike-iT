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



@end

@implementation BikeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapView addSubview:self.toAndFromView];
    [self.mapView addSubview:self.bottomView];
    [self.mapView addSubview:self.bottomStatsView];
    
    
    [self getCurrentLocation];
    
    //[self testCurrent];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (IBAction)bikeButtonTapped:(UIButton *)sender {

  //  [self startJourneyButtonAnimation:^{
        CLLocationCoordinate2D origin;
        CLLocationCoordinate2D dest;
        
        if (self.otherOrigin == nil){
            origin = CLLocationCoordinate2DMake(self.currentLoc.coordinate.latitude, self.currentLoc.coordinate.longitude);
        } else {
            origin = CLLocationCoordinate2DMake(self.otherOrigin.coordinate.latitude, self.otherOrigin.coordinate.longitude);
        }
        dest = CLLocationCoordinate2DMake(self.destination.coordinate.latitude, self.destination.coordinate.longitude);
        
        //[self makeNewBikeDirectionsAPIRequestwithOrigin:origin destination:dest completionHandler:nil];

        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:dest.latitude
                                                                longitude:dest.longitude
                                                                     zoom:15];
        
        
        [self.mapView animateToCameraPosition:camera];

 //   }];
    
//    CLLocationCoordinate2D origin;
//    CLLocationCoordinate2D dest;
//    
//    if (self.otherOrigin == nil){
//        origin = CLLocationCoordinate2DMake(self.currentLoc.coordinate.latitude, self.currentLoc.coordinate.longitude);
//    } else {
//        origin = CLLocationCoordinate2DMake(self.otherOrigin.coordinate.latitude, self.otherOrigin.coordinate.longitude);
//    }
//    dest = CLLocationCoordinate2DMake(self.destination.coordinate.latitude, self.destination.coordinate.longitude);
//    
//    [self makeNewBikeDirectionsAPIRequestwithOrigin:origin destination:dest completionHandler:nil];
//    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:dest.latitude
//                                                            longitude:dest.longitude
//                                                                 zoom:15];
//    
//    
//    [self.mapView animateToCameraPosition:camera];
    
//    CustomView *cv = [[CustomView alloc]initWithFrame:CGRectMake(self.mapView.bounds.origin.x, self.mapView.bounds.origin.y, 200, 100)];   //create an instance of your custom view
//    [self.mapView addSubview:cv];

}

#pragma mark - Animations

- (void) startJourneyButtonAnimation:(void(^)())block {
    // toAndFromView
//    [UIView animateWithDuration:0.2 animations:^{
//        //[self.toAndFromView removeFromSuperview];
//        CGRect newFrame = self.toAndFromView.frame;
//        newFrame.origin.y += 20;
//        self.toAndFromView.frame = newFrame;
//    }];

    
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
    
    
//    [UIView animateWithDuration: 1.0 animations:^{
            
//        CGRect newFrame2 = cv.frame;
//        newFrame2.origin.x += 400;
//        cv.frame = newFrame2;

        
//        CGRect newFrame2 = self.bottomStatsView.frame;
//        newFrame2.origin.x += 400;
//        self.bottomStatsView.frame = newFrame2;

//        }];
    
//    // bottomView
//    [UIView animateWithDuration:0.5 animations:^{
//        CGRect newFrame = self.bottomView.frame;
//        newFrame.origin.x += 250;
//        self.bottomView.frame = newFrame;
//        
//        CGRect newFrame2 = self.bottomStatsView.frame;
//        newFrame2.origin.x += 400;
//        self.bottomStatsView.frame = newFrame2;

//    }];
//    
    //bottomStatsView
//    [UIView animateWithDuration:0.5 animations:^{
//        CGRect newFrame = self.bottomStatsView.frame;
//        newFrame.origin.x += 400;
//        self.bottomStatsView.frame = newFrame;
//    }];

}

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
            
            //[NSJSONSerialization JSONObjectWithData:responseObject
//                                                                 options:0
//                                                                   error:nil];
            NSArray *routes = json[@"routes"];
            NSLog(@"Routes Array:%@",routes);
            
            if (routes.count > 0){
        
                self.steps = json[@"routes"][0][@"legs"][0][@"steps"];
                self.totalDistance = json[@"routes"][0][@"legs"][0][@"distance"][@"text"];
                self.totalDuration = json[@"routes"][0][@"legs"][0][@"duration"][@"text"];
                self.directionsArray = [[NSMutableArray alloc]init];
                self.numberArray = [[NSMutableArray alloc]init];
                self.distanceArray = [[NSMutableArray alloc]init];
                self.durationArray = [[NSMutableArray alloc]init];
                self.maneuverArray = [[NSMutableArray alloc]init];
                self.polylineArray = [[NSMutableArray alloc]init];
                NSInteger directionsCount = 0;
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
                    
                    [self.directionsArray addObject:taglessString]; //method created in NSString+NSString_Sanitize
                    [self.distanceArray addObject:distance];
                    [self.durationArray addObject:duration];
                    [self.maneuverArray addObject:maneuver];
                    [self.numberArray addObject:[NSNumber numberWithInteger:directionsCount]];
                    
                    self.path =[GMSPath pathFromEncodedPath:
                                    json[@"routes"][0][@"overview_polyline"][@"points"]];
                    self.polyline = [GMSPolyline polylineWithPath:self.path];
                    self.polyline.strokeWidth = 7;
                    self.polyline.strokeColor = [UIColor greenColor];
                    
                    [self.polylineArray addObject:self.polyline];
                    
                    for (GMSPolyline *polyline in self.polylineArray){
                        polyline.map = self.mapView;
                    }
                }
                
            } else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Route!" message:@"This destination looks to be unbikable!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Gotcha" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                
                [self presentViewController:alert animated:true completion:nil];
                
                NSLog(@"Unbikable!");
            }
            
            NSLog(@"Total Distance: %@", self.totalDistance);
            NSLog(@"Total Duration: %@", self.totalDuration);
            NSLog(@"Directions: %@", self.directionsArray);
            NSLog(@"Distance: %@", self.distanceArray);
            NSLog(@"Duration: %@", self.durationArray);
            NSLog(@"Steps:%@", self.maneuverArray);
        }}
            failure:^(NSURLSessionTask *operation, NSError *error) {
            //NSLog(@"Error: %@", error);
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"Something went wrong. Try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Gotcha" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                
                [self presentViewController:alert animated:true completion:nil];

     }];

    block();
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
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:20.0f]];
  
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
        
        [self makeNewBikeDirectionsAPIRequestwithOrigin:origin destination:self.destination.coordinate completionHandler:^{
            
            //self createPolylinesFromOrigin:<#(CLLocationCoordinate2D)#> toDestination:<#(CLLocationCoordinate2D)#>
        }];
    }
}

- (void)createPolylinesFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)dest{
    
//    GMSPath *path =[GMSPath pathFromEncodedPath:
//                    json[@"routes"][0][@"overview_polyline"][@"points"]];
//    self.polyline = [GMSPolyline polylineWithPath:path];
//    self.polyline.strokeWidth = 7;
//    self.polyline.strokeColor = [UIColor greenColor];
//    self.polyline.map = self.mapView;

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
