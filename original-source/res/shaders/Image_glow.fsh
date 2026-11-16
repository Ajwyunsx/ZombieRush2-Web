#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 resolution;//图片宽高
uniform vec3 glowColor;//发光颜色
uniform float blurRadius;//发光半径,建议值20
uniform float threshold;//发光浓度,建议值2


vec4 blur(vec2);

void main(void)
{
    vec4 col = blur(v_texCoord);
    gl_FragColor = col * v_fragmentColor;
}

vec4 blur(vec2 p)
{
    vec4 oldcolor = texture2D(CC_Texture0, p);
    if (oldcolor.a > 0.98)
    {
        return oldcolor;
    }
    float sampleNum = blurRadius / 2.0;//采样率设置为发光半径的一半
    if (blurRadius > 0.0 && sampleNum > 1.0)
    {
        vec2 unit = 1.0 / resolution.xy;
        
        float r = blurRadius;
        float sampleStep = r / sampleNum;
        float sum_a = 0.0;
        float count = 0.0;
        
        for(float x = -r; x < r; x += sampleStep)
        {
            for(float y = -r; y < r; y += sampleStep)
            {
                float weight = (r - abs(x)) * (r - abs(y));
                vec4 c = texture2D(CC_Texture0, p + vec2(x * unit.x, y * unit.y));
                sum_a += c.a * weight;
                count += weight;
            }
        }
        float avg_a = sum_a / count;
        vec4 gc = vec4(glowColor * avg_a * threshold, avg_a * threshold);
        gc = oldcolor + (1.0-oldcolor.a)*gc;
        return gc;
    }
    
    return oldcolor;
}
