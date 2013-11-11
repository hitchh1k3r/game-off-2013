part of gitfighter;

Shader createShader(String src, int type)
{
  Shader shader = gl.createShader(type);
  gl.shaderSource(shader, src);
  gl.compileShader(shader);
  if(DEBUG && !gl.getShaderParameter(shader, COMPILE_STATUS))
  {
    window.alert("Shader Compile Error: " + gl.getShaderInfoLog(shader));
  }
  return shader;
}

Program createProgram(String vs, String fs)
{
  Program program = gl.createProgram();
  Shader vshader = createShader(vs, VERTEX_SHADER);
  Shader fshader = createShader(fs, FRAGMENT_SHADER);
  gl.attachShader(program, vshader);
  gl.attachShader(program, fshader);
  gl.linkProgram(program);
  if(DEBUG && !gl.getProgramParameter(program, LINK_STATUS))
  {
    window.alert("Shader Link Error: " + gl.getProgramInfoLog(program));
  }
  return program;
}

void loadProgram(String vsURL, String fsURL, void callback(Program p))
{
  String vshaderSource;
  String fshaderSource;
  void vshaderLoaded(String source)
  {
    vshaderSource = source;
    if(fshaderSource != null)
    {
      callback(createProgram(vshaderSource, fshaderSource));
    }
  }
  void fshaderLoaded(String source)
  {
    fshaderSource = source;
    if(vshaderSource != null)
    {
      callback(createProgram(vshaderSource, fshaderSource));
    }
  }
  HttpRequest.getString(vsURL).then(vshaderLoaded);
  HttpRequest.getString(fsURL).then(fshaderLoaded);
}