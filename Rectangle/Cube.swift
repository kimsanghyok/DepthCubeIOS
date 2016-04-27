//
//  Cube.swift
//  Rectangle
//
//  Created by toltori on 4/27/16.
//  Copyright © 2016 hyong. All rights reserved.
//

import Foundation
import CoreVideo
import GLKit
import OpenGLES

class Cube {
    var vertex: [GLfloat]
    var index: [GLushort] = [GLushort](count: 36, repeatedValue: 0)
    
    var program: GLuint = 0
    var vbo: GLuint = 0
    var ibo: GLuint = 0
    var texture: [GLuint] = [GLuint](count: 6, repeatedValue: 0)
    
    var mvMatrix: GLKMatrix4! = nil
    var normalMatrix: GLKMatrix3! = nil
    var mvpMatrix: GLKMatrix4! = nil
    
    var mvMatrixUniform: GLint = 0
    var normalMatrixUniform: GLint = 0
    var mvpMatrixUniform: GLint = 0
    
    var rotation: Float = 0.0
    
    init() {
        
        vertex = [
            // Data layout for each line below is:
            // positionX, positionY, positionZ,     normalX, normalY, normalZ,  texCoordU, texCoordV
            // Right.
            0.5, -0.5, -0.5,        1.0, 0.0, 0.0,  1.0, 1.0,   // 0
            0.5, 0.5, -0.5,         1.0, 0.0, 0.0,  1.0, 0.0,   // 1
            0.5, 0.5, 0.5,          1.0, 0.0, 0.0,  0.0, 0.0,   // 2
            0.5, -0.5, 0.5,         1.0, 0.0, 0.0,  0.0, 1.0,   // 3
            
            // Top.
            0.5, 0.5, -0.5,         0.0, 1.0, 0.0,  1.0, 0.0,   // 4
            -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,  0.0, 0.0,   // 5
            -0.5, 0.5, 0.5,         0.0, 1.0, 0.0,  0.0, 1.0,   // 6
            0.5, 0.5, 0.5,          0.0, 1.0, 0.0,  1.0, 1.0,   // 7
            
            // Left.
            -0.5, 0.5, -0.5,        -1.0, 0.0, 0.0, 0.0, 0.0,   // 8
            -0.5, -0.5, -0.5,      -1.0, 0.0, 0.0,  0.0, 1.0,   // 9
            -0.5, -0.5, 0.5,        -1.0, 0.0, 0.0, 1.0, 1.0,   // 10
            -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0, 1.0, 0.0,   // 11
            
            // Bottom.
            -0.5, -0.5, -0.5,      0.0, -1.0, 0.0,  0.0, 1.0,   // 12
            0.5, -0.5, -0.5,        0.0, -1.0, 0.0, 1.0, 1.0,   // 13
            0.5, -0.5, 0.5,         0.0, -1.0, 0.0, 1.0, 0.0,   // 14
            -0.5, -0.5, 0.5,        0.0, -1.0, 0.0, 0.0, 0.0,   // 15
            
            // Front.
            0.5, 0.5, 0.5,          0.0, 0.0, 1.0,  1.0, 0.0,   // 16
            -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,  0.0, 0.0,   // 17
            -0.5, -0.5, 0.5,        0.0, 0.0, 1.0,  0.0, 1.0,   // 18
            0.5, -0.5, 0.5,         0.0, 0.0, 1.0,  1.0, 1.0,   // 19
            
            // Back.
            0.5, -0.5, -0.5,        0.0, 0.0, -1.0, 0.0, 1.0,   // 20
            -0.5, -0.5, -0.5,      0.0, 0.0, -1.0,  1.0, 1.0,   // 21
            -0.5, 0.5, -0.5,        0.0, 0.0, -1.0, 1.0, 0.0,   // 22
            0.5, 0.5, -0.5,         0.0, 0.0, -1.0, 0.0, 0.0    // 23
        ]
        
        let index0: [GLushort] = [
            // Right.
            0, 1, 2, 0, 2, 3
        ]
        
        for i: GLushort in 0 ..< 6 {
            for j: GLushort in 0 ..< 6 {
                index[Int(i * 6 + j)] = (4 * i) + index0[Int(j)]
            }
        }
    }
    
    func setupGL() {
        self.loadShaders()
        
        //
        // VBO, IBO setup
        //
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(sizeof(VertexInfo) * vertex.count), &vertex, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(GLfloat) * 8), BUFFER_OFFSET(0))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(GLfloat) * 8), BUFFER_OFFSET(12))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.TexCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.TexCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(GLfloat) * 8), BUFFER_OFFSET(24))
        
        glGenBuffers(1, &ibo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ibo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), index.count * sizeof(GLushort), &index, GLenum(GL_STATIC_DRAW))
        
        //
        // Texture setup
        // Make a simple 2d map texture
        //
        var imagePixels: [GLubyte] = [
            255, 0, 0
        ]
        glGenTextures(6, &texture)
        glActiveTexture(GLenum(GL_TEXTURE0))
        for i in 0..<6 {
            glBindTexture(GLenum(GL_TEXTURE_2D), texture[i])
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, 1, 1, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &imagePixels)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        }
        let samplerLoc: GLint = glGetUniformLocation(self.program, "s_texture")
        glUniform1i(samplerLoc, 0)
    }
    
    func teardownGL() {
        glDeleteProgram(program)
        glDeleteBuffers(1, &vbo)
        glDeleteTextures(1, &texture)
    }
    
    func update(viewMatrix: GLKMatrix4, projectionMatrix: GLKMatrix4) {
        let modelMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(rotation), 1.0, 0.0, 0.0)
        mvMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix)
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMatrix), nil)
        mvpMatrix = GLKMatrix4Multiply(projectionMatrix, mvMatrix)
        rotation += 1.5
    }
    
    func draw() {
        glUseProgram(program)
        
        withUnsafePointer(&mvMatrix, {
            glUniformMatrix4fv(mvMatrixUniform, 1, 0, UnsafePointer($0))
        })
        withUnsafePointer(&normalMatrix, {
            glUniformMatrix3fv(normalMatrixUniform, 1, 0, UnsafePointer($0))
        })
        withUnsafePointer(&mvpMatrix, {
            glUniformMatrix4fv(mvpMatrixUniform, 1, 0, UnsafePointer($0))
        })
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        for i in 0..<6 {
            glBindTexture(GLenum(GL_TEXTURE_2D), texture[i])
            glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_SHORT), BUFFER_OFFSET(6 * i * sizeof(GLushort)))
        }
    }
    
    func setTextureImage(faceIndex: Int, imageBufferRef: CVImageBufferRef) {
        if faceIndex >= 0 && faceIndex < 6 {
            CVPixelBufferLockBaseAddress(imageBufferRef, 0)
            let bufferWidth = CVPixelBufferGetWidth(imageBufferRef);
            let bufferHeight = CVPixelBufferGetHeight(imageBufferRef);
            
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), texture[faceIndex])
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(bufferWidth), GLsizei(bufferHeight), 0, GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), CVPixelBufferGetBaseAddress(imageBufferRef))
            CVPixelBufferUnlockBaseAddress(imageBufferRef, 0)
        }
    }
    
    func loadShaders() -> Bool {
        var vertShader: GLuint = 0
        var fragShader: GLuint = 0
        var vertShaderPathname: String
        var fragShaderPathname: String
        
        // Create shader program.
        program = glCreateProgram()
        
        // Create and compile vertex shader.
        vertShaderPathname = NSBundle.mainBundle().pathForResource("RectangleShader", ofType: "vsh")!
        if self.compileShader(&vertShader, type: GLenum(GL_VERTEX_SHADER), file: vertShaderPathname) == false {
            print("Failed to compile vertex shader")
            return false
        }
        
        // Create and compile fragment shader.
        fragShaderPathname = NSBundle.mainBundle().pathForResource("RectangleShader", ofType: "fsh")!
        if !self.compileShader(&fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragShaderPathname) {
            print("Failed to compile fragment shader")
            return false
        }
        
        // Attach vertex shader to program.
        glAttachShader(program, vertShader)
        
        // Attach fragment shader to program.
        glAttachShader(program, fragShader)
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Position.rawValue), "position")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Normal.rawValue), "normal")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.TexCoord0.rawValue), "texCoord0")
        
        // Link program.
        if !self.linkProgram(program) {
            print("Failed to link program: \(program)")
            
            if vertShader != 0 {
                glDeleteShader(vertShader)
                vertShader = 0
            }
            if fragShader != 0 {
                glDeleteShader(fragShader)
                fragShader = 0
            }
            if program != 0 {
                glDeleteProgram(program)
                program = 0
            }
            
            return false
        }
        
        // Get uniform locations.
        mvMatrixUniform = glGetUniformLocation(program, "modelViewMatrix")
        normalMatrixUniform = glGetUniformLocation(program, "normalMatrix")
        mvpMatrixUniform = glGetUniformLocation(program, "modelViewProjectionMatrix")
        
        // Release vertex and fragment shaders.
        if vertShader != 0 {
            glDetachShader(program, vertShader)
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDetachShader(program, fragShader)
            glDeleteShader(fragShader)
        }
        
        return true
    }
    
    
    func compileShader(inout shader: GLuint, type: GLenum, file: String) -> Bool {
        var status: GLint = 0
        var source: UnsafePointer<Int8>
        do {
            source = try NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding).UTF8String
        } catch {
            print("Failed to load vertex shader")
            return false
        }
        var castSource = UnsafePointer<GLchar>(source)
        
        shader = glCreateShader(type)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)
        
        //#if defined(DEBUG)
        //                var logLength: GLint = 0
        //                glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        //                if logLength > 0 {
        //                    var log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
        //                    glGetShaderInfoLog(shader, logLength, &logLength, log)
        //                    NSLog("Shader compile log: \n%s", log)
        //                    free(log)
        //                }
        //#endif
        
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if status == 0 {
            glDeleteShader(shader)
            return false
        }
        return true
    }
    
    func linkProgram(prog: GLuint) -> Bool {
        var status: GLint = 0
        glLinkProgram(prog)
        
        //#if defined(DEBUG)
        //        var logLength: GLint = 0
        //        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        //        if logLength > 0 {
        //            var log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
        //            glGetShaderInfoLog(shader, logLength, &logLength, log)
        //            NSLog("Shader compile log: \n%s", log)
        //            free(log)
        //        }
        //#endif
        
        glGetProgramiv(prog, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            return false
        }
        
        return true
    }
    
    func validateProgram(prog: GLuint) -> Bool {
        var logLength: GLsizei = 0
        var status: GLint = 0
        
        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log: [GLchar] = [GLchar](count: Int(logLength), repeatedValue: 0)
            glGetProgramInfoLog(prog, logLength, &logLength, &log)
            print("Program validate log: \n\(log)")
        }
        
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        var returnVal = true
        if status == 0 {
            returnVal = false
        }
        return returnVal
    }
    
}