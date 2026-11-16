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

void main(void)
{
		vec2 p = v_texCoord;
		if( u_size.x < 1.0 )
		{
			if( p.x < u_origin.x )
			{
				p.x = p.x/u_size.x;
			}
			else if( p.x > u_rect.x )
			{
				p.x = 1.0-(1.0-p.x)/u_size.x;
			}
			else
			{
				p.x = u_point.x;
			}
		}
		if( u_size.y < 1.0 )
		{
			if( p.y < u_origin.y )
			{
				p.y = p.y/u_size.y;
			}
			else if( p.y > u_rect.y )
			{
				p.y = 1.0-(1.0-p.y)/u_size.y;
			}
			else
			{
				p.y = u_point.y;
			}
		}
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