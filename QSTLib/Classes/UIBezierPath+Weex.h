

#import <UIKit/UIKit.h>

@interface UIBezierPath (Weex)

+ (instancetype)wx_bezierPathWithRoundedRect:(CGRect)rect
                                     topLeft:(CGFloat)topLeftRadius
                                    topRight:(CGFloat)topRightRadius
                                  bottomLeft:(CGFloat)bottomLeftRadius
                                 bottomRight:(CGFloat)bottomRightRadius;

@end
