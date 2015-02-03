//
//  ViewController.m
//  VSCards
//
//  Created by Steven Chien on 2/2/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "VSViewController.h"
#import "VSPlacesCell.h"
#import "VSMusicCell.h"
#import "VSMovieCell.h"
#import "UIImageView+WebCache.h"

@interface VSViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UITableView *cardsTableView;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, assign) BOOL cellsLoaded;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, strong) CLLocation *updatedLocation;
@property (nonatomic, assign) BOOL locationFound;
@property (nonatomic, assign) BOOL cardsFetched;

@end

@implementation VSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.results = [[NSMutableArray alloc] initWithCapacity:1];
    self.locationFound = NO;
    self.cardsFetched = NO;
    [self setupNavigationBar];
    [self setupLocationManager];
    [self setupTableView];
    [self fetchCardData];
    [self setupSpinnerAndLoader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup Navigation Bar

- (void)setupNavigationBar
{
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width / 2, self.navigationController.navigationBar.bounds.size.height);
    UIView *title = [[UIView alloc] initWithFrame:frame];
    title.backgroundColor = [UIColor clearColor];
    self.titleLabel = [[UILabel alloc] initWithFrame:title.frame];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [title addSubview:self.titleLabel];
    self.navigationItem.titleView = title;
}

#pragma mark - Setup Spinner and Loader

- (void)setupSpinnerAndLoader
{
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height * 4.5 / 8, self.view.bounds.size.width, self.view.bounds.size.height / 8)];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.text = @"Loading...";
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.frame = CGRectMake(0, self.view.bounds.size.height * 3.5 / 8, self.view.bounds.size.width, self.view.bounds.size.height / 8);
    [self.loadingSpinner startAnimating];
    [self.view addSubview:self.loadingLabel];
    [self.view addSubview:self.loadingSpinner];
}

#pragma mark - Setup Location Manager

- (void)setupLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error.userInfo objectForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.updatedLocation = newLocation;
    [self.locationManager stopUpdatingLocation];
    if (self.cardsFetched) {
        [self bothFinishLoading];
    }
    else {
        self.locationFound = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        [self.loadingSpinner removeFromSuperview];
        [self.loadingLabel removeFromSuperview];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please allow access to your Location. Go to your phone's Settings > Privacy > Location Settings to proceed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else if (status == kCLAuthorizationStatusNotDetermined) {
        
    }
    else if (status == kCLAuthorizationStatusRestricted) {
        
    }
    else {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Setup Table View

- (void)setupTableView
{
    self.cardsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.cardsTableView.backgroundColor = [UIColor lightGrayColor];
    self.cardsTableView.dataSource = self;
    self.cardsTableView.delegate = self;
    self.cardsTableView.clipsToBounds = YES;
    self.cardsTableView.showsVerticalScrollIndicator = NO;
    self.cardsTableView.scrollsToTop = YES;
    [self.view addSubview:self.cardsTableView];
    self.cellsLoaded = NO;
    [self.cardsTableView reloadData];
}

#pragma mark - UITableView Delegate and Datasource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self.results objectAtIndex:indexPath.section] valueForKey:@"type"] isEqualToString:@"place"]) {
        VSPlacesCell *cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"PLACESCELL"];
        if (cell == nil) {
            cell = [[VSPlacesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLACESCELL"];
        }
        cell.categoryLabel.text = [[self.results objectAtIndex:indexPath.section] valueForKey:@"placeCategory"];
        return cell;
    }
    else if ([[[self.results objectAtIndex:indexPath.section] valueForKey:@"type"] isEqualToString:@"music"]) {
        VSMusicCell *cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"MUSICCELL"];
        if (cell == nil) {
            cell = [[VSMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MUSICCELL"];
        }
        cell.link = [[self.results objectAtIndex:indexPath.section] valueForKey:@"musicVideoURL"];
        return cell;
    }
    else if ([[[self.results objectAtIndex:indexPath.section] valueForKey:@"type"] isEqualToString:@"movie"]) {
        VSMovieCell *cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"MOVIECELL"];
        if (cell == nil) {
            cell = [[VSMovieCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MOVIECELL"];
        }
        [cell.mainCharImage sd_setImageWithURL:[[self.results objectAtIndex:indexPath.section] valueForKey:@"movieExtraImageURL"]];
        return cell;
    }
    else {
        VSPlacesCell *cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"PLACESCELL"];
        if (cell == nil) {
            cell = [[VSPlacesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLACESCELL"];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self.results objectAtIndex:indexPath.section] valueForKey:@"type"] isEqualToString:@"place"]) {
        return self.view.bounds.size.height / 8;
    }
    else if ([[[self.results objectAtIndex:indexPath.section] valueForKey:@"type"] isEqualToString:@"music"]) {
        return self.view.bounds.size.height / 8;
    }
    else if ([[[self.results objectAtIndex:indexPath.section] valueForKey:@"type"] isEqualToString:@"movie"]) {
        return self.view.bounds.size.width;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.cellsLoaded) {
        return 1;
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.cellsLoaded) {
        return [self.results count];
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.view.bounds.size.height / 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 8)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [[self.results objectAtIndex:section] valueForKey:@"title"];
    [view addSubview:label];
    return view;
}

#pragma mark - Search With Query

- (void)fetchCardData
{
    self.cellsLoaded = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://gist.githubusercontent.com/helloandrewpark/0a407d7c681b833d6b49/raw/5f3936dd524d32ed03953f616e19740bba920bcd/gistfile1.js"]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:@"USERNAME" password:@"PASSWORD" persistence:NSURLCredentialPersistencePermanent];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    self.cellsLoaded = YES;
    if (json) {
        for (NSDictionary *dict in [json valueForKey:@"cards"]) {
            [self.results addObject:dict];
        }
        if (self.locationFound) {
            [self bothFinishLoading];
        }
        else {
            self.cardsFetched = YES;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error.userInfo objectForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

#pragma mark - Both Finish Loading

- (void)bothFinishLoading
{
    [self.loadingLabel removeFromSuperview];
    [self.loadingSpinner stopAnimating];
    [self.loadingSpinner removeFromSuperview];
    self.titleLabel.text = [NSString stringWithFormat:@"%f, %f", self.updatedLocation.coordinate.latitude, self.updatedLocation.coordinate.longitude];
    [self.cardsTableView reloadData];
}


@end
