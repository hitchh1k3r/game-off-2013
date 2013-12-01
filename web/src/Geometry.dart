part of gitfighter;

class BoundingBox
{

  double length;
  double width;
  double height;
  double originX;
  double originY;
  double originZ;

  BoundingBox(num len, num wid, num hei, num orx, num ory, num orz)
  {
    length = len.toDouble();
    width = wid.toDouble();
    height = hei.toDouble();
    originX = orx.toDouble();
    originY = ory.toDouble();
    originZ = orz.toDouble();
  }

  List<double> getVertCoords()
  { // faces: 1, 2, 3 and 1, 4, 2
    // 3 --- 2
    // |  /  |
    // 1 --- 4
    List<double> result = new List<double>();

    result.add(-1.0 * originX); //   1
    result.add(width - originY);
    result.add(0.0);
    result.add(length - originX); // 2
    result.add(-1.0 * originY);
    result.add(0.0);
    result.add(-1.0 * originX); //   3
    result.add(-1.0 * originY);
    result.add(0.0);

    result.add(-1.0 * originX); //   1
    result.add(width - originY);
    result.add(0.0);
    result.add(length - originX); // 4
    result.add(width - originY);
    result.add(0.0);
    result.add(length - originX); // 2
    result.add(-1.0 * originY);
    result.add(0.0);
    return result;
  }

  Vec3 getOrigin()
  {
    return new Vec3(originX, originY, originZ);
  }

}

class Color
{

  double red;
  double green;
  double blue;

  Color(num r, num g, num b)
  {
    red = r.toDouble();
    green = g.toDouble();
    blue = b.toDouble();
  }

}

class Material
{

  int numIndices;
  Texture diffuseTexture;
  Texture emissiveTexture;

  int draw(int start)
  {
    gl.activeTexture(TEXTURE0);
    gl.bindTexture(TEXTURE_2D, diffuseTexture);
    gl.uniform1i(uniformDiffuseSampler, 0);

    gl.activeTexture(TEXTURE1);
    gl.bindTexture(TEXTURE_2D, emissiveTexture);
    gl.uniform1i(uniformEmissiveSampler, 1);

    gl.drawElements(TRIANGLES, numIndices, UNSIGNED_SHORT, start * 2);
    return start + numIndices;
  }

}

class Geometry implements drawable
{

  bool loaded = false;
  bool texturesLoaded = false;
  BoundingBox bBox;
  Buffer boxBuffer;
  Buffer shapeBuffer;
  Buffer shapeTexUVBuffer;
  Buffer modelBuffer;
  Buffer modelIndexBuffer;
  Buffer modelNormBuffer;
  Buffer modelTexUVBuffer;
  Color color;
  int shapePoints;
  int modelPoints;
  int texturesToLoad = 0;
  List<Material> materials = new List<Material>();
  Texture spriteTexture;

  Geometry(String url)
  {
    Geometry that = this;
    HttpRequest.getString(url).then((String response) { that.init(response); });
  }

  void init(String jsonstring)
  {
    Map data = JSON.decode(jsonstring);
    boxBuffer = gl.createBuffer();
    shapeBuffer = gl.createBuffer();
    shapeTexUVBuffer = gl.createBuffer();
    modelBuffer = gl.createBuffer();
    modelIndexBuffer = gl.createBuffer();
    modelNormBuffer = gl.createBuffer();
    modelTexUVBuffer = gl.createBuffer();

    bBox = new BoundingBox(data['box']['length'], data['box']['width'], data['box']['height'], data['box']['originX'], data['box']['originY'], data['box']['originZ']);
    color = new Color(data['shape']['color'][0], data['shape']['color'][1], data['shape']['color'][2]);
    
    gl.bindBuffer(ARRAY_BUFFER, boxBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(bBox.getVertCoords()), STATIC_DRAW);

    gl.bindBuffer(ARRAY_BUFFER, shapeBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(doubleList(data['shape']['vertices'])), STATIC_DRAW);
    shapePoints = data['shape']['vertices'].length ~/ 3;
    
    gl.bindBuffer(ARRAY_BUFFER, shapeTexUVBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(uvBoxList(data['sprite']['left'], data['sprite']['top'], data['sprite']['right'], data['sprite']['bottom'])), STATIC_DRAW);

    gl.bindBuffer(ARRAY_BUFFER, modelBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(doubleList(data['vertexPositions'])), STATIC_DRAW);

    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, modelIndexBuffer);
    gl.bufferDataTyped(ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(data['indices']), STATIC_DRAW);
    modelPoints = data['indices'].length;

    gl.bindBuffer(ARRAY_BUFFER, modelNormBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(doubleList(data['vertexNormals'])), STATIC_DRAW);
    
    gl.bindBuffer(ARRAY_BUFFER, modelTexUVBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(doubleList(data['vertexTextureCoords'])), STATIC_DRAW);

    ++texturesToLoad;
    for(Map material in data['materials'])
    {
      int materialID = materials.length;
      materials.add(new Material());
      materials[materialID].numIndices = material['numindices'];
      texturesToLoad += 2;
      materials[materialID].diffuseTexture = textureCache.loadTexture(material['diffuse'], this, true);
      materials[materialID].emissiveTexture = textureCache.loadTexture(material['emissive'], this, true);
    }
    spriteTexture = textureCache.loadTexture(data['sprite']['sheet'], this, false);
    loaded = true;
  }

  List<double> doubleList(List input)
  {
    for(int i = 0; i < input.length; ++i)
    {
      if(input[i].runtimeType != "double")
      {
        input[i] = input[i].toDouble();
      }
    }
    return input;
  }

  static List<double> uvBoxList(num left, num top, num right, num bottom)
  { // faces: 1, 2, 3 and 1, 4, 2
    // 3 --- 2
    // |  /  |
    // 1 --- 4
    List<double> result = new List<double>();
    result.add(left.toDouble()); //  1
    result.add(bottom.toDouble());
    result.add(right.toDouble()); // 2
    result.add(top.toDouble());
    result.add(left.toDouble()); //  3
    result.add(top.toDouble());
    
    result.add(left.toDouble()); //  1
    result.add(bottom.toDouble());
    result.add(right.toDouble()); // 4
    result.add(bottom.toDouble());
    result.add(right.toDouble()); // 2
    result.add(top.toDouble());
    return result;
  }

  void draw(double interpolation)
  {
    if(loaded)
    {
      if(game_textured && !texturesLoaded)
      {
        return;
      }
      matrixStack.modelMatrix.writeToUniform(uniformMMatrix);
      if(!game_textured)
      {
        gl.uniform1f(uniformRed, color.red);
        gl.uniform1f(uniformGreen, color.green);
        gl.uniform1f(uniformBlue, color.blue);
      }

      if(game_3d)
      {
        gl.bindBuffer(ELEMENT_ARRAY_BUFFER, modelIndexBuffer);
  
        gl.enableVertexAttribArray(attribVertexPosition);
        gl.bindBuffer(ARRAY_BUFFER, modelBuffer);
        gl.vertexAttribPointer(attribVertexPosition, 3, FLOAT, false, 0, 0);
  
        gl.enableVertexAttribArray(attribVertexNormal);
        gl.bindBuffer(ARRAY_BUFFER, modelNormBuffer);
        gl.vertexAttribPointer(attribVertexNormal, 3, FLOAT, false, 0, 0);
  
        if(game_textured)
        {
          gl.enableVertexAttribArray(attribVertexTextureCoord);
          gl.bindBuffer(ARRAY_BUFFER, modelTexUVBuffer);
          gl.vertexAttribPointer(attribVertexTextureCoord, 2, FLOAT, false, 0, 0);

          int start = 0;
          for(Material material in materials)
          {
            start = material.draw(start);
          }
        }
        else
        {
          gl.drawElements(TRIANGLES, modelPoints, UNSIGNED_SHORT, 0);
        }
  
      }
      else
      {
        if(game_textured)
        {
          gl.activeTexture(TEXTURE0);
          gl.bindTexture(TEXTURE_2D, spriteTexture);
          gl.uniform1i(uniformSpriteSampler, 0);

          gl.enableVertexAttribArray(attribVertexPosition);
          gl.bindBuffer(ARRAY_BUFFER, boxBuffer);
          gl.vertexAttribPointer(attribVertexPosition, 3, FLOAT, false, 0, 0);
          
          gl.enableVertexAttribArray(attribVertexTextureCoord);
          gl.bindBuffer(ARRAY_BUFFER, shapeTexUVBuffer);
          gl.vertexAttribPointer(attribVertexTextureCoord, 2, FLOAT, false, 0, 0);

          gl.drawArrays(TRIANGLES, 0, 6);
        }
        else
        {
          gl.enableVertexAttribArray(attribVertexPosition);
          gl.bindBuffer(ARRAY_BUFFER, shapeBuffer);
          gl.vertexAttribPointer(attribVertexPosition, 3, FLOAT, false, 0, 0);
          gl.drawArrays(LINE_LOOP, 0, shapePoints);
        }
      }
      gl.disableVertexAttribArray(attribVertexPosition);
      gl.disableVertexAttribArray(attribVertexNormal);
      gl.disableVertexAttribArray(attribVertexTextureCoord);
    }
  }

}

class Billboard extends drawable
{

  Texture spriteTexture;
  Buffer boxBuffer;
  List<Buffer> texBuffers = new List<Buffer>();
  List<Color> colors;

  Billboard(BoundingBox bounds, this.colors, List<Rectangle> sprites)
  {
    spriteTexture = textureCache.loadTexture('textures/sprites.png', null, false);
    boxBuffer = gl.createBuffer();
    for(int i = 0; i < sprites.length; ++i)
    {
      texBuffers.add(gl.createBuffer());
    }

    gl.bindBuffer(ARRAY_BUFFER, boxBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(bounds.getVertCoords()), STATIC_DRAW);

    for(int i = 0; i < sprites.length; ++i)
    {
      gl.bindBuffer(ARRAY_BUFFER, texBuffers[i]);
      gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(Geometry.uvBoxList((sprites[i].left+0.5)/512.0, (sprites[i].top+0.5)/256.0, (sprites[i].left+sprites[i].width-0.5)/512.0, (sprites[i].top+sprites[i].height-0.5)/256.0)), STATIC_DRAW);
    }
  }

  void draw(double partialTime)
  {
    drawPlus(partialTime);
  }

  void drawPlus(double partialTime, {double rotation: 0.0, double opacity: 1.0, bool forceTexture: false, int version: 0})
  {
    if(fadeTime > 0 && opacity < 1.0)
      return;
    matrixStack.pushModel();
    gl.disable(CULL_FACE);
    if(opacity != 1.0)
      gl.uniform1f(uniformAlpha, opacity);
    if(!forceTexture && !game_textured)
    {
      gl.uniform1f(uniformRed, colors[version].red);
      gl.uniform1f(uniformGreen, colors[version].green);
      gl.uniform1f(uniformBlue, colors[version].blue);
    }
    if(game_3d)
    {
      matrixStack.modelMatrix.multiply(camera.getDirection(partialTime));
      if(rotation != 0)
        matrixStack.modelMatrix.multiply(MatrixFactory.rotationMatrix(rotation, 0.0, 0.0, 1.0));
      matrixStack.modelMatrix.multiply(MatrixFactory.rotationMatrix(PI, 1.0, 0.0, 0.0));
    }
    matrixStack.modelMatrix.writeToUniform(uniformMMatrix);

    if(game_3d)
      gl.uniform1i(uniformRender3D, 0);
    if(!game_textured && forceTexture)
      gl.uniform1i(uniformUseTexture, 1);

    gl.activeTexture(TEXTURE0);
    gl.bindTexture(TEXTURE_2D, spriteTexture);
    gl.uniform1i(uniformSpriteSampler, 0);

    gl.enableVertexAttribArray(attribVertexPosition);
    gl.bindBuffer(ARRAY_BUFFER, boxBuffer);
    gl.vertexAttribPointer(attribVertexPosition, 3, FLOAT, false, 0, 0);

    if(game_textured || forceTexture)
    {
      gl.enableVertexAttribArray(attribVertexTextureCoord);
      gl.bindBuffer(ARRAY_BUFFER, texBuffers[version]);
      gl.vertexAttribPointer(attribVertexTextureCoord, 2, FLOAT, false, 0, 0);
    }

    gl.drawArrays(TRIANGLES, 0, 6);

    gl.disableVertexAttribArray(attribVertexPosition);
    gl.disableVertexAttribArray(attribVertexTextureCoord);

    if(game_3d)
      gl.uniform1i(uniformRender3D, 1);
    if(!game_textured && forceTexture)
      gl.uniform1i(uniformUseTexture, 0);

    if(opacity != 1.0)
      gl.uniform1f(uniformAlpha, 1.0);    
    matrixStack.popModel();
    gl.enable(CULL_FACE);
  }

}