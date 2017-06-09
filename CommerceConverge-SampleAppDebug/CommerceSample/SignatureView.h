//
//  Signature.h
//  Commerce Sample
//
//  Created by Rapoport, Julia on 11/6/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureView : UIView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)addImageView:(UIImageView *)imageView;
- (UIImage *)renderTrimmedImage;
- (CGRect)signatureRect;
- (void) clear;
@end
