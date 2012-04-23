//
//  TKSecondViewController.m
//  Demo
//
//  Created by Руслан Федоров on 4/22/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

//Основные плюшки:
//self.sprites: NSMutableSet из всех спрайтов, которые принадлежат данному вью
//self.viewIOSize: Размер вью
//self.player: Спрайт игрока. Его тоже нужно добавлять в self.sprites или же писать для него
//	отдельный вызов апдейт, не в переболе всех элементов self.sprites

#import "TKSecondViewController.h"
#import "ASPGLSprite.h"

@implementation TKSecondViewController
{
	//Тут лежит список имен файлов текстур
	NSArray *pics;
	ASPGLSprite *earth;
	ASPGLSprite *ball;
}

//Тут желательно прогрузить все текстуры и насоздавать спрайтов.
#define XSPEED (rand()%600)
#define YSPEED (rand()%200)
#define GCONST 10
- (void)viewDidLoad
{
    [super viewDidLoad];
	//Заполняем список
	self.backgroundColor=GLKVector3Make(0.3, 0.4, 0.3);
	pics = [NSArray arrayWithObjects:@"Space_Invaders_by_maleiva.png",@"spaceinvaders.png",@"tits.png",nil];
	
    earth = [ASPGLSprite spriteWithTextureName:@"ball.png" effect:self.effect];
    //Выставляем параметры созданного спрайта
    earth.velocity=GLKVector2Make(0,0);
    earth.contentSize=CGSizeMake(150,150);
    earth.position=GLKVector2Make(self.viewIOSize.width/2, self.viewIOSize.height/2-earth.contentSize.height/2);

    
   ball = [ASPGLSprite spriteWithTextureName:@"ball.png" effect:self.effect];
	//Выставляем параметры созданного спрайта
    ball.velocity=GLKVector2Make(0, 100);
    ball.contentSize=CGSizeMake(70,70);
    ball.position=GLKVector2Make(self.viewIOSize.width/2+100, 0);
    
}

-(void) recalculateVelocityWalls:(ASPGLSprite*)sp{
    //Стенки
    if (sp.position.x-sp.contentSize.width/2>self.viewIOSize.width) {
        sp.velocity=GLKVector2Make(-sp.velocity.x, sp.velocity.y);
    }else if(sp.position.x+sp.contentSize.width/2<0){
		sp.velocity=GLKVector2Make(-sp.velocity.x, sp.velocity.y);
    }
}

-(void) recalculateVelocityEarth:(ASPGLSprite*)sp{
    // Здесь мы рассчитываем новую скорость шарика под действием силы тяжести Земли
    
    GLfloat dx=earth.position.x-sp.position.x; // Разность X координат
    GLfloat dy=earth.position.x-sp.position.y; // разность Y координат
    GLKVector2 vect=GLKVector2Make(dx, dy); // Направление действия силы
    vect=GLKVector2Normalize(vect); // Привели к единичной длине
    CGFloat acceleration = GCONST/(dx*dx + dy*dy); // Модуль силы
    vect=GLKVector2MultiplyScalar(vect, acceleration); // Задали направление ускорения
    sp.velocity=GLKVector2Add(sp.velocity, vect); // Добавляем изменения
}
//Тут нужно очистить кэш и sprites
- (void)viewDidUnload 
{
    [super viewDidUnload];
    pics=nil;
	[ASPGLSprite clearTextureCache];
}

//Тут - отрисовка. Т.е у каждого спрайта, который ты хочешь отрисовать
//Ты должен дернуть render. В моем классе ASPGLKViewController
//от которого ты наследуешся есть массив sprites в котором хранятся
//все спрайты. Туда ты их и обязан класть при создании
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	[super glkView:view drawInRect:rect];
    for (ASPGLSprite *sp in self.sprites) {
		[sp render];
	}
}

- (ASPGLSprite *) makeRandomSprite{
    //Вот так правильно создавать спрайты. rand%[pics count] обеспечивает рандомную текстуру
    ASPGLSprite *sprite=[ASPGLSprite spriteWithTextureName:[pics objectAtIndex:rand()%[pics count]] effect:self.effect];
    if (!sprite){
        NSLog(@"Failed to create a sprite");
        return nil;
    }
    return sprite;
}

//Этот метод дергается каждый раз, когда GLKit решит, что пора бы
//пересчитать логику. Соответственно тут нужно раздать указания
//sprite'ам, что им делать и дернуть у них update
- (void)update{
	//Тут логика игры и раздача пиздюлей спрайтам.
    [self recalculateVelocityEarth:ball];
    [self recalculateVelocityWalls:ball];
    [ball update:self.timeSinceLastUpdate];
}
//Отменяем себя
-(IBAction)dismiss:(id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

@end
