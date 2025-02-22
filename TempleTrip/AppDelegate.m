
//
//  AppDelegate.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/6/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "MasterViewController.h"
#import "Temple.h"
#import <Parse/Parse.h>
#import "NetworkHelper.h"
#import <ChameleonFramework/Chameleon.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    
    //[Chameleon setGlobalThemeUsingPrimaryColor:FlatSkyBlueDark withContentStyle:UIContentStyleContrast];
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    
    UINavigationController *navigationController = (splitViewController.viewControllers).firstObject;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    
    controller.managedObjectContext = self.managedObjectContext;
    
    //Setup default user preferences
    
    NSURL *defaultPrefsFile = [[NSBundle mainBundle]
                               URLForResource:@"DefaultPreferences" withExtension:@"plist"];
    NSDictionary *defaultPrefs =
    [NSDictionary dictionaryWithContentsOfURL:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
    
    
    ParseClientConfiguration *configuration = [ParseClientConfiguration configurationWithBlock: ^(id<ParseMutableClientConfiguration> config) {
       config.applicationId = @"JUJurzhFM1UwVK1cY0JHyyJCw17ai5QH1cJ5F880";
       config.clientKey = @"unused";
        config.server = @"https://templetrip-server.herokuapp.com/parse";
    }];
    [Parse initializeWithConfiguration:configuration];
    
    // Check to see if we should initialize CoreData from results.txt.
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldReloadCoreData"]){
        [self preloadData];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"shouldReloadCoreData"];
    }
    
    //Try to update from Parse on every launch
    [NetworkHelper fetchAndUpdateTemplesFromParseWithManagedObjectContext:self.managedObjectContext completionBlock:^(void){
        NSLog(@"Startup fetch of temples from Parse complete.");
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.EphraimKunz.TempleTrip" in the application's documents directory.
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TempleTrip" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TempleTrip.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = coordinator;
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if (managedObjectContext.hasChanges && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}

#pragma mark - Parse Temples Json

/* These methods are mainly to allow someone without internet access to 
 get started with the app. The app ships with results.txt, a JSON store of
 temple data that we will initialize Core Data with here. Going forward,
 we will pull updates from the Parse server and update Core Data directly.
 */

-(NSArray *)parseTempleJson:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *temples = nil;
	NSError *error;
	temples =[NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:&error];
    
    return temples;
}

-(void)preloadData{
    
    [self removeData];
	
    NSString *path = [[NSBundle mainBundle]pathForResource:@"results" ofType:@"json"];
    NSArray *temples = [self parseTempleJson:path];
    
    for (id item in temples) {
        Temple *temple = [NSEntityDescription insertNewObjectForEntityForName:@"Temple" inManagedObjectContext:self.managedObjectContext];
		temple.name = [item valueForKey:@"name"];
        temple.dedication = [item valueForKey:@"dedication"];
        temple.place = [item valueForKey:@"place"];
        temple.address = [item valueForKey:@"address"];
        temple.imageLink = [item valueForKey:@"photoLink"];
        temple.telephone = [item valueForKey:@"telephone"];
        temple.endowmentSchedule = [item valueForKey:@"endowmentSchedule"];
        temple.firstLetter = [temple.name substringToIndex:1];
        temple.webViewUrl = [item valueForKey:@"detailLink"];
    
        NSString *firstTwoLetters = [[[item valueForKey:@"servicesAvailable"]valueForKey:@"Cafeteria"] substringToIndex:2] == nil ? @"No" : [[[item valueForKey:@"servicesAvailable"]valueForKey:@"Cafeteria"] substringToIndex:2];
		temple.hasCafeteria = ![firstTwoLetters isEqualToString:@"No"];
		
		firstTwoLetters = [[[item valueForKey:@"servicesAvailable"]valueForKey:@"Clothing"] substringToIndex:2] == nil ? @"No" : [[[item valueForKey:@"servicesAvailable"]valueForKey:@"Clothing"] substringToIndex:2];
        temple.hasClothing = ![firstTwoLetters isEqualToString:@"No"];
        
        NSMutableArray *closedDatesArray = [[NSMutableArray alloc]initWithArray:[[item valueForKey:@"closures"]valueForKey:@"Maintenance Dates"]];
        [closedDatesArray addObjectsFromArray:[[item valueForKey:@"closures"]valueForKey:@"Other Dates"]];
        temple.closedDates = [closedDatesArray copy];
    }
	[self.managedObjectContext save:nil];
}

-(void)removeData{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *delete = [NSFetchRequest fetchRequestWithEntityName:@"Temple"];
    NSArray *allTemples = [context executeFetchRequest:delete error:nil];
    for (Temple* item in allTemples) {
        [context deleteObject:item];
    }
	[context save:nil];
}

@end
