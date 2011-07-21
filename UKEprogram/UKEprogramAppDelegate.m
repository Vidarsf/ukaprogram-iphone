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
@synthesize facebook;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
    NSLog(@"DIDRECEIVERESPONSE");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
    NSLog(@"DIDRECEIVEDATA");
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    //self.twitterLabel.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
    //[myTableView setNeedsDisplay];
    NSLog(@"DIDFAILWITHERROR");
}
/**
 * Request to uka backend to retrieve all events
 */
- (void)getAllEvents {
    NSString *eventsApiUrl = [NSString stringWithFormat: @"http://findmyapp.net/findmyapp/program/uka11/events"];
    //NSString *eventsApiUrl = [NSString stringWithFormat: @"http://localhost"];
    responseData = [[NSMutableData data] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:eventsApiUrl]];
    NSLog(@"Opening connection");
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


/**
 *  Called when data is retrieved from connection, adds any new events to object context and displays only the events recieved from connection
 */
#pragma mark NSURLConnection Delegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //for returning a set of events and showing these
    [connection release];
    NSLog(@"Connection closed");
    NSString *responseString = [[NSString alloc] initWithData:responseData  encoding:NSASCIIStringEncoding];
    //NSLog(@"RESPONSE %i: %@", [responseData length] ,responseString);
    [responseData release];
    NSArray *events = [responseString JSONValue];
    [responseString release];
    NSLog(@"Number of events fetched: %i", [events count]);
    
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
            NSLog(@"Updating event with id: %@", id);
        }
        else {//create new event
            e = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:con];
            e.id = [numberFormat numberFromString:id];
            NSLog(@"Creating event with id: %@", id);
        }
        e.lowestPrice = [numberFormat numberFromString:[[event objectForKey:@"lowestPrice"] stringValue]];
        e.showingTime = [dateFormat dateFromString:[event objectForKey:@"showingTime"]];
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
            NSLog(@"Lagring av %@ feilet", e.title);
        } else {
            NSLog(@"Lagret event %@", e.title);
        }
        
        //[listOfEvents addObject:e];
    }
    [numberFormat release];
    //[self updateTable];
    //[self showAllEvents];
    
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"App Startet");    
    [self.window addSubview:rootController.view];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    [self getAllEvents];
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    
    
    weekDayFormat = [[NSDateFormatter alloc] init];
    [weekDayFormat setDateFormat:@"e"];
    onlyDateFormat = [[NSDateFormatter alloc] init];
    [onlyDateFormat setDateFormat:@"dd.MM"];
    onlyTimeFormat  = [[NSDateFormatter alloc] init];
    [onlyTimeFormat setDateFormat:@"HH:mm"];
    weekDays = [[NSArray alloc] initWithObjects:@"ubrukt",@"Sondag",@"Mandag",@"Tirsdag",@"Onsdag",@"Torsdag",@"Fredag",@"Lordag", nil];
    checkedImage = [UIImage imageNamed:@"checked.png"];
    uncheckedImage = [UIImage imageNamed:@"unchecked.png"];
    
    
    facebook = [[Facebook alloc] initWithAppId:@"219501071426021"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.accessToken = [defaults objectForKey:@"FBExpirationDateKey"];
        
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url];
}
- (void) fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
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
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [facebook release];
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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

@end
