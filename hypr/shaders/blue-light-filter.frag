// Warm night light / blue light filter shader for Hyprland
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    
    // Warms temperature by scaling blue down and slightly boosting amber/red
    vec3 warmColor = vec3(
        color.r * 1.0,
        color.g * 0.88,
        color.b * 0.70
    );
    
    gl_FragColor = vec4(clamp(warmColor, 0.0, 1.0), color.a);
}

