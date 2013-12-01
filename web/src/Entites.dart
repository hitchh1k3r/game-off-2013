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
    node.transform = MatrixFactory.translationMatrix(position.x, position.y, position.z);
    node.lastTransform = MatrixFactory.translationMatrix(position.x, position.y, position.z);
  }

  bool tick()
  {
    node.tick(0);
    position.add(velocity.x, velocity.y, ( game_3d ? velocity.z : 0.0 ));
    node.transform = MatrixFactory.translationMatrix(position.x, position.y, ( game_3d ? position.z : 0.0 ));
    node.transform.multiply(MatrixFactory.rotationMatrix(rotations.z, 0.0, 0.0, 1.0));
    if(game_3d)
    {
      node.transform.multiply(MatrixFactory.rotationMatrix(rotations.y, 0.0, 1.0, 0.0));
      node.transform.multiply(MatrixFactory.rotationMatrix(rotations.x, 1.0, 0.0, 0.0));
    }
    while((position.x - playerShip.position.x).abs() > 3000)
    {
      if(position.x < playerShip.position.x)
      {
        position.x += 6000;
      }
      else
      {
        position.x -= 6000;
      }
      node.transform._elements[12] = position.x;
      node.lastTransform._elements[12] = position.x;
    }
    while((position.y - playerShip.position.y).abs() > 3000)
    {
      if(position.y < playerShip.position.y)
      {
        position.y += 6000;
      }
      else
      {
        position.y -= 6000;
      }
      node.transform._elements[13] = position.y;
      node.lastTransform._elements[13] = position.y;
    }
    while(game_3d && (position.z - playerShip.position.z).abs() > 3000)
    {
      if(position.z < playerShip.position.z)
      {
        position.z += 6000;
      }
      else
      {
        position.z -= 6000;
      }
      node.transform._elements[14] = position.z;
      node.lastTransform._elements[14] = position.z;
    }
    return false;
  }

  void draw(double partialTime)
  {
    if(game_3d)
    {
      Vec3 origin = new Vec3(position.x, position.y, position.z);
      origin.multiply(matrixStack.viewMatrix);
      origin.multiply(matrixStack.projectionMatrix);
      if(origin.x < 0)
        origin.x += 100;
      else
        origin.x -= 100;
      if(origin.y < 0)
        origin.y += 100;
      else
        origin.y -= 100;
      origin.x /= origin.w;
      origin.y /= origin.w;
      if(origin.x < -1 || origin.x > 1 || origin.y < -1 || origin.y > 1 || origin.z < 0 || origin.z > 6000)
        return;
    }
    else
    {
      if(position.x < playerShip.position.x - 800 ||
         position.x > playerShip.position.x + 800 ||
         position.y < playerShip.position.y - 650 ||
         position.y > playerShip.position.y + 650)
        return;
    }
    node.draw(partialTime);
  }

  double sqDistanceToPlayer()
  {
    return new Vec3((playerShip.position.x-position.x).abs(), (playerShip.position.y-position.y).abs(), (playerShip.position.z-position.z).abs()).sqMagnitude();
  }
  
}

class LaserBlast extends Entity
{

  int age = 0;

  LaserBlast(): super(laserBlast, new Vec3(playerShip.position.x, playerShip.position.y, playerShip.position.z), new Vec3.direction(playerShip.velocity.magnitude() + 35.0, 0.0, 0.0)..multiply(playerShip.node.transform));
  
  bool tick()
  {
    if(++age > (game_3d ? 40 : 20))
      return true;
    rotations.x += 0.1;
    rotations.y += 0.15;
    rotations.z += 0.2;
    return super.tick();
  }

  void draw(double partialTime)
  {
    if(fadeTime == 0 && age > (game_3d ? 30 : 10))
    {
      gl.uniform1f(uniformAlpha, ((game_3d ? 40 : 20) - age)/10.0);
    }
    if(age > 1)
    {
      super.draw(partialTime);
    }
    if(fadeTime == 0 && age > (game_3d ? 30 : 10))
    {
      gl.uniform1f(uniformAlpha, 1.0);
    }
  }

}

class EvilLaser extends Entity
{

  int age = 0;

  EvilLaser(Vec3 pos, Vec3 vel): super(evilLaser, pos, vel);
  
  bool tick()
  {
    if(++age > (game_3d ? 40 : 20))
      return true;
    if(VectorMath.sqDistanceToLine(position, new Vec3(position.x+velocity.x, position.y+velocity.y, position.z+velocity.z), playerShip.position) < 40.0 * 40.0)
    {
      playSound('explode');
      if(game_particles)
      {
        for(int i = 0; i < 10; ++i)
        {
          Particle particle = new Particle(explosionParticle, new Vec3(playerShip.position.x, playerShip.position.y, playerShip.position.z), new Vec3((random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0), 0.0, 5, 5, 25, 10);
          scene.nodes.add(particle);
          entities.add(particle);
        }
      }
      startDeath();
      return true;
    }
    rotations.x += 0.1;
    rotations.y += 0.15;
    rotations.z += 0.2;
    return super.tick();
  }

  void draw(double partialTime)
  {
    if(fadeTime == 0 && age > (game_3d ? 30 : 10))
    {
      gl.uniform1f(uniformAlpha, ((game_3d ? 40 : 20) - age)/10.0);
    }
    if(age > 1)
    {
      super.draw(partialTime);
    }
    if(fadeTime == 0 && age > (game_3d ? 30 : 10))
    {
      gl.uniform1f(uniformAlpha, 1.0);
    }
  }

}

class Particle extends Entity
{

  double rotationSpeed;
  double rotation = 0.0;
  double opacity;
  int age = 0;
  int frame = 0;
  Billboard particle;
  int life;
  int fadeTime;
  int numFrames;
  int frameLength;
  double baseOpacity;

  Particle(this.particle, Vec3 position, Vec3 velocity, this.rotationSpeed, this.numFrames, this.frameLength, this.life, this.fadeTime, [this.baseOpacity]) : super(null, position, velocity)
  {
    if(baseOpacity == null)
      baseOpacity = 1.0;
    opacity = baseOpacity;
  }

  bool tick()
  {
    if(++age > life)
    {
      return true;
    }
    if(age > life - fadeTime)
    {
      opacity = MyMath.ease((age - life + fadeTime), fadeTime, baseOpacity, 0.0);
    }
    if(game_3d)
    {
      rotation += rotationSpeed;
    }
    else
    {
      rotations.z += rotationSpeed;
    }
    if(numFrames > 1 && frameLength > 0)
    {
      int cycle = age % (numFrames * frameLength);
      frame = cycle ~/ frameLength;
    }
    return super.tick();
  }

  void draw(double partialTime)
  {
    matrixStack.pushModel();
    matrixStack.modelMatrix.multiply(node.lastTransform.interpolate(node.transform, partialTime));
    particle.drawPlus(partialTime, rotation: rotation, opacity: opacity, version: frame);
    matrixStack.popModel();
  }

}

class Asteroid extends Entity
{

  Vec3 angularVelocity;
  int type;

  Asteroid(Vec3 position): super(null, position, new Vec3(0.0, 0.0, 0.0))
  {
    type = random.nextInt(5);
    node = new DAG_Node([(type == 0 ? asteroid1 : (type == 1 ? asteroid2 : (type == 2 ? asteroid3 : (type == 3 ? asteroid4 : asteroid5))))]);
    node.transform = MatrixFactory.translationMatrix(position.x, position.y, position.z);
    node.lastTransform = MatrixFactory.translationMatrix(position.x, position.y, position.z);
    velocity.x = random.nextDouble() * 10.0 - 5.0;
    velocity.y = random.nextDouble() * 10.0 - 5.0;
    velocity.z = random.nextDouble() * 10.0 - 5.0;
    angularVelocity = new Vec3(random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.1 - 0.05);
  }

  bool tick()
  {
    rotations += angularVelocity;
    if(super.tick())
    {
      return true;
    }
    for(Entity entity in entities)
    {
      if(entity is LaserBlast && VectorMath.sqDistanceToLine(entity.position, new Vec3(entity.position.x+entity.velocity.x, entity.position.y+entity.velocity.y, entity.position.z+entity.velocity.z), position) < 60.0 * 60.0)
      {
        if(game_particles)
        {
          Billboard part1 = (type == 0 ? asteroid1Part1 : (type == 1 ? asteroid2Part1 : (type == 2 ? asteroid3Part1 : (type == 3 ? asteroid4Part1 : asteroid5Part1))));
          Billboard part2 = (type == 0 ? asteroid1Part2 : (type == 1 ? asteroid2Part2 : (type == 2 ? asteroid3Part2 : (type == 3 ? asteroid4Part2 : asteroid5Part2))));
          Billboard part3 = (type == 0 ? asteroid1Part3 : (type == 1 ? asteroid2Part3 : (type == 2 ? asteroid3Part3 : (type == 3 ? asteroid4Part3 : asteroid5Part3))));
          Particle particle1 = new Particle(part1, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0), 0.0, 1, 0, 20, 15);
          Particle particle2 = new Particle(part2, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0), 0.0, 1, 0, 20, 15);
          Particle particle3 = new Particle(part3, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0), 0.0, 1, 0, 20, 15);
          scene.nodes.add(particle1);
          entities.add(particle1);
          scene.nodes.add(particle2);
          entities.add(particle2);
          scene.nodes.add(particle3);
          entities.add(particle3);
        }
        if(bitsDropped < 30)
        {
          if(random.nextInt((game_aliens ? 4 : 2)) == 0)
          {
            Bit bit = new Bit(position);
            entities.add(bit);
            scene.nodes.add(bit);
            ++bitsDropped;
          }
        }
        playSound('explode');
        score += 100;
        Vec3 pos = randomWorldPoint();
        Asteroid asteroid = new Asteroid(pos);
        entities.add(asteroid);
        scene.nodes.add(asteroid);
        return true;
      }
    }
    if(!isDeath && checkPlayerCollide())
    {
      playSound('explode');
      if(game_particles)
      {
        Billboard part1 = (type == 0 ? asteroid1Part1 : (type == 1 ? asteroid2Part1 : (type == 2 ? asteroid3Part1 : (type == 3 ? asteroid4Part1 : asteroid5Part1))));
        Billboard part2 = (type == 0 ? asteroid1Part2 : (type == 1 ? asteroid2Part2 : (type == 2 ? asteroid3Part2 : (type == 3 ? asteroid4Part2 : asteroid5Part2))));
        Billboard part3 = (type == 0 ? asteroid1Part3 : (type == 1 ? asteroid2Part3 : (type == 2 ? asteroid3Part3 : (type == 3 ? asteroid4Part3 : asteroid5Part3))));
        Particle particle1 = new Particle(part1, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0), 0.0, 1, 0, 20, 15);
        Particle particle2 = new Particle(part2, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0), 0.0, 1, 0, 20, 15);
        Particle particle3 = new Particle(part3, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0, (random.nextDouble()-0.5)*10.0), 0.0, 1, 0, 20, 15);
        scene.nodes.add(particle1);
        entities.add(particle1);
        scene.nodes.add(particle2);
        entities.add(particle2);
        scene.nodes.add(particle3);
        entities.add(particle3);
        for(int i = 0; i < 10; ++i)
        {
          Particle particle = new Particle(explosionParticle, new Vec3(playerShip.position.x, playerShip.position.y, playerShip.position.z), new Vec3((random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0), 0.0, 5, 5, 25, 10);
          scene.nodes.add(particle);
          entities.add(particle);
        }
      }
      startDeath();
      return true;
    }
    return false;
  }

  bool checkPlayerCollide()
  {
    double sqDistance1 = new Vec3((playerShip.position.x-position.x).abs(), (playerShip.position.y-position.y).abs(), (playerShip.position.z-position.z).abs()).sqMagnitude();
    double sqDistance2 = new Vec3((playerShip.position.x+playerShip.velocity.x-position.x).abs(), (playerShip.position.y+playerShip.velocity.y-position.y).abs(), (playerShip.position.z+playerShip.velocity.z-position.z).abs()).sqMagnitude();
    return (sqDistance1 < 50.0 * 50.0) || (sqDistance2 < 50.0 * 50.0);
  }

}

class UFO extends Entity
{

  Vec3 angularVelocity;
  int laserCooldown = 0;
  int laserDirection = 0;
  int moveCooldown = 0;
  int trailCooldown = 0;

  UFO(Vec3 position): super(null, position, new Vec3(0.0, 0.0, 0.0))
  {
    node = new DAG_Node([ufoGeometry]);
    node.transform = MatrixFactory.translationMatrix(position.x, position.y, position.z);
    node.lastTransform = MatrixFactory.translationMatrix(position.x, position.y, position.z);
    velocity.x = random.nextDouble() * 15.0 - 7.5;
    velocity.y = random.nextDouble() * 15.0 - 7.5;
    velocity.z = random.nextDouble() * 15.0 - 7.5;
    angularVelocity = new Vec3(random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.5 - 0.25);
  }

  bool tick()
  {
    double sqPlayerDistance = new Vec3((playerShip.position.x-position.x).abs(), (playerShip.position.y-position.y).abs(), (playerShip.position.z-position.z).abs()).sqMagnitude();
    rotations += angularVelocity;
    if(super.tick())
    {
      return true;
    }
    if(game_trail)
    {
      if(--trailCooldown <= 0)
      {
        trailCooldown = 6;
        Particle particle = new Particle(evilTrailSprite, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*0.07, (random.nextDouble()-0.5)*0.07, (random.nextDouble()-0.5)*0.07), (random.nextDouble()-0.5)*5.0, 1, 0, 40, 20,  0.5);
        scene.nodes.add(particle);
        entities.add(particle);
      }
    }
    if(--moveCooldown <= 0)
    {
      moveCooldown = (game_AI ? random.nextInt(20)+10 : random.nextInt(60)+30);
      if(sqPlayerDistance < (game_3d ? 1500.0 * 1500.0 : 700.0 * 700.0))
      {
        velocity.x = playerShip.position.x - position.x;
        velocity.y = playerShip.position.y - position.y;
        velocity.z = playerShip.position.z - position.z;
        velocity.scale(random.nextDouble()*7.5/velocity.magnitude());
      }
      else
      {
        velocity.x = random.nextDouble() * 15.0 - 7.5;
        velocity.y = random.nextDouble() * 15.0 - 7.5;
        velocity.z = random.nextDouble() * 15.0 - 7.5;
      }
      angularVelocity = new Vec3(random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.1 - 0.05, random.nextDouble() * 0.5 - 0.25);
    }
    if(--laserCooldown <= 0)
    {
      laserCooldown = random.nextInt(10)+15;
      if(game_AI)
      {
        laserCooldown = max((600.0 - sqPlayerDistance) ~/ 150.0, 20);
      }
      ++laserDirection;
      laserDirection %= 3;
      Vec3 lVelocity;
      if(laserDirection == 0)
      {
        lVelocity = new Vec3.direction(21.21320344, 21.21320344, 0.0);
      }
      else if(laserDirection == 1)
      {
        lVelocity = new Vec3.direction(21.21320344, -21.21320344, 0.0);
      }
      else
      {
        lVelocity = new Vec3.direction(-30.0, 0.0, 0.0);
      }
      lVelocity.multiply(node.transform);
      EvilLaser laser = new EvilLaser(new Vec3(position.x, position.y, position.z), lVelocity);
      scene.nodes.add(laser);
      entities.add(laser);
      if(sqPlayerDistance < 500.0 * 500.0)
        playSound('laser');
    }
    for(Entity entity in entities)
    {
      if(entity is LaserBlast && VectorMath.sqDistanceToLine(entity.position, new Vec3(entity.position.x+entity.velocity.x, entity.position.y+entity.velocity.y, entity.position.z+entity.velocity.z), position) < 60.0 * 60.0)
      {
        if(game_particles)
        {
          for(int i = 0; i < 10; ++i)
          {
            Particle particle = new Particle(explosionParticle, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0), 0.0, 5, 5, 25, 10);
            scene.nodes.add(particle);
            entities.add(particle);
          }
        }
        if(bitsDropped < 30)
        {
          if(random.nextInt(game_AI ? 1 : 2) == 0)
          {
            Bit bit = new Bit(position);
            entities.add(bit);
            scene.nodes.add(bit);
            ++bitsDropped;
          }
        }
        score += (game_AI ? 300 : 200);
        playSound('explode');
        Vec3 pos = randomWorldPoint();
        UFO ufo = new UFO(pos);
        entities.add(ufo);
        scene.nodes.add(ufo);
        return true;
      }
    }
    if(!isDeath && checkPlayerCollide())
    {
      playSound('explode');
      if(game_particles)
      {
        for(int i = 0; i < 10; ++i)
        {
          Particle particle = new Particle(explosionParticle, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0), 0.0, 5, 5, 25, 10);
          scene.nodes.add(particle);
          entities.add(particle);
        }
        for(int i = 0; i < 10; ++i)
        {
          Particle particle = new Particle(explosionParticle, new Vec3(playerShip.position.x, playerShip.position.y, playerShip.position.z), new Vec3((random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0, (random.nextDouble()-0.5)*20.0), 0.0, 5, 5, 25, 10);
          scene.nodes.add(particle);
          entities.add(particle);
        }
      }
      startDeath();
      return true;
    }
    return false;
  }

  bool checkPlayerCollide()
  {
    double sqDistance1 = new Vec3((playerShip.position.x-position.x).abs(), (playerShip.position.y-position.y).abs(), (playerShip.position.z-position.z).abs()).sqMagnitude();
    double sqDistance2 = new Vec3((playerShip.position.x+playerShip.velocity.x-position.x).abs(), (playerShip.position.y+playerShip.velocity.y-position.y).abs(), (playerShip.position.z+playerShip.velocity.z-position.z).abs()).sqMagnitude();
    return (sqDistance1 < 60.0 * 60.0) || (sqDistance2 < 60.0 * 60.0);
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
      matrixStack.modelMatrix.multiply(aimMatrix);
      matrixStack.modelMatrix.multiply(MatrixFactory.translationMatrix(50.0, 0.0, 0.0));
      node.nodes[0].draw(partialTime);
      matrixStack.modelMatrix.multiply(aimMatrix);
      matrixStack.modelMatrix.multiply(aimMatrix);
      matrixStack.modelMatrix.multiply(MatrixFactory.translationMatrix(50.0, 0.0, 0.0));
      node.nodes[0].draw(partialTime);
      matrixStack.popModel();
    }
    else
    {
      if(game_mouse)
      {
        node.transform._elements[12] = position.x;
        node.lastTransform = node.transform;
        node.draw(partialTime);
      }
    }
  }

}

class Bit extends Entity
{

  int shape = 0;
  double spin = 0.0;
  double speed = (random.nextDouble() / 4.0) - 0.125;
  int cooldown = 5;

  bool tick()
  {
    if(game_3d)
    {
      spin += speed;
    }
    else
    {
      rotations.z += speed;
    }
    double sqDistance = sqDistanceToPlayer();
    if(!isDeath && fadeTime == 0 && sqDistance < (game_3d ? 1000.0 * 1000.0 : 500.0 * 500.0))
    {
      if(sqDistance < 40.0 * 40.0)
      {
        score += 500;
        if(++bitsGotten >= 15)
        {
          playSound('lastBit');
          startChange();
        }
        else
          playSound('getBit');
        return true;
      }
      double force = min((game_3d ? 5000.0 : 500.0) / sqrt(sqDistance), 25.0);
      velocity.x = playerShip.position.x - position.x;
      velocity.y = playerShip.position.y - position.y;
      velocity.z = playerShip.position.z - position.z;
      velocity.scale(force / velocity.magnitude());
    }
    else
    {
      velocity.scale(0.85);
    }
    if(game_particles && --cooldown <= 0)
    {
      cooldown = 5;
      Particle particle = new Particle(bitRadiation, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*5.0, (random.nextDouble()-0.5)*5.0, (random.nextDouble()-0.5)*5.0), (random.nextDouble()-0.5)*5.0, 6, 1, 30, 10);
      scene.nodes.add(particle);
      entities.add(particle);
    }
    shape = random.nextInt(6);
    return super.tick();
  }

  Bit(Vec3 position) : super(null, position, new Vec3(0.0, 0.0, 0.0));

  void draw(double partialTime)
  {
    matrixStack.pushModel();
    matrixStack.modelMatrix.multiply(node.lastTransform.interpolate(node.transform, partialTime));
    bitSprite.drawPlus(partialTime, rotation: spin, forceTexture: true, version: shape);
    matrixStack.popModel();
  }

}

class KingOfBits extends Entity
{

  int shape = 0;
  double spin = 0.0;
  double speed = 0.15;
  int cooldown = 3;

  bool tick()
  {
    if(game_3d)
    {
      spin += speed;
    }
    else
    {
      rotations.z += speed;
    }
    double sqDistance = sqDistanceToPlayer();
    if(sqDistance < 60.0 * 60.0)
    {
      game_score = false;
      playSound('lastBit');
      startChange();
      return true;
    }
    if(--cooldown <= 0)
    {
      cooldown = 3;
      Particle particle = new Particle(bigBitRadiation, new Vec3(position.x, position.y, position.z), new Vec3((random.nextDouble()-0.5)*5.0, (random.nextDouble()-0.5)*5.0, (random.nextDouble()-0.5)*5.0), (random.nextDouble()-0.5)*5.0, 6, 1, 50, 10);
      scene.nodes.add(particle);
      entities.add(particle);
    }
    shape = random.nextInt(6);
    return super.tick();
  }

  KingOfBits() : super(null, new Vec3(1000.0, 0.0, 0.0), new Vec3(0.0, 0.0, 0.0));

  void draw(double partialTime)
  {
    matrixStack.pushModel();
    matrixStack.modelMatrix.multiply(node.lastTransform.interpolate(node.transform, partialTime));
    bigBitSprite.drawPlus(partialTime, rotation: spin, forceTexture: true, version: shape);
    matrixStack.popModel();
  } 

}

class PlayerShip extends Entity
{

  DAG_Node aiming = new DAG_Node([crosshair]);

  PlayerShip(): super(new Geometry('entities/space-ship.json'), new Vec3(0.0, 0.0, 0.0), new Vec3(0.0, 0.0, 0.0))
  {
    node.nodes.add(aiming);
  }

  bool tick()
  {
    if(isDeath)
      return false;
    node.tick(0);
    velocity.scale(0.85);
    if(game_trail)
    {
      double speed = velocity.sqMagnitude();
      if(speed > 5.0 * 5.0)
      {
        Vec3 pos = new Vec3(-25.0, 0.0, 0.0);
        pos.multiply(node.transform);
        Particle particle = new Particle(trailSprite, pos, new Vec3((random.nextDouble()-0.5)*0.07, (random.nextDouble()-0.5)*0.07, (random.nextDouble()-0.5)*0.07), (random.nextDouble()-0.5)*5.0, 1, 0, 75, 20, min(speed/(game_3d ? 1500.0 : 4000.0), 0.75));
        scene.nodes.add(particle);
        entities.add(particle);
      }
    }
    position.add(velocity.x, velocity.y, ( game_3d ? velocity.z : 0.0 ));
    if(game_3d)
    {
      if(position.x > 6000)
      {
        position.x -= 12000;
        node.lastTransform._elements[12] -= 12000;
        camera.lastTransform._elements[12] -= 12000;
        camera.transform._elements[12] -= 12000;
      }
      if(position.x < -6000)
      {
        position.x += 12000;
        node.lastTransform._elements[12] += 12000;
        camera.lastTransform._elements[12] += 12000;
        camera.transform._elements[12] += 12000;
      }
      if(position.y > 6000)
      {
        position.y -= 12000;
        node.lastTransform._elements[13] -= 12000;
        camera.lastTransform._elements[13] -= 12000;
        camera.transform._elements[13] -= 12000;
      }
      if(position.y < -6000)
      {
        position.y += 12000;
        node.lastTransform._elements[13] += 12000;
        camera.lastTransform._elements[13] += 12000;
        camera.transform._elements[13] += 12000;
      }
      if(position.z > 6000)
      {
        position.z -= 12000;
        node.lastTransform._elements[14] -= 12000;
        camera.lastTransform._elements[14] -= 12000;
        camera.transform._elements[14] -= 12000;
      }
      if(position.z < -6000)
      {
        position.z += 12000;
        node.lastTransform._elements[14] += 12000;
        camera.lastTransform._elements[14] += 12000;
        camera.transform._elements[14] += 12000;
      }
    }
    node.transform._elements[12] = position.x;
    node.transform._elements[13] = position.y;
    node.transform._elements[14] = position.z;
    return false;
  }

  void draw(double partialTime)
  {
    if(!isDeath)
    {
      node.draw(partialTime);
    }
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