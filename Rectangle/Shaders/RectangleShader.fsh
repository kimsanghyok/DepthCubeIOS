//
//  Shader.fsh
//  Rectangle
//
//  Created by toltori on 4/15/16.
//  Copyright © 2016 hyong. All rights reserved.
//
#version 300 es
precision mediump float;

in vec2 v_texCoord;
uniform sampler2D s_texture;
out vec4 outColor;

void main()
{
    outColor = texture(s_texture, v_texCoord);
}
