//
//  iOSOpenCVTest-Bridging-Header.h
//  iOSOpenCVTest
//
//  Created by 青鹿司 on 2017/02/28.
//  Copyright © 2017年 bhind. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVProcess: NSObject
+(UIImage*) SobelFilter:(UIImage*)image;
- (id)init;
-(UIImage*) recognizeFace:(UIImage*)image;
@end
