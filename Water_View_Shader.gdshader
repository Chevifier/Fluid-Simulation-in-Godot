shader_type canvas_item;

uniform sampler2D noise;
uniform float water_speed:hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float color_detect_threshold = 0.6;
//suggest color code: ff00ff
uniform vec4 water_dev_color: hint_color;
uniform vec4 water_color:hint_color = vec4(0,0,1,1);
uniform vec4 bubble_color:hint_color = vec4(0,0,1.5,1);

void fragment(){
	//2 UV references from Screen
	vec2 suv = SCREEN_UV;
	vec2 buv = SCREEN_UV;
	//move water around
	suv.x += sin(TIME) * water_speed;
	suv.y -= cos(TIME) * water_speed;
	//move bubble upward and sway left to right
	buv.x -= sin(TIME)*0.2 * water_speed;
	buv.y -= TIME * water_speed;
	//2 references to noise texture
	vec4 n = texture(noise,suv).rgba;
	vec4 bn = texture(noise,buv).rgba;
	//remove most of the noise from bubble noise texture
	bn = smoothstep(0.35,0.83,bn);
	//get a blurred version of the screen texture
	vec4 screen_tex = textureLod(SCREEN_TEXTURE,SCREEN_UV,1.5).rgba;
	vec4 particle_color;
	vec4 bubble;
	//check if the color is pink i.e ff00ff
	//if it is set it to the new color else set it to transparent
	if(step(color_detect_threshold,screen_tex) == water_dev_color){
		
		particle_color = n*water_color;
		bubble = bn*bubble_color;
		//add bubble if noise.red channel greater than 0.5
		if(bn.r>0.50){
			particle_color = particle_color + bubble;
		}
	}else{
		//transparent
		particle_color = vec4(0.0);
	}
	//assign final color
	COLOR = particle_color;
}