//
//  UIColor+DANAdditions.m
//
//  Copyright (c) 2014 Daniel Tomlinson. All rights reserved.
//

#import "UIColor+DANAdditions.h"

@implementation UIColor (DANAdditions)

+(UIColor *) colorFromHexString:(NSString *)hexString 
{
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIColor *) lighten:(float)amount
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:(b + (b * (amount / 100)))
                               alpha:a];
    return nil;
}

- (UIColor *) darken:(float)amount
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:(b - (b * (amount / 100)))
                               alpha:a];
    return nil;
}

- (UIColor *) saturate:(float)amount 
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:(s + (s * (amount / 100)))
                          brightness:b
                               alpha:a];
    return nil;
}

- (UIColor *) desaturate:(float)amount 
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:(s - (s * (amount / 100)))
                          brightness:b
                               alpha:a];
    return nil;
}

- (UIColor *) invert 
{
    float r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:1.0-r
                               green:1.0-g
                                blue:1.0-b
                               alpha:a];
    return nil;
}

- (UIColor *) greyscale 
{
    float r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithWhite:((r + g + b)/3)
                                 alpha:a];
    return nil;
}

@end
