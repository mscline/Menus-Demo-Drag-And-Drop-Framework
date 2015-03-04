//
//  DemoStorefront.h
//  MCMenus
//
//  Created by xcode on 7/30/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MCDragAndDrop/MCDragAndDrop.h>

@interface DemoStorefront : NSObject <MCMenuDataSource>

  -(id)initForViewController:(UIViewController *)viewController;

@end
