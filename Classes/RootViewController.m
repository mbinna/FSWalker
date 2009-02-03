//
//  RootViewController.m
//  FSWalker
//
//  Created by Nicolas Seriot on 17.08.08.
//  Copyright Sen:te 2008. All rights reserved.
//

#import "RootViewController.h"
#import "FSWalkerAppDelegate.h"
#import "FSItemCell.h"
#import "DetailViewController.h"

@implementation RootViewController

@dynamic fsItem;

- (void)setFsItem:(FSItem *)item {
	if(item != fsItem) {
		[item retain];
		[fsItem release];
		fsItem = item;

		self.title = fsItem.prettyFilename;
	}
}

- (FSItem *)fsItem {
	return fsItem;
}

- (void)viewDidLoad {
	// Add the following line if you want the list to be editable
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [fsItem.children count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"FSItemCell";
	
	FSItemCell *cell = (FSItemCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = (FSItemCell *)[[[NSBundle mainBundle] loadNibNamed:@"FSItemCell" owner:self options:nil] lastObject];
	}
	
	// Set up the cell
	FSItem *child = [fsItem.children objectAtIndex:indexPath.row];
	cell.fsItem = child;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	FSItem *child = [fsItem.children objectAtIndex:indexPath.row];
	
	if([child.posixPermissions intValue] == 0) return;

	NSString *path = [child.parent stringByAppendingPathComponent:child.filename];
	NSLog(@"did select %@", path);

	if(child.canBeFollowed) {
		RootViewController *rvc = [[RootViewController alloc] init];
		rvc.title = fsItem.filename;
		rvc.fsItem = child;
		[self.navigationController pushViewController:rvc animated:YES];
		[rvc release];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowDetail" object:child];
	}
}

/*
 Override if you support editing the list
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
		
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}	
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}	
}
*/


/*
 Override if you support conditional editing of the list
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}
*/


/*
 Override if you support rearranging the list
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
 Override if you support conditional rearranging of the list
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the item to be re-orderable.
	return YES;
}
 */ 


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = fsItem.prettyFilename;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[fsItem release];	
	[super dealloc];
}


@end

