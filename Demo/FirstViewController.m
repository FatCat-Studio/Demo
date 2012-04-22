//
//  FirstViewController.m
//  Demo
//
//  Created by Руслан Федоров on 4/22/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//


#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController{
	//Тут лежит список имен файлов текстур
	NSArray *pics;
	CGPoint touchPos;
	BOOL touching;
}

//Тут желательно прогрузить все текстуры и насоздавать спрайтов. 
- (void)viewDidLoad{
    [super viewDidLoad];
	//Заполняем список
	pics = [NSArray arrayWithObjects:@"Space_Invaders_by_maleiva.png",@"spaceinvaders.png",nil];
	self.player=[ASPGLSprite spriteWithTextureName:@"player.png" effect:self.effect];
	self.player.hidden=YES;
	self.player.contentSize=CGSizeMake(200, 200);
	self.player.layer=1;
	
}
- (void)viewDidUnload{
    [super viewDidUnload];
    pics=nil;
	[ASPGLSprite clearTextureCache];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	[super glkView:view drawInRect:rect];
    for (ASPGLSprite *sp in self.sprites) {
		[sp render];
	}
	if (touching) {
	[self.player render];
	}
}


#define XSPEED (rand()%600)
#define YSPEED (rand()%200)

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
		sprite.velocity=GLKVector2Make(-300+XSPEED, YSPEED);
		sprite.contentSize=CGSizeMake(20+rand()%100,20+rand()%100);
		sprite.position=GLKVector2Make(self.viewIOSize.width/2, -sprite.contentSize.height);
		//Смотрим, лежит ли спрайт в списке спрайтов и если нет - добавляем его туда
		if (![self.sprites containsObject:sprite]){
			[self.sprites addObject:sprite];
			NSLog(@"Now there is %d sprites!",[self.sprites count]);
			[sprite enableDebugOnView:self.view];
		}
	}
	//Тут логика игры и раздача пиздюлей спрайтам.
	for (ASPGLSprite *sp in self.sprites){
		if ((sp.position.y>self.viewIOSize.height)||
			(sp.position.y<-sp.contentSize.height-1))
			[sp outOfView];
		[self recalculateVelocity:sp];
		[sp update:self.timeSinceLastUpdate];
    }
	if (touching){
		self.player.position=GLKVector2Make(touchPos.x, touchPos.y-self.player.contentSize.height/2);
		self.player.hidden=NO;
	}
	a+=8;
}

-(void)recalculateVelocity:(ASPGLSprite*)sp{
	//Стенки
    if (sp.position.x-sp.contentSize.width/2>self.viewIOSize.width) {
		GLKVector2 rightWallVelocity = GLKVector2Make(-5, 0);
        sp.velocity=GLKVector2Add(sp.velocity, rightWallVelocity);
    }else if(sp.position.x+sp.contentSize.width/2<0){
		GLKVector2 leftWallVelocity = GLKVector2Make(5, 0);
        sp.velocity=GLKVector2Add(sp.velocity, leftWallVelocity);
		
    }
	//Палец
    if(touching){
		GLfloat dx=touchPos.x-sp.position.x;
		GLfloat dy=touchPos.y-sp.position.y;
		GLKVector2 vect=GLKVector2Make(dx, dy);
		CGFloat length=100-GLKVector2Length(vect);
		vect=GLKVector2Normalize(vect);
		if (length>0)
			vect=GLKVector2MultiplyScalar(vect, length);
        sp.velocity=GLKVector2Add(sp.velocity, vect);
    }
	//Сила Архимеда нах
	
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=YES;
	CGPoint point=[[touches anyObject] locationInView:self.view];
	touchPos=CGPointMake(point.x, self.viewIOSize.height-point.y);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint point=[[touches anyObject] locationInView:self.view];
	touchPos=CGPointMake(point.x, self.viewIOSize.height-point.y);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=NO;
}


@end
