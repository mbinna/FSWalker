//
//  FSWalkerAppDelegate.h
//  FSWalker
//
//  Created by Nicolas Seriot on 17.08.08.
//  Copyright Sen:te 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class InfoPanelController;
@class DetailViewController;
@class HTTPServer;

@interface FSWalkerAppDelegate : NSObject <UIApplicationDelegate> {
	HTTPServer *httpServer;
	
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
	IBOutlet RootViewController *rootViewController;
	IBOutlet InfoPanelController *infoPanelController;
	IBOutlet DetailViewController *detailViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

