varying vec2 v_texCoord;

uniform float brightness;

void main()
{
   vec2 texcoord = v_texCoord.xy;

   vec4 inputValue = texture2D(CC_Texture0, texcoord);
   inputValue.rgb += vec3(brightness * inputValue.a);
   gl_FragColor = inputValue;
}

