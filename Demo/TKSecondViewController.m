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

@implementation TKSecondViewController
{
	//Тут лежит список имен файлов текстур
	NSArray *pics;
}

//Тут желательно прогрузить все текстуры и насоздавать спрайтов. 
- (void)viewDidLoad
{
    [super viewDidLoad];
	//Заполняем список
	self.backgroundColor=GLKVector3Make(0.3, 0.4, 0.3);
	pics = [NSArray arrayWithObjects:@"Space_Invaders_by_maleiva.png",@"spaceinvaders.png",@"tits.png",nil];
	
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
//Этот метод дергается каждый раз, когда GLKit решит, что пора бы
//пересчитать логику. Соответственно тут нужно раздать указания
//sprite'ам, что им делать и дернуть у них update
- (void)update{
	
	//Тут логика игры и раздача пиздюлей спрайтам.

}
//Отменяем себя
-(IBAction)dismiss:(id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

@end
