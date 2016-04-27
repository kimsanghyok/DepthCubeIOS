//
//  GameViewController.swift
//  Rectangle
//
//  Created by toltori on 4/15/16.
//  Copyright © 2016 hyong. All rights reserved.
//

import GLKit
import OpenGLES

func BUFFER_OFFSET(i: Int) -> UnsafePointer<Void> {
    let p: UnsafePointer<Void> = nil
    return p.advancedBy(i)
}

let UNIFORM_MODELVIEWPROJECTION_MATRIX = 0
let UNIFORM_NORMAL_MATRIX = 1
var uniforms = [GLint](count: 2, repeatedValue: 0)

class GameViewController: GLKViewController, ColorTrackingCameraDelegate {
    
    var program: GLuint = 0
    
    var modelViewProjectionMatrix:GLKMatrix4 = GLKMatrix4Identity
    var normalMatrix: GLKMatrix3 = GLKMatrix3Identity
    var rotation: Float = 0.0
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    var context: EAGLContext? = nil

    var cube: Cube! = nil
    var rect: Rectangle! = nil
    var camera: ColorTrackingCamera! = nil
    
    deinit {
        self.tearDownGL()
        
        if EAGLContext.currentContext() === self.context {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.context = EAGLContext(API: .OpenGLES3)
        
        if !(self.context != nil) {
            print("Failed to create ES context")
        }
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .Format24
        
        cube = Cube()
        //rect = Rectangle()
        
        self.setupGL()
       
        //
        // Load textures.
        //
        let imageNames = ["right", "top", "left", "bottom", "front", "back"]
        for i in 0..<6 {
            let image = UIImage(named: imageNames[i])!
            cube.setTextureImage(i, imageBufferRef: self.CGImageToPixelBuffer(image.CGImage!, frameSize: image.size))
        }
        //rect.setTextureImage(self.CGImageToPixelBuffer(image.CGImage!, frameSize: image.size))
        
        camera = ColorTrackingCamera()
        camera.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded() && (self.view.window != nil) {
            self.view = nil
            
            self.tearDownGL()
            
            if EAGLContext.currentContext() === self.context {
                EAGLContext.setCurrentContext(nil)
            }
            self.context = nil
        }
    }
    
    func setupGL() {
        EAGLContext.setCurrentContext(self.context)
        glDisable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        cube.setupGL()
        //rect.setupGL()
    }
    
    func tearDownGL() {
        cube.teardownGL()
        //rect.teardownGL()
        EAGLContext.setCurrentContext(self.context)
    }
    
    // MARK: - GLKView and GLKViewController delegate methods
    
    func update() {
        let aspect = fabsf(Float(self.view.bounds.size.width / self.view.bounds.size.height))
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1, 100.0)
        let viewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -3.0)
        cube.update(viewMatrix, projectionMatrix: projectionMatrix)
        //rect.update(viewMatrix, projectionMatrix: projectionMatrix)
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        glClearColor(1.0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        self.cube.draw()
        //self.rect.draw()
    }
    
    func CGImageToPixelBuffer(image: CGImageRef, frameSize: CGSize) -> CVPixelBuffer {
        
        // stupid CFDictionary stuff
        let keys: [CFStringRef] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue]
        let keysPointer = UnsafeMutablePointer<UnsafePointer<Void>>.alloc(1)
        let valuesPointer =  UnsafeMutablePointer<UnsafePointer<Void>>.alloc(1)
        keysPointer.initialize(keys)
        valuesPointer.initialize(values)
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count,
                                         UnsafePointer<CFDictionaryKeyCallBacks>(), UnsafePointer<CFDictionaryValueCallBacks>())
        
        let buffer = UnsafeMutablePointer<CVPixelBuffer?>.alloc(1)
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height),
                                         kCVPixelFormatType_32ARGB, options, buffer)
        
        CVPixelBufferLockBaseAddress(buffer.memory!, 0);
        let bufferData = CVPixelBufferGetBaseAddress(buffer.memory!);
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let context = CGBitmapContextCreate(bufferData, Int(frameSize.width),
                                            Int(frameSize.height), 8, 4*Int(frameSize.width), rgbColorSpace,
                                            CGImageAlphaInfo.PremultipliedLast.rawValue);
        
        CGContextSetBlendMode(context, CGBlendMode.Copy);
        CGContextDrawImage(context, CGRectMake(0, 0,
            CGFloat(CGImageGetWidth(image)),
            CGFloat(CGImageGetHeight(image))), image);
        
        CVPixelBufferUnlockBaseAddress(buffer.memory!, 0);
        return buffer.memory!
    }
    
    func cameraHasConnected() {
    }
    
    func processNewCameraFrame(cameraFrame: CVImageBuffer!) {
        CVPixelBufferLockBaseAddress(cameraFrame, 0);
        //cube.setTextureImage(cameraFrame)
        //rect.setTextureImage(cameraFrame)
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
    }
}