/*****************************************************************************
 *
 * FILE:	AppDelegate.m
 * DESCRIPTION:	CalendarKitDemo: Application Main Controller
 * DATE:	Thu, Jan 28 2016
 * UPDATED:	Fri, Jan 29 2016
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2016 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2016 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: AppDelegate.m,v 1.1 2016/01/28 12:40:36 kouichi Exp $
 *
 *****************************************************************************/

#import "AppDelegate.h"
#import "RootViewController.h"

#define	APP_NAME \
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]

#define	APP_VERSION \
	[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

#define	APP_BUILD_VERSION \
	[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]


@interface AppDelegate () <UIApplicationDelegate>
@property (nonatomic,strong,readwrite) UIColor *	themeColor;
@property (nonatomic,assign) NSUserDefaults *		ud;
@property (nonatomic,getter=isAutolocked) BOOL		autolock;
@end

@implementation AppDelegate

#if     DEBUG
static void uncaughtExceptionHandler(NSException * exception)
{
  NSLog(@"CRASH: %@", exception);
  NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}
#endif	// DEBUG

#if	0
+(void)initialize
{
  dispatch_block_t	onceBlock = ^{
    NSUserDefaults *	ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *	dval = @{
    };
    [ud registerDefaults:dval];
    [ud synchronize];
  };
  static dispatch_once_t	onceToken;
  dispatch_once(&onceToken, onceBlock);
}
#endif

-(id)init
{
  self = [super init];
  if (self) {
    self.ud = [NSUserDefaults standardUserDefaults];

    [self configureAppearance];
  }
  return self;
}

/*****************************************************************************/

-(void)configureAppearance
{
  UIColor *	barColor = [self colorWithHex:0x5c3566];

  [[UINavigationBar appearance] setBarTintColor:barColor];
  [[UITabBar appearance] setBarTintColor:barColor];
  [[UIToolbar appearance] setBarTintColor:barColor];
  [[UISearchBar appearance] setBarTintColor:barColor];

  [[UISegmentedControl appearance] setTintColor:barColor];
  [[UIStepper appearance] setTintColor:barColor];
  [[UISwitch appearance] setOnTintColor:barColor];

  [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  self.themeColor = barColor;

  [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class]]]
    setTitleTextAttributes:@{
      NSForegroundColorAttributeName : [UIColor whiteColor]
    }
    forState:UIControlStateNormal];

  [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewHeaderFooterView class]]] setTextColor:barColor];
}

/*****************************************************************************/

#pragma mark - UIApplicationDelegate
-(BOOL)application:(UIApplication *)application
	didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if     DEBUG
  NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif	// DEBUG

  // set default idle timer setting
  self.autolock = application.idleTimerDisabled;

  // Create a full-screen window
  UIWindow *	window;
  window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  window.backgroundColor = [UIColor whiteColor];
  self.window = window;

  // Make root view controller
  RootViewController * rootViewController;
  rootViewController = [RootViewController new];
  UINavigationController * navigationController;
  navigationController = [[UINavigationController alloc]
			  initWithRootViewController:rootViewController];
  self.window.rootViewController = navigationController;

  // Show window
  [self.window makeKeyAndVisible];

  return YES;
}

#pragma mark - UIApplicationDelegate
/*
 * Sent when the application is about to move from active to inactive state.
 * This can occur for certain types of temporary interruptions (such as an
 * incoming phone call or SMS message) or when the user quits the application
 * and it begins the transition to the background state.
 * Use this method to pause ongoing tasks, disable timers, and throttle down
 * OpenGL ES frame rates. Games should use this method to pause the game.
 */
-(void)applicationWillResignActive:(UIApplication *)application
{
  // restore default idle timer setting
  application.idleTimerDisabled = self.isAutolocked;
}

#pragma mark - UIApplicationDelegate
/*
 * Use this method to release shared resources, save user data, invalidate
 * timers, and store enough application state information to restore your
 * application to its current state in case it is terminated later. 
 * If your application supports background execution, this method is called
 * instead of applicationWillTerminate: when the user quits.
 */
-(void)applicationDidEnterBackground:(UIApplication *)application
{
}

#pragma mark - UIApplicationDelegate
/*
 * Called as part of the transition from the background to the inactive state;
 * here you can undo many of the changes made on entering the background.
 */
-(void)applicationWillEnterForeground:(UIApplication *)application
{
}

#pragma mark - UIApplicationDelegate
/*
 * Restart any tasks that were paused (or not yet started)
 * while the application was inactive. If the application was previously
 * in the background, optionally refresh the user interface.
 */
-(void)applicationDidBecomeActive:(UIApplication *)application
{
  // disable idle timer
  application.idleTimerDisabled = YES;
}

#pragma mark - UIApplicationDelegate
-(void)applicationWillTerminate:(UIApplication *)application
{
  // restore default idle timer setting
  application.idleTimerDisabled = self.isAutolocked;
}

#pragma mark - UIApplicationDelegate
/*
 * This callback will be made upon calling
 * -[UIApplication registerUserNotificationSettings:]. The settings the user
 * has granted to the application will be passed in as the second argument.
 */
-(void)application:(UIApplication *)application
	didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
}

#pragma mark - UIApplicationDelegate
// Called at the forground processing
-(void)application:(UIApplication *)application
	didReceiveLocalNotification:(UILocalNotification *)notification
{
#if	DEBUG
  NSLog(@"DEBUG[receive] localNotif=%@",notification); 
#endif	// DEBUG
}

/*
 * Free up as much memory as possible by purging cached data objects
 * that can be recreated (or reloaded from disk) later.
 */
#pragma mark - Memory management
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
}

/*****************************************************************************/

#pragma mark - public method
-(UIColor *)textColor
{
  return [self colorWithHex:0xff7f7f];
}

#pragma mark - public method
// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
-(UIColor *)colorWithHex:(int)hex
{
  return [UIColor colorWithRed:((float)((hex & 0xff0000) >> 16)) / 255.0f
			 green:((float)((hex & 0xff00)   >>  8)) / 255.0f
			  blue:((float)( hex & 0xff)) / 255.0f
			 alpha:1.0f];
}

#pragma mark - public method
// Default UIBarButtonItem's color for iOS7
-(UIColor *)iOS7blueColor
{
  return ColorWithRGB(0.0f, 122.0f, 255.0f);
}

#pragma mark - public method
// Default UINavigationBar's background color for iOS7
-(UIColor *)iOS7barColor
{
  return ColorWithRGB(247.0f, 247.0f, 247.0f);
}

@end
