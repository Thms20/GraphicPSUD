#ifdef GL_ES
  precision mediump float;
precision mediump int;
#endif

  uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;
smooth in vec2 vertHeat;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  if (vertHeat.x < 60) {                        // Augmente de 0.5 en rouge pour les coordonnées x inférieurs à 60. On peut voir ça comme la distance entre les points d'intérets et 
    gl_FragColor.r += 0.5;                      // les vertexs de satellite (du terrain donc).
  }

}