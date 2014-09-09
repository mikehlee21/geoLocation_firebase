//
//  ViewController.m
//  location-demo
//
//  Created by Tony Meng on 8/25/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import <Firebase/Firebase.h>
#import <FacebookSDK/FacebookSDK.h>

@implementation ViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    // setup the view
    [self loadMapsView];
	// additional setup after loading the view, typically from a nib.
    [self loadFacebookView];
    [self listenForLocations];
}

- (void)loadMapsView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.7833
                                                            longitude:-122.4167
                                                                 zoom:8];
    self.mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView_.myLocationEnabled = YES;
    self.view = self.mapView_;
}

- (void)loadFacebookView {
	// Do any additional setup after loading the view, typically from a nib.
    FBLoginView *loginView = [[FBLoginView alloc] init];
    // position the login button
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // create a button that's the width of the screen (with 4 padding) and has a height of 50
    // move the button to the bottom of the screen (screen height - button height (50))
    loginView.frame = CGRectMake(4, screenRect.size.height-50, screenRect.size.width-(4*2), 50);
    // set the view controller as the delegate
    loginView.delegate = self;
    [self.view addSubview:loginView];
}

- (void)listenForLocations {
    self.usersToMarkers_ = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://location-demo.firebaseio.com"];
    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *s2) {
        // a new person connected, start listening for his position
        [[ref childByAppendingPath:s2.name] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            GMSMarker *marker = [self.usersToMarkers_ objectForKey:snapshot.name];
            if (!marker) {
                marker = [[GMSMarker alloc] init];
                marker.title = snapshot.name;
                marker.map = self.mapView_;
                [self.usersToMarkers_ setObject:marker forKey:snapshot.name];
            }
            marker.position = CLLocationCoordinate2DMake([snapshot.value[@"coords"][@"latitude"] doubleValue], [snapshot.value[@"coords"][@"longitude"] doubleValue]);
        }];
    }];
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"FB: logged out");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate deauthToFirebase];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
