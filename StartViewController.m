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
    [self.eventsTableViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)stopActivityIndication:(NSNotification *)notification
{
    [activityView stopAnimating];
    [activityView setHidden:YES];
    [activityLabel setHidden:YES];
}
-(void)startActivityIndication:(NSNotification *)notification
{
    [activityView startAnimating];
    [activityView setHidden:NO];
    [activityLabel setHidden:NO];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [allButton addTarget:self action:@selector(allEventsClicked:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    [favoritesButton addTarget:self action:@selector(favoriteEventsClicked:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    self.navigationItem.title = @"Hjem";
    [activityView startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopActivityIndication:) name:@"stopActivityIndication" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startActivityIndication:) name:@"startActivityIndication" object:nil];
    self.eventsTableViewController = [[EventsTableViewController alloc] initWithNibName:@"EventsTableView" bundle:nil];
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
