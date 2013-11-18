part of gitfighter;

class Entity implements drawable
{

  DAG_Node node;
  Vec3 position;
  Vec3 velocity;
  Vec3 rotations = new Vec3(0.0, 0.0, 0.0);

  Entity(Geometry geometry, this.position, this.velocity)
  {
    node = new DAG_Node([geometry]);
  }

  void tick()
  {
    position.add(velocity.x, velocity.y, ( game_3d ? velocity.z : 0.0 ));
    node.transform = MatrixFactory.translationMatrix(position.x, position.y, ( game_3d ? position.z : 0.0 ));
    node.transform.multiply(MatrixFactory.rotationMatrix(rotations.z, 0.0, 0.0, 1.0));
    if(game_3d)
    {
      node.transform.multiply(MatrixFactory.rotationMatrix(rotations.y, 0.0, 1.0, 0.0));
      node.transform.multiply(MatrixFactory.rotationMatrix(rotations.x, 1.0, 0.0, 0.0));
    }
    if((position.x - playerShip.position.x).abs() > 6000)
    {
      if(position.x < playerShip.position.x)
      {
        position.x += 12000;
      }
      else
      {
        position.x -= 12000;
      }
      node.transform._elements[12] = position.x;
      node.lastTransform._elements[12] = position.x;
    }
    if((position.y - playerShip.position.y).abs() > 6000)
    {
      if(position.y < playerShip.position.y)
      {
        position.y += 12000;
      }
      else
      {
        position.y -= 12000;
      }
      node.transform._elements[13] = position.y;
      node.lastTransform._elements[13] = position.y;
    }
    if(game_3d && (position.z - playerShip.position.z).abs() > 6000)
    {
      if(position.z < playerShip.position.z)
      {
        position.z += 12000;
      }
      else
      {
        position.z -= 12000;
      }
      node.transform._elements[14] = position.z;
      node.lastTransform._elements[14] = position.z;
    }
  }

  void draw(double partialTime)
  {
    node.draw(partialTime);
  }

}

class Asteroid extends Entity
{

  Vec3 angularVelocity;

  Asteroid(Vec3 position): super(( random.nextBool() ? ( random.nextBool() ? asteroid1 : asteroid2 ) : ( random.nextBool() ? asteroid3 : ( random.nextBool() ? asteroid4 : asteroid5 ) ) ), position, new Vec3(0.0, 0.0, 0.0))
  {
    velocity.x = random.nextDouble() * 10.0 - 5.0;
    velocity.y = random.nextDouble() * 10.0 - 5.0;
    velocity.z = random.nextDouble() * 10.0 - 5.0;
    angularVelocity = new Vec3(random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.1 - 0.05);
  }

  void tick()
  {
    rotations += angularVelocity;
    super.tick();
  }

  bool checkPlayerCollide()
  {
    double sqDistance1 = new Vec3((playerShip.position.x-position.x).abs(), (playerShip.position.y-position.y).abs(), (playerShip.position.z-position.z).abs()).sqMagnitude();;
    double sqDistance2 = new Vec3((playerShip.position.x+playerShip.velocity.x-position.x).abs(), (playerShip.position.y+playerShip.velocity.y-position.y).abs(), (playerShip.position.z+playerShip.velocity.z-position.z).abs()).sqMagnitude();;
    return (sqDistance1 < 50.0 * 50.0) || (sqDistance2 < 50.0 * 50.0);
  }

}

class Crosshair extends Entity
{

  Crosshair(): super(new Geometry('entities/crosshair.json'), new Vec3(0.0, 0.0, 0.0), new Vec3(0.0, 0.0, 0.0));
  Matrix4x3 aimMatrix = new Matrix4x3.identity();

  void draw(double partialTime)
  {
    if(game_3d)
    {
      matrixStack.pushModel();
      matrixStack.modelMatrix.multiply(MatrixFactory.translationMatrix(50.0, 0.0, 0.0));
      node.nodes[0].draw(partialTime);
      matrixStack.modelMatrix.multiply(aimMatrix);
      matrixStack.modelMatrix.multiply(MatrixFactory.translationMatrix(50.0, 0.0, 0.0));
      node.nodes[0].draw(partialTime);
      matrixStack.modelMatrix.multiply(aimMatrix);
      matrixStack.modelMatrix.multiply(MatrixFactory.translationMatrix(50.0, 0.0, 0.0));
      node.nodes[0].draw(partialTime);
      matrixStack.popModel();
    }
    else
    {
      node.transform._elements[12] = position.x;
      node.lastTransform = node.transform;
      node.draw(partialTime);
    }
  }

}

class PlayerShip extends Entity
{

  DAG_Node aiming = new DAG_Node([crosshair]);

  PlayerShip(): super(new Geometry('entities/space-ship.json'), new Vec3(0.0, 0.0, 0.0), new Vec3(0.0, 0.0, 0.0))
  {
    node.nodes.add(aiming);
  }

  void tick()
  {
    velocity.scale(0.85);
    position.add(velocity.x, velocity.y, ( game_3d ? velocity.z : 0.0 ));
    node.transform._elements[12] = position.x;
    node.transform._elements[13] = position.y;
    node.transform._elements[14] = position.z;
  }

  void setCamera()
  {
    if(game_3d)
    {
      camera.transform = playerShip.node.transform.clone(3);
      camera.transform.multiply(MatrixFactory.translationMatrix(-150.0, 0.0, 50.0));
      camera.transform.multiply(MatrixFactory.rotationMatrix(-PI/2.0 + 0.1745329252, 0.0, 1.0, 0.0));
      camera.transform.multiply(MatrixFactory.rotationMatrix(-PI/2.0, 0.0, 0.0, 1.0));
    }
    else
    {
      camera.transform = MatrixFactory.translationMatrix(playerShip.position.x - 500.0, playerShip.position.y - 350.0, 0.0);
    }
  }

}