//
//  FilterViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 20.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "FilterViewController.h"
#import "EventsTableViewController.h"
#import "UKEprogramAppDelegate.h"

@implementation FilterViewController

@synthesize alleButton;
@synthesize konsertButton;
@synthesize revyButton;
@synthesize kursButton;
@synthesize festButton;
@synthesize eventsTableViewController;

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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void) alleClicked:(id)sender
{
    [self.eventsTableViewController showAllEvents];
    [self dismissModalViewControllerAnimated:YES];
}
- (void) konsertClicked:(id)sender
{
    [self.eventsTableViewController showKonsertEvents];
    [self dismissModalViewControllerAnimated:YES];
}
- (void) revyClicked:(id)sender
{
    [self.eventsTableViewController showRevyEvents];
    [self dismissModalViewControllerAnimated:YES];
}
- (void) kursClicked:(id)sender
{
    [self.eventsTableViewController showKursEvents];
    [self dismissModalViewControllerAnimated:YES];
}
- (void) festClicked:(id)sender
{
    [self.eventsTableViewController showFestEvents];
    [self dismissModalViewControllerAnimated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Velg eventtype"];
    [alleButton addTarget:self action:@selector(alleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [konsertButton addTarget:self action:@selector(konsertClicked:) forControlEvents:UIControlEventTouchUpInside];
    [revyButton addTarget:self action:@selector(revyClicked:) forControlEvents:UIControlEventTouchUpInside];
    [kursButton addTarget:self action:@selector(kursClicked:) forControlEvents:UIControlEventTouchUpInside];
    [festButton addTarget:self action:@selector(festClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [alleButton release];
    [konsertButton release];
    [revyButton release];
    [kursButton release];
    [festButton release];
    [eventsTableViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
