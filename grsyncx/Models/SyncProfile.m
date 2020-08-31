//
//  SyncProfile.m
//  grsyncx
//
//  Created by Michi on 24/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "SyncProfile.h"
#import "UNXParsable.h"
#import "Foundation.h"

@implementation SyncProfile

#pragma mark - Initializers

- (instancetype)duplicate
{
	SyncProfile *copy = [SyncProfile new];

	copy.UUID = [NSUUID UUID];
	copy.name = _name;
	copy.sourcePath = _sourcePath;
	copy.destinationPath = _destinationPath;
	copy.wrapInSourceFolder = _wrapInSourceFolder;
	copy.basicProperties = _basicProperties;
	copy.advancedProperties = _advancedProperties;
	copy.additionalOptions = _additionalOptions;

	return copy;
}

+ (instancetype)defaultProfile
{
	SyncProfile *def = [SyncProfile new];

	def.wrapInSourceFolder = YES;

	def.basicProperties =
		RSyncBasicPropPreserveTime | RSyncBasicPropPreservePermissions |
		RSyncBasicPropPreserveOwner | RSyncBasicPropPreserveGroup |
		RSyncBasicPropPreserveExtAttrs | RSyncBasicPropDeleteOnDest |
		RSyncBasicPropVerbose | RSyncBasicPropShowTransProgress;

	def.advancedProperties =
		RSyncAdvancedPropPreserveSymlinks | RSyncAdvancedPropShowItemizedChanges;

	return def;
}

- (instancetype)initFromDictionary:(NSDictionary *)dict
{
	NSString *uuid = dict.unx_parsable[@"UUID"].string;
	NSString *name = dict.unx_parsable[@"Name"].string;

	if (self = [super init])
	{
		if (uuid) _UUID = [[NSUUID alloc] initWithUUIDString:uuid];
		if (name) _name = name;
		_sourcePath = dict.unx_parsable[@"Source"].string;
		_destinationPath = dict.unx_parsable[@"Destination"].string;
		_wrapInSourceFolder = dict.unx_parsable[@"WrapInSrcFolder"].number.boolValue;
		_basicProperties = dict.unx_parsable[@"BasicProps"].number.unsignedIntegerValue;
		_advancedProperties = dict.unx_parsable[@"AdvProps"].number.unsignedIntegerValue;
		_additionalOptions = dict.unx_parsable[@"CustomOpts"].string;
	}

	return self;
}

- (NSDictionary *)asDictionary
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:8];

	id obj = nil;

	if ((obj = [_UUID UUIDString]))
		dict[@"UUID"] = obj;
	if ((obj = _name))
		dict[@"Name"] = obj;

	if ((obj = _sourcePath))
		dict[@"Source"] = obj;

	if ((obj = _destinationPath))
		dict[@"Destination"] = obj;

	dict[@"WrapInSrcFolder"] = @(_wrapInSourceFolder);

	dict[@"BasicProps"] = @(_basicProperties);
	dict[@"AdvProps"] = @(_advancedProperties);

	if ((obj = _additionalOptions))
		dict[@"CustomOpts"] = obj;

	return [dict copy];
}

#pragma mark - Getters

- (NSString *)displayableName
{
	NSString *name = _name;

	if (!name)
		name = (_UUID) ?
			NSLocalizedString(@"Unnamed", @"Default sync profile name"):
			NSLocalizedString(@"Default", @"Default sync profile name");

	return name;
}

- (NSString *)calculatedSourcePath
{
	NSString *path = [_sourcePath copy];

	if (path && !_wrapInSourceFolder)
		path = [path stringByAppendingString:@"/"];

	return path;
}

- (NSString *)calculatedDestinationPath
{
	return [_destinationPath copy];
}

- (NSArray<NSString *> *)calculatedArguments
{
	NSMutableArray<NSString *> *args = [NSMutableArray arrayWithCapacity:32];

	#define HAS(x) ((x) > 0)

	RSyncBasicProp basic = _basicProperties;

	if (HAS(basic & RSyncBasicPropPreserveTime))           [args addObject:@"-t"];
	if (HAS(basic & RSyncBasicPropPreservePermissions))    [args addObject:@"-p"];
	if (HAS(basic & RSyncBasicPropPreserveOwner))          [args addObject:@"-o"];
	if (HAS(basic & RSyncBasicPropPreserveGroup))          [args addObject:@"-g"];
	if (HAS(basic & RSyncBasicPropPreserveExtAttrs))       [args addObject:@"-E"];

	if (HAS(basic & RSyncBasicPropDeleteOnDest))           [args addObject:@"--delete"];
	if (HAS(basic & RSyncBasicPropDontLeaveFilesyst))      [args addObject:@"-x"];
	if (HAS(basic & RSyncBasicPropVerbose))                [args addObject:@"-v"];
	if (HAS(basic & RSyncBasicPropShowTransProgress))      [args addObject:@"--progress"];
	if (HAS(basic & RSyncBasicPropIgnoreExisting))         [args addObject:@"--ignore-existing"];
	if (HAS(basic & RSyncBasicPropSizeOnly))               [args addObject:@"--size-only"];
	if (HAS(basic & RSyncBasicPropSkipNewer))              [args addObject:@"--update"];
	if (HAS(basic & RSyncBasicPropWindowsCompat))          [args addObject:@"--modify-window=1"];

	RSyncAdvancedProp adv = _advancedProperties;

	if (HAS(adv & RSyncAdvancedPropAlwaysChecksum))        [args addObject:@"--checksum"];
	if (HAS(adv & RSyncAdvancedPropCompressFileData))      [args addObject:@"--compress"];
	if (HAS(adv & RSyncAdvancedPropPreserveDevices))       [args addObject:@"-D"];
	if (HAS(adv & RSyncAdvancedPropExistingFiles))         [args addObject:@"--existing"];
	if (HAS(adv & RSyncAdvancedPropPartialTransFiles))     [args addObject:@"-P"];
	if (HAS(adv & RSyncAdvancedPropNoUIDGIDMap))           [args addObject:@"--numeric-ids"];
	if (HAS(adv & RSyncAdvancedPropPreserveSymlinks))      [args addObject:@"-l"];
	if (HAS(adv & RSyncAdvancedPropPreserveHardLinks))     [args addObject:@"-H"];
	if (HAS(adv & RSyncAdvancedPropMakeBackups))           [args addObject:@"--backup"];
	if (HAS(adv & RSyncAdvancedPropShowItemizedChanges))   [args addObject:@"-i"];

	if (HAS(adv & RSyncAdvancedPropDisableRecursion))      [args addObject:@"-d"];
	else                                                   [args addObject:@"-r"];

	if (HAS(adv & RSyncAdvancedPropProtectRemoteArgs))     [args addObject:@"-s"];

	NSArray<NSString *> *additionalArgs =
	[[_additionalOptions componentsSeparatedByString:@" "]
	 filteredArrayUsingBlock:^BOOL(NSString *element) {
		return element.length > 0;
	}];

	if (additionalArgs.count)
		[args addObjectsFromArray:additionalArgs];

	if (_simulatedRun)
		[args addObject:@"-n"];

	return [args copy];
}

@end
