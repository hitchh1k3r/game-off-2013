part of gitfighter;

abstract class drawable
{
  void draw();
}

class DAG_Node implements drawable
{
  Matrix4x3 transform = new Matrix4x3.identity();
  List<drawable> nodes;

  DAG_Node(this.nodes);

  void draw()
  {
    matrixStack.pushModel();
    matrixStack.modelMatrix.multiply(transform);
    for(drawable obj in nodes)
    {
      obj.draw();
    }
    matrixStack.popModel();
  }
}