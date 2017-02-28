//
//  ViewController.swift
//  iOSOpenCVTest
//
//  Created by 青鹿司 on 2017/02/24.
//  Copyright © 2017年 bhind. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!

    var session: AVCaptureSession! = AVCaptureSession()
    var device: AVCaptureDevice!
    var output: AVCaptureVideoDataOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(self.initCamera()) {
            self.session.startRunning()
        } else {
            NSLog("initCamera error occured.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initCamera() -> Bool {
        self.session.sessionPreset = AVCaptureSessionPresetHigh
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: self.device) as AVCaptureInput
            self.session.addInput(input)
        
            self.output = AVCaptureVideoDataOutput()
            self.output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: kCVPixelFormatType_32BGRA]
            try self.device.lockForConfiguration()
            self.device.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            self.device.unlockForConfiguration()
            let queue = DispatchQueue(label: "site.bhind.queue")
            self.output.setSampleBufferDelegate(self, queue: queue)
            
            self.output.alwaysDiscardsLateVideoFrames = true
            
            self.session.addOutput(self.output)
        } catch {
            return false
        }
        
        
        for connection in self.output.connections {
            if let connection_buf = connection as? AVCaptureConnection {
                if( connection_buf.isVideoOrientationSupported ) {
                    connection_buf.videoOrientation = AVCaptureVideoOrientation.portrait
                }
            }
        }
        
        return true
    }

    func captureOutput(_: AVCaptureOutput!, didOutputSampleBuffer: CMSampleBuffer!, from: AVCaptureConnection!) {
        DispatchQueue.main.async( execute: {
            self.imageView.image = self.imageFromSampleBuffer(samplebuffer: didOutputSampleBuffer)
        })
    }
    
    func imageFromSampleBuffer(samplebuffer: CMSampleBuffer) -> UIImage {
        let image_buf: CVImageBuffer = CMSampleBufferGetImageBuffer(samplebuffer)!
        CVPixelBufferLockBaseAddress(image_buf, CVPixelBufferLockFlags(rawValue: 0))
        
        let base_address: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(image_buf, 0)!
        
        let bytes_per_row: Int = CVPixelBufferGetBytesPerRow(image_buf)
        let width: Int = CVPixelBufferGetWidth(image_buf)
        let height: Int = CVPixelBufferGetHeight(image_buf)
        
        let color_space: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bits_per_compornent: Int = 8
        let bitmap_info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            .union(.byteOrder32Little)
        let new_context: CGContext = CGContext(data: base_address, width: width, height: height, bitsPerComponent: bits_per_compornent, bytesPerRow: bytes_per_row, space: color_space, bitmapInfo: bitmap_info.rawValue)! as CGContext
        
        let image: CGImage = new_context.makeImage()!
        
        // UIImageを作成
        let rawImage: UIImage = UIImage(cgImage: image)
        let result: UIImage = OpenCVProcess.sobelFilter(rawImage)
        return result
    }

}

