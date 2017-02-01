//
//  pageView.m
//  翻页效果
//
//  Created by lihe on 17/1/29.
//  Copyright © 2017年 lihe. All rights reserved.
//

#import "pageView.h"

@interface pageView ()

@property (nonatomic ,strong) UIImageView *rightImageView;
@property (nonatomic ,strong) UIImageView *leftImageView;
@property (nonatomic ,assign) CGFloat startX;
@property (nonatomic ,strong) UIImageView *rightBackView;
@property (nonatomic ,strong) UIImageView *leftBackView;
@property (nonatomic ,strong) CAGradientLayer *leftGradientlayer;
@property (nonatomic ,strong) CAGradientLayer *rightGradientlayer;




@end

@implementation pageView



-(void)awakeFromNib{
    [super awakeFromNib];
    UIImage *image = [UIImage imageNamed:@"雨滴"];
    
    UIImageView *leftImageViwe = [[UIImageView alloc]init];
    UIImageView *rightImageViwe = [[UIImageView alloc]init];
    leftImageViwe.userInteractionEnabled = YES;
    rightImageViwe.userInteractionEnabled = YES;
    leftImageViwe.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) /2, CGRectGetHeight(self.frame));
    rightImageViwe.layer.anchorPoint = CGPointMake(0, 0.5);
    rightImageViwe.frame = CGRectMake(CGRectGetWidth(self.frame)/2, 0, CGRectGetWidth(self.frame)/2l,CGRectGetHeight(self.frame));
    leftImageViwe.image = [self clipImageWithImage:image andIsLeft:YES];
    rightImageViwe.image = [self clipImageWithImage:image andIsLeft:NO];
    
    self.rightImageView = rightImageViwe;
    self.leftImageView = leftImageViwe;
    self.leftImageView.layer.mask = [self getCornerRidusWithRect:self.leftImageView.bounds andIsLeft:YES];
    self.rightImageView.layer.mask = [self getCornerRidusWithRect:self.rightImageView.bounds andIsLeft:NO];
    

    [self addSubview:leftImageViwe];
    [self addSubview:rightImageViwe];
    
    
    self.rightBackView = [[UIImageView alloc]init];
    self.rightBackView.frame = self.rightImageView.bounds;
    self.rightBackView.alpha = 0;
    self.rightBackView.image = [self getBlurAndInvertImageWithImage:[self clipImageWithImage:image andIsLeft:NO]];
    
    self.leftGradientlayer = [CAGradientLayer layer];
    self.leftGradientlayer.frame = self.leftImageView.bounds;
    //颜色数组格式必须这样
    self.leftGradientlayer.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
    self.leftGradientlayer.opacity = 0;
    self.leftGradientlayer.startPoint = CGPointMake(1.0, 1.0);
    self.leftGradientlayer.endPoint = CGPointMake(0, 1);
    [self.leftImageView.layer addSublayer:self.leftGradientlayer];
    
    self.rightGradientlayer = [CAGradientLayer layer];
    self.rightGradientlayer.frame = self.leftImageView.bounds;
    self.rightGradientlayer.colors = @[[UIColor clearColor] ,[UIColor blackColor]];
    self.rightGradientlayer.opacity = 0;
    self.rightGradientlayer.startPoint = CGPointMake(0, 1.0);
    self.rightGradientlayer.endPoint = CGPointMake(1, 1);
    [self.leftImageView.layer addSublayer:self.rightGradientlayer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [rightImageViwe addGestureRecognizer:pan];
}

//圆角
-(CAShapeLayer*)getCornerRidusWithRect:(CGRect)rect andIsLeft:(BOOL)isLeft{
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    UIRectCorner corner = isLeft ? UIRectCornerTopLeft | UIRectCornerBottomLeft : UIRectCornerTopRight|UIRectCornerBottomRight;
    
    UIBezierPath *paht = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:CGSizeMake(10, 10)];
    
    layer.path = paht.CGPath;
    
    return layer;
}

//获得模糊效果的图片
- (UIImage*)getBlurAndInvertImageWithImage:(UIImage*)image{
    CIContext * context = [CIContext contextWithOptions:nil];
    CIImage * inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter * filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputRadius"];
    CIImage * result = [filter valueForKey:kCIOutputImageKey];
    result = [result imageByApplyingTransform:CGAffineTransformMakeTranslation(-1, 1)];//朦胧效果
    CGImageRef ref = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage * returnImage = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return returnImage;
}

//手势回调
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    CGPoint touchPoint = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.startX = touchPoint.x;
    }
    
    
    if ([[self.rightImageView.layer valueForKey:@"transform.rotation.y"] floatValue] > - M_PI_2 &&([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] != 0)) {
        
        self.rightBackView.alpha = 1.0;
        self.rightGradientlayer.opacity = 0;
        CGFloat opacity = (touchPoint.x - self.startX) / (CGRectGetWidth(self.bounds) - self.startX);
        self.leftGradientlayer.opacity = fabs(opacity);
        
    }else if(([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue] > -M_PI_2)&&([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue]<0)&&([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] == 0)){
        self.rightBackView.alpha = 0;
        CGFloat opacity = (touchPoint.x-self.startX)/(CGRectGetWidth(self.bounds)-self.startX);
        self.rightGradientlayer.opacity =fabs(opacity)*0.5 ;
        self.leftGradientlayer.opacity =fabs(opacity)*0.5;
        
    }
    
    if ([self isTouchPoint:touchPoint InView:self]) {
        
        CGFloat angle = M_PI / (CGRectGetWidth(self.bounds) - self.startX);
        self.rightImageView.layer.transform = [self getRightTransform3DWithAngle:(touchPoint.x - self.startX) * angle];
        
        pan.enabled = YES;
    }else {
        pan.enabled = YES;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        ;
    }
    
    
}

//核心方法
-(CATransform3D)getRightTransform3DWithAngle:(CGFloat)angle{
    
    CATransform3D trans = CATransform3DIdentity;
    trans.m34 = 4.5 /- 2000;
    trans = CATransform3DRotate(trans, angle, 0, 1, 0);
    return trans;
}

//判断点的位置
- (BOOL)isTouchPoint:(CGPoint)point InView:(UIView*)view{
    if ((point.x > 0 && point.x < CGRectGetMaxX(self.frame)) && (point.y > 0 && point.y < CGRectGetMaxY(self.frame))){
        return YES;
    }else{
        return NO;
    }
}

//得到左右两半的图片
-(UIImage *)clipImageWithImage:(UIImage *)image andIsLeft:(BOOL)isLeft{
    if (isLeft) {
        CGRect rect1 = CGRectMake(0, 0, image.size.width / 2, image.size.height);
        CGImageRef img1 = CGImageCreateWithImageInRect(image.CGImage, rect1);
        UIImage *image1 = [UIImage imageWithCGImage:img1];
        return image1;
        
    }else{
        
        CGRect rect2 = CGRectMake(image.size.width/2,0, image.size.width / 2, image.size.height);
        CGImageRef img2 = CGImageCreateWithImageInRect(image.CGImage, rect2);
        UIImage *image2 = [UIImage imageWithCGImage:img2];
        return image2;
        
    }
}




@end
