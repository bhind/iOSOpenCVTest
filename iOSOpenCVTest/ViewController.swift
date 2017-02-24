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

    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var output: AVCaptureVideoDataOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(self.initCamera()) {
            self.session.startRunning()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initCamera() -> Bool {
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPreset1280x720
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: self.device) as AVCaptureInput
            self.session.addInput(input)
        } catch {
            return false
        }
        
        self.output = AVCaptureVideoDataOutput()
        self.output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]

        do {
            try self.device.lockForConfiguration()
            self.device.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            self.device.unlockForConfiguration()
        } catch {
            return false
        }
        
        let queue: DispatchQueue = DispatchQueue(label: "myqueue")
        self.output.setSampleBufferDelegate(self, queue: queue)
        
        self.output.alwaysDiscardsLateVideoFrames = true
        
        self.session.addOutput(self.output)
        
        for connection in self.output.connections {
            if let connection_buf = connection as? AVCaptureConnection {
                if( connection_buf.isVideoOrientationSupported ) {
                    connection_buf.videoOrientation = AVCaptureVideoOrientation.portrait
                }
            }
        }
        
        return true
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        NSLog("coco")
        DispatchQueue.main.async( execute: {
            self.imageView.image = self.imageFromSampleBuffer(samplebuffer: sampleBuffer)
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
        let result: UIImage = UIImage(cgImage: image)
        
        return result
    }

}

