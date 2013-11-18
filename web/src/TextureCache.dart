part of gitfighter;

class TextureCache
{

  Map<String, Texture> cache = new Map<String, Texture>();

  Texture loadTexture(String url, Geometry parent)
  {
    if(cache.containsKey(url))
    {
      if(--parent.texturesToLoad <= 0)
        parent.texturesLoaded = true;
      return cache[url];
    }
    Texture result = gl.createTexture();
    ImageElement img = new ImageElement();
    img.onLoad.listen((e)
      {
        gl.bindTexture(TEXTURE_2D, result);
        gl.texImage2DImage(TEXTURE_2D, 0, RGBA, RGBA, UNSIGNED_BYTE, img);
        gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, LINEAR);
        gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR);
        gl.bindTexture(TEXTURE_2D, null);
        if(--parent.texturesToLoad <= 0)
            parent.texturesLoaded = true;
      });
    img.src = url;
    cache[url] = result;
    return result;
  }

}