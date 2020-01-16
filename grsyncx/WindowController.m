//
//  WindowController.m
//  grsyncx
//
//  Created by Michal Zelinka on 13/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "WindowController.h"
#import "WindowActionsResponder.h"


@interface WindowController () <NSToolbarDelegate>

@property (nonatomic, weak) IBOutlet id<WindowActionsResponder> actionsResponder;

@end


@implementation WindowController

- (void)windowDidLoad
{
	[super windowDidLoad];

	NSViewController *vc = self.contentViewController;

	if ([vc conformsToProtocol:@protocol(WindowActionsResponder)])
		_actionsResponder = (id)self.contentViewController;
	else @throw @"Invalid Window actions responder";
}

- (IBAction)simulateButton:(__unused id)sender
{
	[_actionsResponder didReceiveSimulateAction];
}

- (IBAction)executeButton:(__unused id)sender
{
	[_actionsResponder didReceiveExecuteAction];
}

@end
