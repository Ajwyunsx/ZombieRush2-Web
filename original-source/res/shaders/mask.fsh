#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_mask;

void main()
{
    vec4 texColor = texture2D(CC_Texture0, v_texCoord);
    vec4 maskColor = texture2D(u_mask, v_texCoord);
    float a = 1.0-maskColor.a;
    vec4 finalColor = vec4(texColor.rgb * a, texColor.a * a);
    gl_FragColor = v_fragmentColor * finalColor;
}

