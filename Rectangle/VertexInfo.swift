//
//  VertexInfo.swift
//  Rectangle
//
//  Created by toltori on 4/15/16.
//  Copyright © 2016 hyong. All rights reserved.
//

import Foundation
import GLKit
import OpenGLES

class VertexInfo {
    var position: [GLfloat]
    var normal: [GLfloat]
    var texCoord: [GLfloat]
    
    init(p_position: [GLfloat], p_normal: [GLfloat], p_texCoord: [GLfloat]) {
        position = p_position
        normal = p_normal
        texCoord = p_texCoord
    }
}