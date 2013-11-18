part of gitfighter;

abstract class drawable
{
  void draw(double interpolation);
}

class DAG_Node implements drawable
{
  Matrix4x3 transform = new Matrix4x3.identity();
  Matrix4x3 lastTransform = new Matrix4x3.identity();
  List<drawable> nodes;

  DAG_Node(this.nodes);

  void tick(int depth)
  {
    lastTransform = transform.clone(3);
    for(drawable obj in nodes)
    {
      if(obj is DAG_Node)
      {
        obj.tick(depth + 1);
      }
    }
  }

  void draw(double interpolation)
  {
    matrixStack.pushModel();
    matrixStack.modelMatrix.multiply(lastTransform.interpolate(transform, interpolation));
    for(drawable obj in nodes)
    {
      obj.draw(interpolation);
    }
    matrixStack.popModel();
  }
}