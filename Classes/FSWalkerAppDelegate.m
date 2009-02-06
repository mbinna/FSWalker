//
//  FSWalkerAppDelegate.m
//  FSWalker
//
//  Created by Nicolas Seriot on 17.08.08.
//  Copyright Sen:te 2008. All rights reserved.
//

#import "FSWalkerAppDelegate.h"
#import "RootViewController.h"
#import "InfoPanelController.h"
#import "DetailViewController.h"
#import "FSItem.h"
#import "HTTPServer.h"
#import "FSWHTTPConnection.h"
#import "MyIP.h"

@implementation FSWalkerAppDelegate

@synthesize window;
@synthesize navigationController;

- (NSString *)myIPAddress {
	NSString *myIP = [[[MyIP sharedInstance] ipsForInterfaces] objectForKey:@"en0"];
	
#if TARGET_IPHONE_SIMULATOR
	if(!myIP) {
		myIP = [[[MyIP sharedInstance] ipsForInterfaces] objectForKey:@"en1"];
	}
#endif
	
	return myIP;
}

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void)startHTTPServer {
	NSDictionary *ips = [[MyIP sharedInstance] ipsForInterfaces];
	BOOL isConnectedThroughWifi = [ips objectForKey:@"en0"] != nil;
	BOOL shouldStartServer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldStartServer"];
	
	if(shouldStartServer && (isConnectedThroughWifi || TARGET_IPHONE_SIMULATOR)) {
		httpServer = [[HTTPServer alloc] init];
		[httpServer setType:@"_http._tcp."];
		[httpServer setDocumentRoot:[NSURL fileURLWithPath:@"/"]];
		[httpServer setName:[NSString stringWithFormat:@"%@ on %@", [[NSProcessInfo processInfo] processName], [[NSProcessInfo processInfo] hostName]]];
		[httpServer setPort:20000];
		[httpServer setConnectionClass:[FSWHTTPConnection class]];
		
		NSError *error = nil;
		BOOL success = [httpServer start:&error];
		
		if(!success) {
			NSLog(@"Error starting HTTP Server.");
			
			if(error) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error starting HTTP Server"
																message:[error localizedDescription]
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles: nil];
				[alert show];
				[alert release];    
			}
		} else {
			[UIApplication sharedApplication].idleTimerDisabled = YES;

			BOOL shouldShowAlert = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowAlertWhenServerStarts"];
			if(shouldShowAlert) {
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HTTP Server is running!"
																message:[NSString stringWithFormat:@"The iPhone files are accessible at http://%@:%u/", [self myIPAddress], [httpServer port]]
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[alert show];
				[alert release]; 
			}
		}		
	}	
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:YES], @"ShouldStartServer",
							  [NSNumber numberWithBool:YES], @"ShowAlertWhenServerStarts",
							  [NSNumber numberWithBool:YES], @"XMLPlist", nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInfo:) name:@"ShowInfo" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDetail:) name:@"ShowDetail" object:nil];
	
	[self startHTTPServer];
	
	rootViewController.fsItem = [FSItem fsItemWithDir:@"/" fileName:@""];
	
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
	RootViewController *rvc;
	
	rvc = [[RootViewController alloc] init];
	rvc.fsItem = [FSItem fsItemWithDir:@"/" fileName:@"private"];
	[rootViewController.navigationController pushViewController:rvc animated:NO];
	[rvc release];
	
	rvc = [[RootViewController alloc] init];
	rvc.fsItem = [FSItem fsItemWithDir:@"/private/" fileName:@"var"];
	[rootViewController.navigationController pushViewController:rvc animated:NO];
	[rvc release];
	
	rvc = [[RootViewController alloc] init];
	rvc.fsItem = [FSItem fsItemWithDir:@"/private/var/" fileName:@"mobile"];
	[rootViewController.navigationController pushViewController:rvc animated:NO];
	[rvc release];
#else
	RootViewController *rvc;
	
	rvc = [[RootViewController alloc] init];
	rvc.fsItem = [FSItem fsItemWithDir:@"/" fileName:@"Users"];
	[rootViewController.navigationController pushViewController:rvc animated:NO];
	[rvc release];
	
	rvc = [[RootViewController alloc] init];
	rvc.fsItem = [FSItem fsItemWithDir:@"/Users" fileName:NSUserName()];
	[rootViewController.navigationController pushViewController:rvc animated:NO];
	[rvc release];
	
#endif
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowInfo" object:nil];
	
	if(httpServer) {
		[httpServer stop];
	}
	
	// TODO: save position?
}


- (void)dealloc {
	[httpServer release];
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)showInfo:(NSNotification *)notification {
	FSItem *fsItem = [notification object];
	infoPanelController.fsItem = fsItem;
	[navigationController presentModalViewController:infoPanelController animated:YES];
}

- (void)showDetail:(NSNotification *)notification {
	FSItem *fsItem = [notification object];
	detailViewController.fsItem = fsItem;
	[self.navigationController pushViewController:detailViewController animated:YES];
	
}

@end
