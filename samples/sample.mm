#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageProcessor : NSObject

- (UIImage *)processImage:(UIImage *)image
              withFilter:(NSString *)filterName;

@end

@implementation ImageProcessor

- (UIImage *)processImage:(UIImage *)image
              withFilter:(NSString *)filterName {
  CGSize size = image.size;
  UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
  
  [image drawAtPoint:CGPointZero];
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

@end
