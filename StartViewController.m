//
//  StartViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 18.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "StartViewController.h"
#import "UKEprogramAppDelegate.h"
#import "EventsTableViewController.h"
#import "EventDetailsViewController.h"
#import "Reachability.h"


@implementation StartViewController

@synthesize allButton;
@synthesize artistButton;
@synthesize favoritesButton;
@synthesize eventsTableViewController;
@synthesize activityView;
@synthesize activityLabel;
@synthesize activityLabelRefreshing;
@synthesize refresh;
@synthesize loaderView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self.allButton release];
    [self.artistButton release];
    [self.favoritesButton release];
    [self.eventsTableViewController release];
    [self.activityView release];
    [self.activityLabel release];
    [self.activityLabelRefreshing release];
    [self.refresh release];
    [self.loaderView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)startActivityIndication:(NSNotification *)notification
{
    [loaderView setHidden:NO];
    [activityLabel setHidden:YES];
    [refresh setHidden:YES];
    [activityView startAnimating];
}
-(void)stopActivityIndication:(NSNotification *)notification
{
    [loaderView setHidden:YES];
    [activityLabel setHidden:NO];
    [refresh setHidden:NO];
    [activityView stopAnimating];
}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)allEventsClicked:(id)sender {
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.rootController pushViewController:eventsTableViewController animated:YES];
    [eventsTableViewController showAllEvents];
    NSDate *now = [[NSDate alloc] init];
    [eventsTableViewController scrollToDate:now animated:YES];
    [now release];
}
-(void)favoriteEventsClicked:(id)sender {
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.rootController pushViewController:eventsTableViewController animated:YES];
    [eventsTableViewController showFavoriteEvents];
    NSDate *now = [[NSDate alloc] init];
    [eventsTableViewController scrollToDate:now animated:YES];
    [now release];
}

- (IBAction)refreshEvents:(id)sender {
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate checkReachability];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [allButton addTarget:self action:@selector(allEventsClicked:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    [favoritesButton addTarget:self action:@selector(favoriteEventsClicked:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    self.navigationItem.title = @"Hjem";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopActivityIndication:) name:@"stopActivityIndication" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startActivityIndication:) name:@"startActivityIndication" object:nil];
    self.eventsTableViewController = [[EventsTableViewController alloc] initWithNibName:@"EventsTableView" bundle:nil];
    
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate appHasLaunchedBefore]){
        [activityLabel setHidden:NO];
        [refresh setHidden:NO];
        [loaderView setHidden:YES];
    } else {
        [activityView startAnimating];
        [activityLabel setHidden:YES];
        [refresh setHidden:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [eventsTableViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [[delegate rootController] setNavigationBarHidden:YES];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    Reachability *r = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        [self stopActivityIndication:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [[delegate rootController] setNavigationBarHidden:NO];
}

@end
