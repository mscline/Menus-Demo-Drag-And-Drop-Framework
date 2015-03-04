//
//  ViewController.m
//  MCMenus
//
//  Created by xcode on 4/23/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "ViewController.h"
#import "DemoStorefront.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DemoStorefront *demo;
    demo = [[DemoStorefront alloc]initForViewController:self];

}

@end