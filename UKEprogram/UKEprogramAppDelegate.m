//
//  UKEprogramAppDelegate.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "UKEprogramAppDelegate.h"
#import "Event.h"
#import "JSON.h"
#import "Reachability.h"
#import "StartViewController.h"

@implementation UKEprogramAppDelegate


@synthesize window=_window;
@synthesize rootController;
@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;
@synthesize dateFormat;
@synthesize weekDayFormat;
@synthesize onlyDateFormat;
@synthesize onlyTimeFormat;
@synthesize weekDays;
@synthesize checkedImage;
@synthesize uncheckedImage;
@synthesize formattedToken;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
NSURLConnection *nsuc;


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [eventResponseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [eventResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    //Stop loading and give a warning
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopActivityIndication" object:nil];
    
    NSString *melding = [[NSString alloc] initWithString:@"Får ikke kontaktet FindMyApp. Vennligst prøv igjen senere."];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kommunikasjonsproblem!" 
                                                    message:melding 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
    [melding release];
}

/**
 * Request to uka backend to retrieve all events
 */
- (void)getAllEvents {
    NSString *eventsApiUrl = [NSString stringWithFormat: @"http://findmyapp.net/findmyapp/program/uka11/events"];
    eventResponseData = [[NSMutableData data] retain];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:eventsApiUrl]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    nsuc = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)fillEvents {
    NSString *responseString = [[NSString alloc] initWithData:eventResponseData  encoding:NSUTF8StringEncoding];
    [eventResponseData release];
    NSArray *events = [responseString JSONValue];
    [responseString release];
    
    NSManagedObjectContext *con = [self managedObjectContext];
    
    NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    for (int i = 0; i < [events count]; i++) {
        NSDictionary *event = [events objectAtIndex:i];
        NSString *id = [[event objectForKey:@"id"] stringValue];
        Event *e;
        NSError *error;
        
        //request event with the given id to see if it exists
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:con];
        [request setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", id];
        [request setPredicate:predicate];
        NSArray *array = [con executeFetchRequest:request error:&error];
        
        if (array != nil && [array count] > 0) {//object exists
            e = (Event *) [array objectAtIndex:0];
        }
        else {//create new event
            e = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:con];
            e.id = [numberFormat numberFromString:id];
        }
        
        e.lowestPrice = [numberFormat numberFromString:[[event objectForKey:@"lowestPrice"] stringValue]];
        //e.showingTime = [dateFormat dateFromString:[event objectForKey:@"showingTime"]];
        e.showingTime = [NSDate dateWithTimeIntervalSince1970:[[event objectForKey:@"showingTime"] longLongValue]/1000];
        e.placeString = [event objectForKey:@"placeString"];
        e.place = [event objectForKey:@"place"];
        e.billigId = [numberFormat numberFromString:[[event objectForKey:@"billigId"] stringValue]];
        e.free = [event objectForKey:@"free"];
        e.canceled = [event objectForKey:@"canceled"];
        e.title = [event objectForKey:@"title"];
        e.lead = [event objectForKey:@"lead"];
        e.text = [event objectForKey:@"text"];
        e.eventType = [event objectForKey:@"eventType"];
        e.image = [event objectForKey:@"image"];
        e.thumbnail = [event objectForKey:@"thumbnail"];
        e.ageLimit = [numberFormat numberFromString:[[event objectForKey:@"ageLimit"] stringValue]];
        if (![con save:&error]) {
            //NSLog(@"Lagring av %@ feilet", e.title);
        } else {
            //NSLog(@"Lagret event %@", e.title);
        }
    }
    [numberFormat release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopActivityIndication" object:nil];
}

- (UIColor *) getColorForEventCategory:(NSString *)category
{
    UIColor *color;
    if ([category isEqualToString:@"Konsert"]) {
        color = [UIColor colorWithRed:0.686 green:0.576 blue:0.776 alpha:1.0];
    } else if ([category isEqualToString:@"Revy og teater"]) {
        color = [UIColor colorWithRed:0.976 green:0.717 blue:0.545 alpha:1.0];
    } else if ([category isEqualToString:@"Andelig fode"]) {
        color = [UIColor colorWithRed:0.5 green:0.854 blue:0.898 alpha:1.0];
    } else if ([category isEqualToString:@"Kurs og events"]) {
        color = [UIColor colorWithRed:0.5 green:0.854 blue:0.898 alpha:1.0];
    } else if ([category isEqualToString:@"Fest og moro"]) {
        color = [UIColor colorWithRed:0.92 green:0.698 blue:0.827 alpha:1.0];
    } else {
        color = [UIColor lightGrayColor];
    }
    return color;
}

- (BOOL)appHasLaunchedBefore
{
    NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[self applicationDocumentsDirectory] path] error:nil];
    //register that the app has been run the first time  
    for (id file in listOfFiles) {
        //NSLog(@"Item: %@", file);
        if ([file isEqualToString:@"UKEprogram.sqlite"]) {
            return YES;
        }
    }
    return NO;
}

/**
 *  Called when data is retrieved from connection, adds any new events to object context and displays only the events recieved from connection
 */
#pragma mark NSURLConnection Delegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //for returning a set of events and showing these
    [self fillEvents];
    [connection release];
}

-(void) checkReachability
{
    Reachability *r = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        NSString *melding = [[NSString alloc] initWithString:@"Denne appen trenger tilgang til internett for å laste nyeste versjon av programmet. Tidligere lastet program vil bli vist."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ingen nettilgang!" 
														message:melding 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
        [melding release];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startActivityIndication" object:nil];
        [self getAllEvents];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window addSubview:rootController.view];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    
    weekDayFormat = [[NSDateFormatter alloc] init];
    [weekDayFormat setDateFormat:@"e"];
    NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"nb"];
    [weekDayFormat setLocale:local];
    [local release];
    
    onlyDateFormat = [[NSDateFormatter alloc] init];
    [onlyDateFormat setDateFormat:@"dd.MM"];
    onlyTimeFormat  = [[NSDateFormatter alloc] init];
    [onlyTimeFormat setDateFormat:@"HH:mm"];
    weekDays = [[NSArray alloc] initWithObjects:@"ubrukt",@"Mandag",@"Tirsdag",@"Onsdag",@"Torsdag",@"Fredag", @"Lørdag", @"Søndag", nil];
    checkedImage = [UIImage imageNamed:@"favorite.png"];
    uncheckedImage = [UIImage imageNamed:@"unfavorite.png"];
    //[self checkReachability];
    //NSLog(@"har db-fil: %i", [self appHasLaunchedBefore]);

    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //NSLog(@"applicationDidBecomeActive:");
    if (![self appHasLaunchedBefore]) {
        [self checkReachability];
    }
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [formattedToken release];
    [weekDayFormat release];
    [onlyDateFormat release];
    [onlyTimeFormat release];
    [weekDays release];
    [dateFormat release];
    [checkedImage release];
    [uncheckedImage release];
    [rootController release];
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [nsuc release];
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UKEprogram" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UKEprogram.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)getWeekDay:(NSDate *)date
{
    return [weekDays objectAtIndex:[[weekDayFormat stringFromDate:date] intValue]];
}

@end
