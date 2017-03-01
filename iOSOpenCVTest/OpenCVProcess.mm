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

@interface OpenCVProcess()
{
    cv::CascadeClassifier classifier;
}
@end

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
- (id)init {
    self = [super init];
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
    std::string cascadeName = (char*)[path UTF8String];
    if(!self->classifier.load(cascadeName)) {
        return nil;
    }
    return self;
}
-(UIImage*) recognizeFace:(UIImage*)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    std::vector<cv::Rect> faces;
    self->classifier.detectMultiScale(mat,
                                      faces,
                                      1.1,
                                      2,
                                      CV_HAAR_SCALE_IMAGE,
                                      cv::Size(30, 30));
    
    std::vector<cv::Rect>::const_iterator it = faces.begin();
    while(it != faces.end()){
        cv::Point pt;
        int r;
        pt.x = cv::saturate_cast<int>((it->x + it->width*0.5));
        pt.y = cv::saturate_cast<int>((it->y + it->height*0.5));
        r = cv::saturate_cast<int>((it->width + it->height));
        cv::circle(mat, pt, r, cv::Scalar(80, 80, 255), 3, 8, 0);
        it++;
    }
    UIImage* result = MatToUIImage(mat);
    return result;
}

@end
