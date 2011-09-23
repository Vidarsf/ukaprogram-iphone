//
//  UKEprogramAppDelegate.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;

@interface UKEprogramAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UINavigationController * rootController;
    NSMutableData *eventResponseData;
    NSDateFormatter *dateFormat;
    NSDateFormatter *weekDayFormat;
    NSDateFormatter *onlyDateFormat;
    NSDateFormatter *onlyTimeFormat;
    NSArray *weekDays;
    UIImage *checkedImage;
    UIImage *uncheckedImage;
    NSString *formattedToken;
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController * rootController;
@property (retain) NSDateFormatter *dateFormat;
@property (retain) NSDateFormatter *weekDayFormat;
@property (retain) NSDateFormatter *onlyDateFormat;
@property (retain) NSDateFormatter *onlyTimeFormat;
@property (retain) NSArray *weekDays;
@property (retain) UIImage *checkedImage;
@property (retain) UIImage *uncheckedImage;
@property (retain) NSString *formattedToken;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)getWeekDay:(NSDate *)date;
- (UIColor *) getColorForEventCategory:(NSString *)category;
- (void)checkReachability;
- (BOOL)appHasLaunchedBefore;
@end