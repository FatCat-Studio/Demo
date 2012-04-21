//
//  ASPGLKMainVIewController.m
//  Demo
//
//  Created by Руслан Федоров on 4/20/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "ASPGLKMainVIewController.h"
#import "ASPGLSprite.h"
@interface ASPGLKMainVIewController (){
}
@property (strong) GLKBaseEffect * effect;
@property (strong) ASPGLSprite * player;
@property (strong,nonatomic) EAGLContext *context;
@property (strong,nonatomic) NSMutableArray *sprites;
@property (readonly,getter = getViewIOSize) CGSize viewIOSize;
@end
@implementation ASPGLKMainVIewController
@synthesize context=_context,player=_player,effect=_eff,sprites=_sprites,viewIOSize;
-(CGSize)getViewIOSize{
	if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])){
		return self.view.bounds.size;
	}else{
		return self.view.bounds.size;
	}
}

#pragma mark Load
- (void) setupGL{
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	if (!_context)
		NSLog(@"Failed to create openGL context");
	((GLKView*)self.view).context=_context;
	[EAGLContext setCurrentContext:_context];
	self.preferredFramesPerSecond=60;
	self.effect = [[GLKBaseEffect alloc] init];
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0,self.viewIOSize.width, 0, self.viewIOSize.height, -1024, 1024);
	//GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), self.viewIOSize.height/self.viewIOSize.width, -4.0f, 10.0f);
	self.effect.transform.projectionMatrix = projectionMatrix;
	self.sprites=[NSMutableArray arrayWithCapacity:10];
}
- (void) viewDidLoad{
	srand(time(NULL));
	[super viewDidLoad];
	[self setupGL];
}
#pragma mark Unload
- (void) tearDownGL{
	if ([EAGLContext currentContext]==_context){
		[EAGLContext setCurrentContext:nil];
	}
	self.context=nil;
}
- (void) viewDidUnload{
	[self tearDownGL];
	[super viewDidUnload];
	
}
#pragma -
#pragma mark Stuff
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
		self.effect.transform.projectionMatrix=GLKMatrix4MakeOrtho(0,self.viewIOSize.width, 0, self.viewIOSize.height, -1024, 1024);

}
#pragma mark Drawing
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	glClearColor(0.2, 0.2, 0.2, 1);
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
	
    for (ASPGLSprite *sp in _sprites) {
		[sp render];
	}
}
#define XSPEED (rand()%600)
#define YSPEED (rand()%200)
- (void)update{
	static char a=0;
	if (!a) {

		ASPGLSprite *sprite=[ASPGLSprite spriteWithTextureName:@"Space_Invaders_by_maleiva.png" effect:self.effect];
		if (!sprite){
			NSLog(@"Failed to create a sprite");
			return;
		}
		sprite.moveVelocity=GLKVector2Make(-300+XSPEED, YSPEED);
		sprite.contentSize=CGSizeMake(20+rand()%100,20+rand()%100);
		sprite.position=GLKVector2Make(self.viewIOSize.width/2, -sprite.contentSize.height);
		if (![_sprites containsObject:sprite]){
			[_sprites addObject:sprite];
		}
	}
	for (ASPGLSprite *sp in _sprites){
		[sp update:self.timeSinceLastUpdate];
		if (sp.position.y>self.viewIOSize.height)
			[sp outOfView];
		if (sp.position.x+sp.contentSize.width>self.viewIOSize.width) {
			sp.moveVelocity=GLKVector2Make(-XSPEED, YSPEED);
		}else if(sp.position.x<0){
			sp.moveVelocity=GLKVector2Make(XSPEED, YSPEED);
		}
	}
	a+=8;
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	self.paused=!self.paused;
}
@end
