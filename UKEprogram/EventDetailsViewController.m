//
//  EventDetailsViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "Event.h"
#import "UKEprogramAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"
#import "StartViewController.h"

/*IBOutlet UILabel *PlaceLabel;
IBOutlet UILabel *DateLabel;
IBOutlet UILabel *leadLabel;
IBOutlet UILabel *textLabel;
IBOutlet UIImage *eventImg;
*/
@implementation EventDetailsViewController
@synthesize headerLabel;
@synthesize footerLabel;
@synthesize leadLabel;
@synthesize textLabel;
@synthesize event;
@synthesize sView;
@synthesize eventImgView;
@synthesize notInUseLabel;
@synthesize loadSpinner;

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
    [loadSpinner release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/**
 * Sets the text in labels, and the size of the description and lead label
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:event.title];
    event.lead = [event.lead stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"###"];
    event.lead = [event.lead stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    event.lead = [event.lead stringByReplacingOccurrencesOfString:@"###" withString:@"\r\n\r\n"];
    
    event.text = [event.text stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"###"];
    event.text = [event.text stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    event.text = [event.text stringByReplacingOccurrencesOfString:@"###" withString:@"\r\n\r\n"];
    
    [leadLabel setText:event.lead];
    [textLabel setText:event.text];
    leadLabel.font = [UIFont boldSystemFontOfSize:14];
    textLabel.font = [UIFont systemFontOfSize:14];
    
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *dateString = [[NSString alloc] initWithFormat:@"%@ %@", [delegate.onlyDateFormat stringFromDate:event.showingTime], [delegate.onlyTimeFormat stringFromDate:event.showingTime]]; 
    NSString *labelText = [[NSString alloc] initWithFormat:@"%@  %@  %@", event.placeString, [delegate getWeekDay:event.showingTime], dateString];
    [dateString release];
    
    //header and footer
    [headerLabel setText:labelText];
    headerLabel.backgroundColor = [delegate getColorForEventCategory:event.eventType];
    headerLabel.textColor = [UIColor darkGrayColor];
    
    footerLabel.text = [NSString stringWithFormat:@"%@ år  %i,-", event.ageLimit, [event.lowestPrice intValue]];
    footerLabel.backgroundColor = [delegate getColorForEventCategory:event.eventType];
    footerLabel.textColor = [UIColor darkGrayColor];
    
    [labelText release];
    //find the size of lead and description text
    CGSize constraintSize = CGSizeMake(300.0f, MAXFLOAT);
    CGSize labelSize = [event.text sizeWithFont:textLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat textHeight = labelSize.height;
    labelSize = [event.lead sizeWithFont:leadLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat leadHeight = labelSize.height;
    //Set the lead and text labels to the size found
    [leadLabel setFrame:CGRectMake(leadLabel.frame.origin.x, leadLabel.frame.origin.y, 305, leadHeight)];
    [textLabel setFrame:CGRectMake(textLabel.frame.origin.x, textLabel.frame.origin.y + leadHeight, 305, textHeight)];
    
    sView = (UIScrollView *) self.view;
    sView.contentSize=CGSizeMake(1, textHeight + leadHeight + leadLabel.frame.origin.y + 50);//1 is less than width of iphone
    
    favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favButton.frame = CGRectMake(0, 0, 40, 40);
    [favButton addTarget:self action:@selector(favoritesClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([event.favorites intValue] > 0) {
        [favButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
    }
    else {
       [favButton setImage:[UIImage imageNamed:@"unfavorite.png"] forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:favButton] autorelease];
    
    //Put the loadSpinner into the eventImgView
    loadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadSpinner setCenter:CGPointMake(eventImgView.frame.size.width/2, eventImgView.frame.size.height/2)];
    [eventImgView addSubview:loadSpinner];
}

- (void)favoritesClicked:(id)sender
{
    NSError *error;
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *con = [delegate managedObjectContext];
    if ([event.favorites intValue] > 0) {
        event.favorites = [NSNumber numberWithInt:0];
        [favButton setImage:delegate.uncheckedImage forState:UIControlStateNormal];
    }
    else {
        event.favorites = [NSNumber numberWithInt:1];
        [favButton setImage:delegate.checkedImage forState:UIControlStateNormal];
    }
    if (![con save:&error]) {
        //NSLog(@"Lagring av %@ feilet", event.title);
    } else {
        //NSLog(@"Lagret event %@", event.title);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Start spinner to indicate image is loading
    [loadSpinner startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Check if you should load image?
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    //Extract the filename
    NSArray *split = [event.image componentsSeparatedByString:@"/"];
    NSString *fileNameWithoutExtention = [split objectAtIndex:[split count] - 1];
    fileNameWithoutExtention = [fileNameWithoutExtention stringByDeletingPathExtension];
    
    //Find all stored images
    NSArray *listOfImages = [fileMgr contentsOfDirectoryAtPath:docDir error:&error];
    NSString *savedImage;
    
    BOOL doWeNeedToDownLoadImage = YES;
    
    for (id file in listOfImages) {
        if ([file isKindOfClass:[NSString class]] && [[file stringByDeletingPathExtension] isEqualToString:fileNameWithoutExtention] ) {
            doWeNeedToDownLoadImage = NO;
            savedImage = [NSString stringWithFormat:@"%@/%@", docDir, file];
        }
    }
    UIImage *placeHolderImage = [UIImage imageNamed:@"placeHolderImage.png"];
    
    if (doWeNeedToDownLoadImage) {
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://uka.no/%@", event.image]]]];
        if (img != nil) {
            eventImgView.image = img;
            NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@.jpeg",docDir,fileNameWithoutExtention];
            NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(img, 1.0f)];//1.0f = 100% quality
            [data writeToFile:jpegFilePath atomically:YES];
        } else {
            eventImgView.image = placeHolderImage;
        }
    } else {
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:savedImage]];
        if (img != nil) {
            eventImgView.image = img;
        } else {
            eventImgView.image = placeHolderImage;
        }
    }
    
    //Stop spinner when image is loaded
    [loadSpinner stopAnimating];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [favButton release];
    [event release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [sView setNeedsLayout];
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
