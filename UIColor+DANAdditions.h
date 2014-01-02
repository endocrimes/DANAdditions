//
//  UIColor+DANAdditions.h
//
//  Copyright (c) 2014 Daniel Tomlinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DANAdditions)

+ (UIColor *) colorFromHexString:(NSString *)hexString;

- (UIColor *) lighten:(float)amount;
- (UIColor *) darken:(float)amount;

- (UIColor *) saturate:(float)amount;
- (UIColor *) desaturate:(float)amount;

- (UIColor *) invert;
- (UIColor *) greyscale;

@end
