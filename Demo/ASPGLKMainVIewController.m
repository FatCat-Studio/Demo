//
//  ASPGLKMainVIewController.m
//  Demo
//
//  Created by Руслан Федоров on 4/20/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "ASPGLKMainVIewController.h"
@interface ASPGLKMainVIewController (){
	
}
@property (strong,nonatomic) EAGLContext *context;
@end
@implementation ASPGLKMainVIewController
@synthesize context=_context;
#pragma mark Load
- (void) viewDidLoad{
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
}
#pragma mark Unload
#pragma -

@end
