shader_type canvas_item;

//--- hatsuyuki ---
// by Catzpaw 2016
//
// Modified for Godot; original code can be found at http://www.glslsandbox.com/e#36547.0

//#extension GL_OES_standard_derivatives : enable

uniform vec2 resolution;

float snow(vec2 uv, float scale, float time)
{
    float w=smoothstep(1.0,0.0,-uv.y*(scale/10.0));if(w<.1)return 0.0;
    uv+=time/scale;uv.y+=time*2.0/scale;uv.x+=sin(uv.y+time*.5)/scale;
    uv*=scale;vec2 s=floor(uv),f=fract(uv),p;float k=3.0,d;
    p=.5+.35*sin(11.0*fract(sin((s+scale)*mat2(vec2(7,3),vec2(6,5)))*5.0))-f;d=length(p);k=min(d,k);
    k=smoothstep(0.0,k,sin(f.x+f.y)*0.01);
    return k*w;
}

void fragment( )
{
    vec2 uv=(FRAGCOORD.xy*2.0-resolution.xy)/min(resolution.x,resolution.y); 
    vec3 finalColor=vec3(0);
    float c=smoothstep(1.0,0.3,clamp(uv.y*.3+.8,0.0,.75));
    c+=snow(uv,30.0,TIME)*.3;
    c+=snow(uv,20.0,TIME)*.5;
    c+=snow(uv,15.0,TIME)*.8;
    c+=snow(uv,10.0,TIME);
    c+=snow(uv,8.0,TIME);
    c+=snow(uv,6.0,TIME);
    c+=snow(uv,5.0,TIME);
    finalColor=(vec3(c));
    COLOR = vec4(finalColor,1.0);
}