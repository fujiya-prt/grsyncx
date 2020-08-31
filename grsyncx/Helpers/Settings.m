//
//  Settings.m
//  grsyncx
//
//  Created by Michi on 29/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "Settings.h"
#import "Notifications.h"
#import "UNXParsable.h"

@interface Settings ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation Settings

+ (Settings *)shared
{
	static Settings *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});

	return shared;
}

- (instancetype)init
{
	if (self = [super init])
	{
		_defaults = [NSUserDefaults standardUserDefaults];

		NSDictionary *lastProfileDict = [_defaults dictionaryForKey:@SETTINGS_KEY_LAST_USED_PROFILE];
		SyncProfile *lastProfile = nil;
		if (lastProfileDict) lastProfile = [[SyncProfile alloc] initFromDictionary:lastProfileDict];
		if (!lastProfile) lastProfile = [SyncProfile defaultProfile];
		_lastUsedProfile = lastProfile;

		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(appWillTerminateNotification)
			name:GRSAppWillTerminateNotification object:nil];
	}

	return self;
}

- (void)appWillTerminateNotification
{
	[self saveSettings];
}

- (void)saveSettings
{
	[_defaults setObject:_lastUsedProfile.asDictionary forKey:@SETTINGS_KEY_LAST_USED_PROFILE];
}

@end
