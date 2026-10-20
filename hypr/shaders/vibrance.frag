// Vibrance shader for Hyprland
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    
    // Luminance coefficients (Rec. 709)
    float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    
    // Saturation boost amount (1.4 = +40% vibrance)
    float vibrance = 1.35;
    
    // Determine maximum and minimum color channels
    float maxVal = max(color.r, max(color.g, color.b));
    float minVal = min(color.r, min(color.g, color.b));
    float sat = maxVal - minVal;
    
    // Protect already high-saturation areas from oversaturating
    float factor = vibrance * (1.0 - sat);
    vec3 result = mix(vec3(luma), color.rgb, 1.0 + factor);
    
    gl_FragColor = vec4(clamp(result, 0.0, 1.0), color.a);
}

