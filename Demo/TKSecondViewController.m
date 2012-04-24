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
@implementation TKSecondViewController{
	//Тут лежит список имен файлов текстур
	NSArray *pics;
	ASPGLSprite *earth;
    ASPGLSprite *mars;
	ASPGLSprite *ball;
}


//Тут желательно прогрузить все текстуры и насоздавать спрайтов.
#define XSPEED (rand()%600)
#define YSPEED (rand()%200)
#define GCONSTEARTH 15000
#define GCONSTMARS 5000
- (void)viewDidLoad
{
    [super viewDidLoad];
	//Заполняем список
	self.backgroundColor=GLKVector3Make(0.3, 0.4, 0.3);
//	pics = [NSArray arrayWithObjects:@"Space_Invaders_by_maleiva.png",@"spaceinvaders.png",@"tits.png",nil];
    
    mars = [ASPGLSprite spriteWithTextureName:@"ball.png" effect:self.effect];
    //Выставляем параметры созданного спрайта
    mars.velocity=GLKVector2Make(0,0);
    mars.contentSize=CGSizeMake(120,120);
    mars.position=GLKVector2Make(self.viewIOSize.width/2, self.viewIOSize.height/2-earth.contentSize.height/2);

	
    earth = [ASPGLSprite spriteWithTextureName:@"ball.png" effect:self.effect];
    //Выставляем параметры созданного спрайта
    earth.velocity=GLKVector2Make(0,0);
    earth.contentSize=CGSizeMake(70,70);
    earth.position=GLKVector2Make(self.viewIOSize.width/2-30, self.viewIOSize.height/2-earth.contentSize.height/2-90);

    
    ball = [ASPGLSprite spriteWithTextureName:@"ball.png" effect:self.effect];
	//Выставляем параметры созданного спрайта
    ball.velocity=GLKVector2Make(0, 150);
    ball.contentSize=CGSizeMake(30,30);
    ball.position=GLKVector2Make(self.viewIOSize.width/2+30, 0);
	
	[self.sprites addObject:ball];
    [self.sprites addObject:mars];
	//[self.sprites addObject:earth];
}

-(void) recalculateVelocityWalls:(ASPGLSprite*)sp{
    //Стенки
    if ((sp.position.x+sp.contentSize.width/2>self.viewIOSize.width)||(sp.position.x-sp.contentSize.width/2<0)){
        sp.velocity=GLKVector2Make(-sp.velocity.x, sp.velocity.y);
    }
    if((sp.position.y<0)||(sp.position.y+sp.contentSize.height>self.viewIOSize.height)){
		sp.velocity=GLKVector2Make(sp.velocity.x, -sp.velocity.y);
    }
}

-(void) recalculateVelocityEarth:(ASPGLSprite*)sp {
    // Здесь мы рассчитываем новую скорость шарика под действием силы тяжести Земли
    
    GLfloat dx=earth.position.x-sp.position.x+sp.contentSize.height/2; // Разность X координат
    GLfloat dy=earth.position.y-sp.position.y; // разность Y координат
    GLKVector2 vect=GLKVector2Make(dx, dy); // Направление действия силы
    vect=GLKVector2Normalize(vect); // Привели к единичной длине
    CGFloat acceleration = GCONSTEARTH/(dx*dx + dy*dy); // Модуль силы
    vect=GLKVector2MultiplyScalar(vect, acceleration); // Задали направление ускорения
    sp.velocity=GLKVector2Add(sp.velocity, vect); // Добавляем изменения
}


-(void) recalculateVelocityMars:(ASPGLSprite*)sp {
    // Здесь мы рассчитываем новую скорость шарика под действием силы тяжести Марса
    GLKVector2 vect=GLKVector2Subtract(mars.centerPosition,sp.centerPosition); // вектор, соединяющий середины шариков
    float length = GLKVector2Length(vect);
    if( length <= 60 ){ // Если мы упали на Планету
        sp.velocity=GLKVector2Mirror(sp.velocity, GLKVector2Subtract(mars.centerPosition,sp.centerPosition));
        return;
    }
    vect=GLKVector2Normalize(vect); // Привели к единичной длине
    CGFloat acceleration = 9.8;// Модуль силы
    vect=GLKVector2MultiplyScalar(vect, acceleration); // Задали направление ускорения
    sp.velocity = GLKVector2Add(sp.velocity, vect); // Наша новая скорость      
}

//Тут нужно очистить кэш и sprites
- (void)viewDidUnload 
{
    [super viewDidUnload];
    pics=nil;
	//[ASPGLSprite clearTextureCache];
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

//Этот метод дергается каждый раз, когда GLKit решит, что пора бы
//пересчитать логику. Соответственно тут нужно раздать указания
//sprite'ам, что им делать и дернуть у них update
- (void)update{
    
	//Тут логика игры и раздача пиздюлей спрайтам.
    //[self recalculateVelocityEarth:ball];
    [self recalculateVelocityMars:ball];
    [self recalculateVelocityWalls:ball];
    NSLog(@"%f %f",ball.velocity.x, ball.velocity.y);
    [ball update:self.timeSinceLastUpdate];
}
//Отменяем себя
-(IBAction)dismiss:(id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

@end
