//
//  FirstViewController.m
//  Demo
//
//  Created by Руслан Федоров on 4/22/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//


#import "FirstViewController.h"

@interface FirstViewController ()
@property (strong) ASPGLSprite * player;
@end

static inline BOOL GLKVector2CompareRadious(GLKVector2 first,GLKVector2 second,CGFloat rad){
	return rad>=GLKVector2Distance(first, second);
}

@implementation FirstViewController{
	//Тут лежит список имен файлов текстур
	NSArray *pics;
	GLKVector2 touchPos;
	BOOL touching;
}
@synthesize player=_player;
//Тут желательно прогрузить все текстуры и насоздавать спрайтов. 
- (void)viewDidLoad{
    [super viewDidLoad];
	//Заполняем список
	pics = [NSArray arrayWithObjects:@"Space_Invaders_by_maleiva.png",@"spaceinvaders.png",nil];
	self.player=[ASPGLSprite spriteWithTextureName:@"player.png" effect:self.effect];
	self.player.hidden=YES;
	self.player.contentSize=CGSizeMake(200, 200);
	
}
- (void)viewDidUnload{
    [super viewDidUnload];
    pics=nil;
	[ASPGLSprite clearTextureCache];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	[super glkView:view drawInRect:rect];
	if (touching) {
		[self.player render];
	}
}


#define XSPEED (200)
#define YSPEED (0)

- (void)update{
	static char a=0;
	if (!a) {
		//Вот так правильно создавать спрайты. rand%[pics count] обеспечивает рандомную текстуру
		ASPGLSprite *sprite=[ASPGLSprite spriteWithTextureName:[pics objectAtIndex:rand()%[pics count]] effect:self.effect];
		if (!sprite){
			NSLog(@"Failed to create a sprite");
			return;
		}
		//Выставляем параметры созданного спрайта
		sprite.velocity=GLKVector2Make(XSPEED, YSPEED);
		sprite.contentSize=CGSizeMake(50,50);
		sprite.position=GLKVector2Make(self.viewIOSize.width/2, -sprite.contentSize.height);
		//Смотрим, лежит ли спрайт в списке спрайтов и если нет - добавляем его туда
		if (![self.sprites containsObject:sprite]){
			[self.sprites addObject:sprite];
			NSLog(@"Now there is %d sprites!",[self.sprites count]);
		//	[sprite enableDebugOnView:self.view];
		}
	}
	//Тут логика игры и раздача пиздюлей спрайтам.
	for (ASPGLSprite *sp in self.sprites){
		if ((sp.position.y>self.viewIOSize.height)||
			(sp.position.y<-sp.contentSize.height-1))
			[sp outOfView];
		if (touching){
			if (GLKVector2CompareRadious(sp.centerPosition, _player.centerPosition,10.))
				[sp outOfView];
		}
		[self recalculateVelocity:sp];
		[sp update:self.timeSinceLastUpdate];
		
    }
	if (touching){
		self.player.position=GLKVector2Make(touchPos.x, touchPos.y-self.player.contentSize.height/2);
		self.player.hidden=NO;
	}
	a+=16;
}

-(void)recalculateVelocity:(ASPGLSprite*)sp{
	//Стенки
#define WALLFORCEX 20
#define WALLFORCEY 10
    if (sp.position.x+sp.contentSize.width/2>self.viewIOSize.width) {
		GLKVector2 rightWallVelocity = GLKVector2Make(-WALLFORCEX, WALLFORCEY);
        sp.velocity=GLKVector2Add(sp.velocity, rightWallVelocity);
    }else if(sp.position.x-sp.contentSize.width/2<0){
		GLKVector2 leftWallVelocity = GLKVector2Make(WALLFORCEX, WALLFORCEY);
        sp.velocity=GLKVector2Add(sp.velocity, leftWallVelocity);

    }else{
		CGFloat dvx=sp.velocity.x,ndvx=0;
		if (dvx!=XSPEED&&dvx!=-XSPEED){
			if (dvx<0)
				ndvx=-XSPEED-dvx;
			else {
				ndvx=XSPEED-dvx;
			}
		}
		CGFloat dvy=sp.velocity.y,ndvy=0;
		if (dvy!=YSPEED&&dvy!=-YSPEED){
			if (dvy<0)
				ndvy=-YSPEED-dvy;
			else
				ndvy=YSPEED-dvy;
		}
		if (abs(ndvx)<0.1 )ndvx*=10;
		if (abs(ndvy)<0.1) ndvy*=10;
		GLKVector2 ndv=GLKVector2Make(ndvx/10, ndvy/10);
		sp.velocity=GLKVector2Add(sp.velocity, ndv);
	}
	//Палец
    if(touching){
		if (GLKVector2CompareRadious(touchPos, sp.centerPosition, 100)){
			GLKVector2 direction=GLKVector2Subtract(touchPos, sp.centerPosition);
			GLfloat distance=GLKVector2Length(direction);
			GLfloat width=sp.contentSize.width;
			GLfloat height=sp.contentSize.height;
			sp.contentSize=CGSizeMake(width-1, height-1);
			direction=GLKVector2Normalize(direction);
			sp.velocity=GLKVector2Add(sp.velocity,GLKVector2MultiplyScalar(direction, 100-distance));
		}
	}	
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=YES;
	CGPoint point=[[touches anyObject] locationInView:self.view];
	touchPos=GLKVector2Make(point.x, self.viewIOSize.height-point.y);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=NO;
}

-(IBAction)pause:(id)sender{
	self.paused=!self.paused;
}


@end