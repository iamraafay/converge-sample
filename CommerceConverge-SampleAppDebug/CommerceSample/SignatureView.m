//
//  Signature.m
//  Commerce Sample
//
//  Created by Rapoport, Julia on 11/6/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "SignatureView.h"

@interface SignatureView() {
@private
    UIColor *signColor;
    UIBezierPath *signaturePath;
    CGPoint previousPoint;
}
@end

@implementation SignatureView

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        signaturePath = [UIBezierPath bezierPath];
        signColor = [UIColor blackColor];
    }
    return self;
}

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    previousPoint = [touch locationInView:self];
    [signaturePath moveToPoint:previousPoint];
    [signaturePath addArcWithCenter:previousPoint radius:0.5 startAngle:0 endAngle:2 clockwise:YES];
    [self setNeedsDisplay];
    [super touchesBegan:touches withEvent:event];
}

- (void)drawToPoint:(CGPoint)currentPoint {
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    [signaturePath addQuadCurveToPoint:midPoint controlPoint:previousPoint];
    previousPoint = currentPoint;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    [self drawToPoint:currentPoint];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    [self drawToPoint:currentPoint];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    [self drawToPoint:currentPoint];
    [super touchesEnded:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect {
    [signColor setStroke];
    [signaturePath stroke];
}

- (void)addImageView:(UIImageView *)imageView {
    [self addSubview:imageView];
}

- (void)clear {
    signaturePath = [UIBezierPath bezierPath];
    [self setNeedsDisplay];
}

- (CGRect)signatureRect {
    return signaturePath.bounds;
}

- (UIImage *)renderTrimmedImage {
    UIImage *viewImage = [self renderImage];
    CGImageRef imageRef = CGImageCreateWithImageInRect(viewImage.CGImage, [self signatureRect]);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)renderImage {
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

@end
