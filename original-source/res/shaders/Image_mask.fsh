// Shader from http://www.iquilezles.org/apps/shadertoy/

#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D u_mask;
uniform sampler2D u_texture;

varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

uniform vec2 u_size;
uniform vec2 u_point;

void main(void)
{
	vec4 texColor = texture2D(u_texture, v_texCoord);
	if( u_size.x == 0.0 )
	{
		vec4 maskColor  = texture2D(u_mask, v_texCoord);
		gl_FragColor = v_fragmentColor*vec4(texColor.r, texColor.g, texColor.b, maskColor.a * texColor.a);
	}
	else if( v_texCoord.x >= u_point.x && v_texCoord.y >= u_point.y &&
			v_texCoord.x <= u_point.x + u_size.x &&
			v_texCoord.y <= u_point.y + u_size.y )
	{
		vec2 pt;
		pt.x = (v_texCoord.x - u_point.x)/u_size.x;
		pt.y = (v_texCoord.y - u_point.y)/u_size.y;
		vec4 maskColor  = texture2D(u_mask, pt);
		gl_FragColor = v_fragmentColor*vec4(texColor.r, texColor.g, texColor.b, maskColor.a * texColor.a);
	}
	else
	{
		gl_FragColor = v_fragmentColor*vec4(texColor.r, texColor.g, texColor.b, 0);
	}
}
