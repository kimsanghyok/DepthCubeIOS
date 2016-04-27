//
//  Shader.vsh
//  Rectangle
//
//  Created by toltori on 4/15/16.
//  Copyright © 2016 hyong. All rights reserved.
//
#version 300 es
in vec4 position;
in vec3 normal;
in vec2 texCoord0;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;

out vec2 v_texCoord;
void main()
{
    gl_Position = modelViewProjectionMatrix * position;
    v_texCoord = texCoord0;
}
