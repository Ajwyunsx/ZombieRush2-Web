// Shader from http://www.iquilezles.org/apps/shadertoy/

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D 	u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;
uniform vec2 u_size;
uniform vec2 u_point;
uniform float u_gray;
uniform vec2 u_origin;
uniform vec2 u_rect;

float u(float r, float s, float p, float o, float t)
{
	if( s < 1.0 )
	{
		if( r-o < s*t*p )
		{
			return o+(r-o)/s;
		}
		else if( r > o+t-(1.0-p)*s*t )
		{
			return o+t-(o+t-r)/s;
		}
		else
		{
			return o+t*p;
		}
	}
	return r;	
}

void main(void)
{
		vec2 p = v_texCoord;
		p.x = u(p.x, u_size.x, u_point.x, u_origin.x, u_rect.x);
		p.y = u(p.y, u_size.y, u_point.y, u_origin.y, u_rect.y);
		if( u_gray == 1.0 )
		{
			vec4 c = texture2D(u_texture, p);
			c.r = c.g = c.b = 0.299*c.r + 0.587*c.g + 0.114*c.b;
		  gl_FragColor = v_fragmentColor*c;
		}
		else
		{
			gl_FragColor = v_fragmentColor*texture2D(u_texture, p);
		}
}