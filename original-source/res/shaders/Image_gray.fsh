
#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

void main(void)
{
		vec4 c = texture2D(u_texture, v_texCoord);
		c.r = c.g = c.b = 0.299*c.r + 0.587*c.g + 0.114*c.b;
		gl_FragColor = v_fragmentColor*c;
}