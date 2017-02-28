//
//  OpenCVProcess.m
//  iOSOpenCVTest
//
//  Created by 青鹿司 on 2017/02/28.
//  Copyright © 2017年 bhind. All rights reserved.
//

#import "iOSOpenCVTest-Bridging-Header.h"

#import "opencv.hpp"
#import "imgcodecs/ios.h"

@implementation OpenCVProcess: NSObject

+(UIImage*) SobelFilter:(UIImage*)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    cv::Mat edge;
    cv::Canny(gray, edge, 100, 200);
    UIImage* result = MatToUIImage(edge);

    return result;
}

@end
