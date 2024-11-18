shader_type canvas_item;

uniform float build_progress : hint_range(0.0, 0.5) = 0.0;
uniform vec2 tile_count = vec2(100.0, 100.0); // Número de tiles na grade
uniform vec4 border_color : source_color = vec4(1.0, 0.84, 0.0, 1.0); // Cor amarelo dourada
uniform float border_thickness : hint_range(0.0, 0.1) = 0.02; // Espessura da borda

void fragment() {
    // Obtém as coordenadas UV com base na região ativa
	vec2 uv = fract(UV * tile_count);
	
    vec2 center = vec2(0.5, 0.5); // Centro relativo ao region
    
    // Calcula uma "distância quadrada" do pixel atual ao centro (efeito mais quadrado)
    float distance_to_center = max(abs(uv.x - center.x), abs(uv.y - center.y));

    // Ajusta o build_progress para um controle mais linear
    float reveal_threshold = smoothstep(0.0, 1.0, build_progress);

    // Controle da opacidade, indo das bordas para o centro
    float alpha = smoothstep(reveal_threshold - 0.05, reveal_threshold, distance_to_center);
    
    // Aplica a textura com a máscara de construção
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Condição para a borda dourada
    float border = smoothstep(reveal_threshold - border_thickness, reveal_threshold, distance_to_center) - 
                   smoothstep(reveal_threshold, reveal_threshold + border_thickness, distance_to_center);
    
    // Cor final: mistura a borda com a textura original
    COLOR = mix(vec4(border_color.rgb, 1.0), vec4(tex_color.rgb, tex_color.a * alpha), 1.0 - border);
}
