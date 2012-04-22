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
}

//Тут желательно прогрузить все текстуры и насоздавать спрайтов. 
- (void)viewDidLoad{
    [super viewDidLoad];
	//Заполняем список
	pics = [NSArray arrayWithObjects:@"Space_Invaders_by_maleiva.png",@"spaceinvaders.png",@"tits.png",nil];
	
}
- (void)viewDidUnload{
    [super viewDidUnload];
    pics=nil;
	[ASPGLSprite clearTextureCache];
}
#define XSPEED (rand()%600)
#define YSPEED (rand()%200)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	[super glkView:view drawInRect:rect];
    for (ASPGLSprite *sp in self.sprites) {
		[sp render];
	}
}

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
		}
	}
	//Тут логика игры и раздача пиздюлей спрайтам.
	for (ASPGLSprite *sp in self.sprites){
		if (sp.position.y>self.viewIOSize.height){
			[sp outOfView];
		}else if (sp.position.x+sp.contentSize.width>self.viewIOSize.width) {
			sp.velocity=GLKVector2Make(-XSPEED, YSPEED);
		}else if(sp.position.x<0){
			sp.velocity=GLKVector2Make(XSPEED, YSPEED);
		}
		[sp update:self.timeSinceLastUpdate];
	}
	a+=8;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];   
    CGPoint currentPoint = [touch locationInView:self.view];
	for (ASPGLSprite *sp in self.sprites){
		
	}
}


@end
