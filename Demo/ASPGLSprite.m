//
//  ASPGLSprite.m
//  Demo
//
//  Created by Руслан Федоров on 4/20/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "ASPGLSprite.h"
#define DEFAULT_AR YES
#define DEFAULT_BOUNDS CGSizeMake(0,0)
#define DEFAULT_POS GLKVector2Make(0,0)

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;    
    TexturedVertex tl;
    TexturedVertex tr;    
} TexturedQuad;

//GLOBALS
static NSMutableSet *__ASPGLFreeSprites;
static NSCache *__ASPGLTextureCache;

@interface ASPGLSprite()
@property (strong) GLKBaseEffect * effect;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo * textureInfo;
+ (void) addSpriteToFreeCache:(ASPGLSprite*)sp;
@end

@implementation ASPGLSprite
@synthesize effect = _effect, quad = _quad, textureInfo = _textureInfo;
@synthesize position = _position, contentSize = _contentSize, moveVelocity = _moveVelocity, fileName=_fileName;
@synthesize hidden=_hidden, rotation=_rotation;

#pragma mark Class Methods
+ (ASPGLSprite*) spriteWithTextureName:(NSString*)fileName effect:(GLKBaseEffect*)effect{
	if (__ASPGLFreeSprites)
	for (ASPGLSprite *sp in __ASPGLFreeSprites){
		if (![sp.fileName compare:fileName]){
			sp.hidden=NO;
			[__ASPGLFreeSprites removeObject:sp];
			return sp;
		}
	}
	return [[ASPGLSprite alloc] initWithFile:fileName effect:effect];
}
+ (void) addSpriteToFreeCache:(ASPGLSprite*)sp{
	if (!__ASPGLFreeSprites){
		__ASPGLFreeSprites=[[NSMutableSet alloc] init];
	}
	[__ASPGLFreeSprites addObject:sp];
}
+ (GLKTextureInfo*) loadTextureToStorage:(NSString*)fileName{
	if (!__ASPGLTextureCache){
		__ASPGLTextureCache=[[NSCache alloc] init];
	}
	NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:YES],
							  GLKTextureLoaderOriginBottomLeft, 
							  nil];
	NSError *error;    
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
	GLKTextureInfo *texture=[GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
	if (texture==nil){
		NSLog(@"Failed to load texture: %@",[error localizedDescription]);
		return nil;
	}
	[__ASPGLTextureCache setObject:texture forKey:fileName];
	return texture;
}
+ (GLKTextureInfo*) textureByFileName:(NSString*)fileName loadIfEmpty:(BOOL)load{
	GLKTextureInfo *texture=[__ASPGLTextureCache objectForKey:fileName];
	if(load&&!(texture))
		texture=[ASPGLSprite loadTextureToStorage:fileName];
	
	return texture;
}
+ (void) clearTextureCache{
	if (__ASPGLTextureCache){
		[__ASPGLTextureCache removeAllObjects];
	}
}
#pragma mark - Init
- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect position:(GLKVector2)position bounds:(CGSize)size respectAspectRatio:(BOOL)respectAR{
    if ((self = [super init])) { 
		//Мелочь
		self.fileName=fileName;
		//Привет шейдер
        self.effect = effect;
		//Загружаем текстуру
		self.textureInfo = [ASPGLSprite textureByFileName:fileName loadIfEmpty:YES];
		CGSize textureSize=CGSizeMake(self.textureInfo.width, self.textureInfo.height);
		if (size.height&&size.width){
			if (respectAR){
				_contentSize=textureSize;
				self.contentSize=size;
			}else
				_contentSize=size;
		}else {
			_contentSize=textureSize;
		}
		TexturedQuad newQuad;
		newQuad.bl.geometryVertex = CGPointMake(0, 0);
		newQuad.br.geometryVertex = CGPointMake(textureSize.width, 0);
		newQuad.tl.geometryVertex = CGPointMake(0, textureSize.height);
		newQuad.tr.geometryVertex = CGPointMake(textureSize.width, textureSize.height);
		
		newQuad.bl.textureVertex = CGPointMake(0, 0);
		newQuad.br.textureVertex = CGPointMake(1, 0);
		newQuad.tl.textureVertex = CGPointMake(0, 1);
		newQuad.tr.textureVertex = CGPointMake(1, 1);
		//Рожаем позицию. Счет ведем от самой нижней точки обьекта
		self.position=GLKVector2Make(position.x, position.y);
		self.quad = newQuad;
		self.hidden=NO;
    }
    return self;
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
			bounds:(CGSize)size 
respectAspectRatio:(BOOL)respectAR{
	return [self initWithFile:fileName effect:effect position:DEFAULT_POS bounds:size respectAspectRatio:respectAR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
		  position:(GLKVector2)position
			bounds:(CGSize)size{
	return [self initWithFile:fileName effect:effect position:position bounds:size respectAspectRatio:DEFAULT_AR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
			bounds:(CGSize)size{
	return [self initWithFile:fileName effect:effect position:DEFAULT_POS bounds:size respectAspectRatio:DEFAULT_AR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect
		  position:(GLKVector2)position{
	return [self initWithFile:fileName effect:effect position:position bounds:DEFAULT_BOUNDS respectAspectRatio:DEFAULT_AR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect{
	return [self initWithFile:fileName effect:effect position:DEFAULT_POS bounds:DEFAULT_BOUNDS respectAspectRatio:DEFAULT_AR];
}
#pragma Accessors
- (void)setContentSize:(CGSize)contentSize{
	//Предполагается, что в _contentSize лежит адекватный размер
	CGFloat aspect = _contentSize.width/(CGFloat)_contentSize.height;
	if (aspect>=1){
		_contentSize.width=contentSize.width;
		_contentSize.height=contentSize.width/aspect;
	}else {
		_contentSize.width=contentSize.height*aspect;
		_contentSize.height=contentSize.height;
	}
}

- (void)outOfView{
	self.hidden=YES;
	[ASPGLSprite addSpriteToFreeCache:self];
}
#pragma mark - OpenGL Part
- (GLKMatrix4) modelMatrix {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;    
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
	//modelMatrix = GLKMatrix4Translate(modelMatrix, -self.contentSize.width, -self.contentSize.height, 0);
	modelMatrix = GLKMatrix4Scale(modelMatrix, _contentSize.width/_textureInfo.width,_contentSize.height/_textureInfo.height, 0);
//	modelMatrix = GLKMatrix4RotateZ(modelMatrix, - self.moveVelocity.x/6000.);
    return modelMatrix;
}

- (void)render { 
	if (!_hidden){
		self.effect.texture2d0.name = self.textureInfo.name;
		self.effect.texture2d0.enabled = YES;
		self.effect.transform.modelviewMatrix = self.modelMatrix;
		[self.effect prepareToDraw];
		glEnableVertexAttribArray(GLKVertexAttribPosition);
		glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
		long offset = (long)&_quad;        
		glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
		glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
}

-(void)update:(CGFloat)dt {
	GLKVector2 curMove = GLKVector2MultiplyScalar(_moveVelocity, dt);
	self.position = GLKVector2Add(_position, curMove);
}


@end