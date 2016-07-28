//
//  AppDelegate.m
//  PillMinder
//
//  Created by Melissa Perenson on 12/31/00.
//  Copyright (c) 2000 Flight of Fancy. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "Constants.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSMutableArray *tempCounterData;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

NSString * const NotificationCategoryIdent  = @"ACTIONABLE";
NSString * const NotificationActionOneIdent = @"ACTION_ONE";
NSString * const NotificationActionTwoIdent = @"ACTION_TWO";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
#ifdef __IPHONE_8_0
    //Right, that is the point
    /*
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                         |UIUserNotificationTypeSound
                                                                                         |UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    */
    [self registerForNotification];
#else
    //register to receive notifications
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif

    
    
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:60], @"pillminder.timeIntervalBeforeMeal",
                                          [NSNumber numberWithInt:60], @"pillminder.timeIntervalAfterMeal",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[UIApplication sharedApplication] scheduledLocalNotifications] count]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[UIApplication sharedApplication] scheduledLocalNotifications] count]];
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    /*
    UIAlertView *alertView = nil;
    
    alertView = [[UIAlertView alloc] initWithTitle:notification.alertBody
                                               message:@""
                                              delegate:self
                                     cancelButtonTitle:kCloseButtonTitle
                                     otherButtonTitles:nil];
 
    [alertView show];
    */
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:notification.alertBody message:notification.alertTitle preferredStyle:UIAlertControllerStyleAlert];
    
    //UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self dismissViewControllerAnimated: YES completion: nil];}];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:ok];
    
    UIViewController *rootController = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    [rootController presentViewController:alertController animated:YES completion:nil];
    
    if([rootController isKindOfClass:[UINavigationController class]])
    {
        rootController=[((UINavigationController *)rootController).viewControllers objectAtIndex:0];
    }
    
    NSLog(@"alertAction: %@",notification.alertAction);
    
    //TODO: update active notifications table:
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocalNotificationsUpdate" object:nil userInfo:nil];

    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler{
    if ([identifier isEqualToString:NotificationActionOneIdent]) {
        
        NSLog(@"You chose action 1.");
    }
    else if ([identifier isEqualToString:NotificationActionTwoIdent]) {
        
        NSLog(@"You chose action 2.");
    }
    if (completionHandler) {
        
        completionHandler();
    }
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    
    reply(@{@"insert counter value":@(1)});
    
    NSString *counterValue = [userInfo objectForKey:@"counterValue"];
    if (!self.tempCounterData) {
        self.tempCounterData = [[NSMutableArray alloc] init];
    }
    
    [self.tempCounterData addObject:counterValue];
 
    //TODO
 //   [self scheduleNotification:[counterValue intValue] alertBody:kScheduleNextDoseMessage];
    
    
    
    
}

- (void)registerForNotification {
    
    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:@"Action 1"];
    [action1 setIdentifier:NotificationActionOneIdent];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Action 2"];
    [action2 setIdentifier:NotificationActionTwoIdent];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action3;
    action3 = [[UIMutableUserNotificationAction alloc] init];
    [action3 setActivationMode:UIUserNotificationActivationModeBackground];
    [action3 setTitle:@"30 min"];
    [action3 setIdentifier:@"ACTION_TREE"];
    [action3 setDestructive:NO];
    [action3 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdent];
    [actionCategory setActions:@[action3, action2, action1]
                    forContext:UIUserNotificationActionContextDefault];
    [actionCategory setActions:@[action2, action1]
                    forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (void) scheduleNotification:(NSInteger)minutesValue alertBody:(NSString*)alertBody alertTitle:(NSString*) alertTitle
{

        // Convert minutes to seconds
        // NSInteger seconds = minutesValue*60;
    
    //    TEMPORARY TO SPEEDUP TESTING: IN PRODUCTION TO BE CHANGE TO LINE ABOVE
    NSInteger seconds = minutesValue*10;
        
        NSLog(@"Setting alarm for %ld seconds", (long)seconds);
        
        // Schedule local notification
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = alertBody;
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertTitle = alertTitle;
    
    notification.hasAction = YES;
    notification.alertAction = @"Pull down to interact :))";
    notification.category = NotificationCategoryIdent;
    
    notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] scheduledLocalNotifications].count ;
        
        NSLog(@"Local Notification %@", notification);
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    /*
     Performs the specified selector on the current thread during the next run loop cycle and after an optional delay period. Because it waits until the next run loop cycle to perform the selector, these methods provide an automatic mini delay from the currently executing code.
     
     http://stackoverflow.com/questions/28985812/uiapplication-sharedapplication-scheduledlocalnotifications-is-always-empty
    */
    [self performSelector:@selector(postNotification) withObject:nil afterDelay:0];
   
}
-(void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocalNotificationsUpdate" object:nil userInfo:nil];
}
@end
