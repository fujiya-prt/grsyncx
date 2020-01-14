//
//  SyncingViewController.h
//  grsyncx
//
//  Created by Michal Zelinka on 14/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SyncingOptions : NSObject

@property (nonatomic, copy, nullable) NSString *sourcePath;
@property (nonatomic, copy, nullable) NSString *destinationPath;

@property (nonatomic, copy, nullable) NSArray<NSString *> *arguments;

@end

@interface SyncingViewController : NSViewController

@property (nonatomic, strong, nullable) SyncingOptions *syncingOptions;

+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
