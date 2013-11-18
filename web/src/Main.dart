library gitfighter;

import 'dart:html';
import 'dart:web_gl';
import 'dart:web_audio';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:collection';

part 'Shaders.dart';
part 'Geometry.dart';
part 'VectorMath.dart';
part 'Sounds.dart';
part 'GameStates.dart';
part 'Node.dart';
part 'Camera.dart';
part 'TextureCache.dart';
part 'MyMath.dart';
part 'Entites.dart';

const bool DEBUG = true;
const int TICKRATE = 20;

Random random = new Random();
CanvasElement canvas;
RenderingContext gl;
MatrixStack matrixStack;
TextureCache textureCache;
Program programStandard;
Program programBackground;
Program programGUI;
int attribVertexPosition;
int attribVertexNormal;
int attribVertexTextureCoord;
UniformLocation uniformRender3D;
UniformLocation uniformUseTexture;
UniformLocation uniformRed;
UniformLocation uniformGreen;
UniformLocation uniformBlue;
UniformLocation uniformMMatrix;
UniformLocation uniformVMatrix;
UniformLocation uniformPMatrix;
UniformLocation uniformSpriteSampler;
UniformLocation uniformDiffuseSampler;
UniformLocation uniformEmissiveSampler;

Buffer screenRectBuffer;

int attribBackgroundVertex;
UniformLocation uniformBackgroundVMatrix;
UniformLocation uniformBackgroundRender3D;

Geometry asteroid1;
Geometry asteroid2;
Geometry asteroid3;
Geometry asteroid4;
Geometry asteroid5;
Geometry ship;
Crosshair crosshair;

int frame = 0;
int tickCount = 0;

bool game_textured = false;
bool game_3d = true;
bool isIn = true;
int fadeTime = 0;
int maxCircle = 3000;

Camera camera = new Camera();
PlayerShip playerShip;
List<Asteroid> asteroids = new List<Asteroid>();
DAG_Node scene;

Sound sndExplosion;

     ///////////////////////////////////////////////////////////////

void tickFade()
{
  if(fadeTime > 0)
  {
    Element circle = querySelector("#circle");
    --fadeTime;
    if(fadeTime == 0)
    {
      if(isIn)
      {
        document.body.style.backgroundColor = "#000000";
      }
      else
      {
        document.body.style.backgroundColor = "#ffffff";
      }
      circle.style.top = "345px";
      circle.style.left = "495px";
      circle.style.width = "10px";
      circle.style.height = "10px";
    }
    else
    {
      int radius = (isIn ? 5 + ((maxCircle~/15)*(15-fadeTime)) : 5 + ((maxCircle~/15)*fadeTime));
      circle.style.top = (350 - radius).toString() + "px";
      circle.style.left = (500 - radius).toString() + "px";
      circle.style.width = (2 * radius).toString() + "px";
      circle.style.height = (2 * radius).toString() + "px";
    }
  }
}

     ///////////////////////////////////////////////////////////////

void init()
{
  canvas = querySelector("#canvas");
  gl = canvas.getContext3d();
  matrixStack = new MatrixStack();
  textureCache = new TextureCache();
  gl.enable(CULL_FACE);
  gl.frontFace(CCW);
  gl.cullFace(BACK);
  gl.clearColor(0, 0, 0, 1);
  gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
  
  Sound.init();
  sndExplosion = new Sound('sounds/explosion.wav');
  // Music music = new Music.andPlay('music/crystalline.ogg');
  asteroid1 = new Geometry('entities/asteroid_large_01.json');
  asteroid2 = new Geometry('entities/asteroid_large_02.json');
  asteroid3 = new Geometry('entities/asteroid_large_03.json');
  asteroid4 = new Geometry('entities/asteroid_large_04.json');
  asteroid5 = new Geometry('entities/asteroid_large_05.json');
  crosshair = new Crosshair();
  ship = new Geometry('entities/space-ship.json');
  Random rand = new Random();
  List<drawable> children = new List<drawable>();
  playerShip = new PlayerShip();
  children.add(playerShip.node);
  for(int i = 0; i < 100; ++i)
  {
    asteroids.add(new Asteroid(new Vec3((random.nextDouble() * 6000) - 3000, (random.nextDouble() * 6000) - 3000, (random.nextDouble() * 6000) - 3000)));
    children.add(asteroids[i].node);
  }
  scene = new DAG_Node(children);
}

    ///////////////////////////////////////////////////////////////
    //                         GAME TICK                         //
    ///////////////////////////////////////////////////////////////

void tick(GameStates states)
{
  tickFade();
  ++tickCount;
  camera.tick();
  playerShip.setCamera();

  if(states.isKeyDown(32))
  {
    if(game_3d)
    {
      Vec3 direction = new Vec3(5.0, 0.0, 0.0)..w = 0.0;
      if(states.isKeyDown(16))
      {
        direction.x = 10.0;
      }
      direction.multiply(playerShip.node.transform);
      playerShip.velocity += direction;
    }
    else
    {
      double deltaX = states.mousePoint.x - 500.0;
      double deltaY = states.mousePoint.y - 350.0;
      double magnitude = sqrt( (deltaX *deltaX) + (deltaY * deltaY) );
      if(magnitude > 0)
      {
        double speed = 15.0;
        if(states.isKeyDown(16))
        {
          speed = 25.0;
        }
        playerShip.velocity.x += deltaX * speed / magnitude;
        playerShip.velocity.y += deltaY * speed / magnitude;
      }
    }
  }

  scene.tick(0);
  playerShip.tick();
  for(Asteroid asteroid in asteroids.toList())
  {
    if(asteroid.checkPlayerCollide())
    {
      sndExplosion.play();
      scene.nodes.remove(asteroid.node);
      asteroids.remove(asteroid);
    }
    else
    {
      asteroid.tick();
    }
  }

  if(game_3d)
  {
    double xOffset = min((states.mousePoint.x - 500.0).abs(), 500.0);
    double yOffset = min((states.mousePoint.y - 350.0).abs(), 350.0);
    double mag = playerShip.velocity.magnitude();
    if(states.isKeyDown(16))
    {
      mag *= 0.5;
    }
    xOffset *= mag;
    yOffset *= mag;
    crosshair.aimMatrix = new Matrix4x3.identity();
    if(states.isMouseDown(2))
    {
      Matrix4x3 matrix = MatrixFactory.rotationMatrix(((states.mousePoint.x > 500.0 ? 1.0 : -1.0) * xOffset / 50000.0), 1.0, 0.0, 0.0);
      crosshair.aimMatrix.multiply(matrix);
      playerShip.node.transform.multiply(matrix);
    }
    else
    {
      Matrix4x3 matrix = MatrixFactory.rotationMatrix(((states.mousePoint.x > 500.0 ? -1.0 : 1.0) * xOffset / 150000.0), 0.0, 0.0, 1.0);
      crosshair.aimMatrix.multiply(matrix);
      playerShip.node.transform.multiply(matrix);
    }
    if(states.isMouseDown(2))
    {
      Matrix4x3 matrix = MatrixFactory.rotationMatrix(((states.mousePoint.y > 350.0 ? 1.0 : -1.0) * yOffset / 250000.0), 0.0, 1.0, 0.0);
      crosshair.aimMatrix.multiply(matrix);
      playerShip.node.transform.multiply(matrix);
    }
    else
    {
      Matrix4x3 matrix = MatrixFactory.rotationMatrix(((states.mousePoint.y > 350.0 ? 1.0 : -1.0) * yOffset / 150000.0), 0.0, 1.0, 0.0);
      crosshair.aimMatrix.multiply(matrix);
      playerShip.node.transform.multiply(matrix);
    }
  }
  else
  {
    double mouseX = states.mousePoint.x - 500.0;
    double mouseY = states.mousePoint.y - 350.0;
    playerShip.node.transform = MatrixFactory.translationMatrix(playerShip.position.x, playerShip.position.y, playerShip.position.z);
    playerShip.node.transform.multiply(MatrixFactory.rotationMatrix(MyMath.pointToAngle(mouseX, mouseY), 0.0, 0.0, 1.0));
    crosshair.position.x = sqrt((mouseX * mouseX) + (mouseY * mouseY));
  }

  if(states.isKeyDown(87)) // W
  {
    playerShip.node.transform.multiply(MatrixFactory.rotationMatrix(-0.05, 0.0, 1.0, 0.0));
  }
  if(states.isKeyDown(65)) // A
  {
    playerShip.node.transform.multiply(MatrixFactory.rotationMatrix(0.05, 0.0, 0.0, 1.0));
  }
  if(states.isKeyDown(83)) // S
  {
    playerShip.node.transform.multiply(MatrixFactory.rotationMatrix(0.05, 0.0, 1.0, 0.0));
  }
  if(states.isKeyDown(68)) // D
  {
    playerShip.node.transform.multiply(MatrixFactory.rotationMatrix(-0.05, 0.0, 0.0, 1.0));
  }
  if(states.isKeyDown(81)) // Q
  {
    playerShip.node.transform.multiply(MatrixFactory.rotationMatrix(-0.05, 1.0, 0.0, 0.0));
  }
  if(states.isKeyDown(69)) // E
  {
    playerShip.node.transform.multiply(MatrixFactory.rotationMatrix(0.05, 1.0, 0.0, 0.0));
  }

  if(states.keyPress(49))
  {
    game_3d = !game_3d;
    if(game_3d)
    {
      for(Asteroid asteroid in asteroids)
      {
        asteroid.position.z = (random.nextDouble() * 6000) - 3000;
      }
      matrixStack.projectionMatrix = MatrixFactory.perspectiveMatrix(45, 1.428571428571429, 0.01, 3000);
    }
    else
    {
      playerShip.position.z = 0.0;
      for(Asteroid asteroid in asteroids)
      {
        asteroid.position.z = 0.0;
      }
      matrixStack.projectionMatrix = MatrixFactory.orthogonalMatrix(0.0, 1000.0, 0.0, 700.0, 1.0, -1.0);
    }
    matrixStack.projectionMatrix.writeToUniform(uniformPMatrix);
  }
  if(states.keyPress(50))
  {
    game_textured = !game_textured;
  }
  if(states.mousePress(0) || states.mouseRepeat(0))
  {
    print('SHOOT!');
  }
  if(states.keyPress(53))
  {
    print(document.body.style.backgroundColor + "to white");
    maxCircle = window.screen.available.width;
    Element circle = querySelector("#circle");
    circle.style.top = (350 - maxCircle).toString() + "px";
    circle.style.left = (500 - maxCircle).toString() + "px";
    circle.style.width = (2 * maxCircle).toString() + "px";
    circle.style.height = (2 * maxCircle).toString() + "px";
    document.body.style.backgroundColor = "#ffffff";
    isIn = false;
    fadeTime = 15;
  }
  if(states.keyPress(54))
  {
    print(document.body.style.backgroundColor + "to black");
    maxCircle = window.screen.available.width;
    isIn = true;
    fadeTime = 15;
  }
}

     ///////////////////////////////////////////////////////////////
     //                         GAME DRAW                         //
     ///////////////////////////////////////////////////////////////

void draw(double partialTickTime)
{
  ++frame;
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);

  // DRAW BACGROUND
  gl.disable(DEPTH_TEST);
  gl.disable(BLEND);
  gl.useProgram(programBackground);

  camera.getMatrix(partialTickTime).writeToUniform(uniformBackgroundVMatrix);
  gl.enableVertexAttribArray(attribBackgroundVertex);
  gl.bindBuffer(ARRAY_BUFFER, screenRectBuffer);
  gl.vertexAttribPointer(attribBackgroundVertex, 2, FLOAT, false, 0, 0);
  gl.uniform1i(uniformBackgroundRender3D, game_3d ? 1 : 0);
  gl.drawArrays(TRIANGLES, 0, 6);
  gl.disableVertexAttribArray(attribBackgroundVertex);
  
  if(programStandard != null)
  {
    // DRAW SCENE
    gl.enable(DEPTH_TEST);
    gl.enable(BLEND);
    gl.useProgram(programStandard);
    matrixStack.viewMatrix = camera.getMatrix(partialTickTime).inverse();
    matrixStack.viewMatrix.writeToUniform(uniformVMatrix);
    gl.uniform1i(uniformRender3D, game_3d ? 1 : 0);
    gl.uniform1i(uniformUseTexture, game_textured ? 1 : 0);
    scene.draw(partialTickTime);
  }

  // DRAW GUI
//  gl.disable(DEPTH_TEST);
//  gl.disable(BLEND);
//  gl.useProgram(programGUI);
  
}

     ///////////////////////////////////////////////////////////////

main()
{
  init();
  Future tickTimer;
  int lastTime = new DateTime.now().millisecondsSinceEpoch;
  GameStates states = new GameStates(20);
  int partialTickTime = 0;

  void loop()
  { 
    // frame time calcs
    int time = new DateTime.now().millisecondsSinceEpoch;
    Duration frameTime = new Duration(milliseconds: time - lastTime);
    lastTime = time;

    // tick
    int maxTickCounter = 100;
    partialTickTime += frameTime.inMilliseconds;
    if(partialTickTime > 1000~/TICKRATE)
    {
      states._poll();
    }
    while(partialTickTime > 1000~/TICKRATE)
    {
      if(--maxTickCounter <= 0)
      {
        print('Game Engine cannot keep up, reseting tick counter in hopes of recovering.');
        partialTickTime = 1000 ~/ TICKRATE;
      }
      partialTickTime -= 1000 ~/ TICKRATE;
      tick(states);
      states._postTick();
    }

    // render
    draw(partialTickTime * TICKRATE / 1000.0 );

    // schedule next frame
    int renderTime = new DateTime.now().millisecondsSinceEpoch - lastTime;
    tickTimer = new Future.delayed(new Duration(milliseconds: 16 - renderTime), loop);
  }
  
  loadProgram('shaders/background-vertex-shader.txt', 'shaders/background-fragment-shader.txt', (Program prog) {
    programBackground = prog;
    gl.useProgram(programBackground);
    attribBackgroundVertex = gl.getAttribLocation(programBackground, 'aVertexPosition');
    uniformBackgroundVMatrix = gl.getUniformLocation(programBackground, 'uVMatrix');
    uniformBackgroundRender3D = gl.getUniformLocation(programBackground, 'uRender3D');
    screenRectBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, screenRectBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([-1.0, -1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0]), STATIC_DRAW);

    loadProgram('shaders/standard-vertex-shader.txt', 'shaders/standard-fragment-shader.txt', (Program prog) {
      programStandard = prog;
      gl.useProgram(programStandard);
      attribVertexPosition = gl.getAttribLocation(programStandard, 'aVertexPosition');
      attribVertexNormal = gl.getAttribLocation(programStandard, 'aVertexNormal');
      attribVertexTextureCoord = gl.getAttribLocation(programStandard, 'aVertexTextureCoord');
      uniformMMatrix = gl.getUniformLocation(programStandard, 'uMMatrix');
      uniformPMatrix = gl.getUniformLocation(programStandard, 'uPMatrix');
      uniformVMatrix = gl.getUniformLocation(programStandard, 'uVMatrix');
      uniformRender3D = gl.getUniformLocation(programStandard, 'uRender3D');
      uniformUseTexture = gl.getUniformLocation(programStandard, 'uUseTexture');
      uniformRed = gl.getUniformLocation(programStandard, 'uRed');
      uniformGreen = gl.getUniformLocation(programStandard, 'uGreen');
      uniformBlue = gl.getUniformLocation(programStandard, 'uBlue');
      uniformSpriteSampler = gl.getUniformLocation(programStandard, 'uSpriteSampler');
      uniformDiffuseSampler = gl.getUniformLocation(programStandard, 'uDiffuseSampler');
      uniformEmissiveSampler = gl.getUniformLocation(programStandard, 'uEmissiveSampler');
      if(game_3d)
      {
        matrixStack.projectionMatrix = MatrixFactory.perspectiveMatrix(45, 1.428571428571429, 0.01, 6000);
      }
      else
      {
        matrixStack.projectionMatrix = MatrixFactory.orthogonalMatrix(0.0, 1000.0, 0.0, 700.0, 1.0, -1.0);
      }
      matrixStack.projectionMatrix.writeToUniform(uniformPMatrix);
    });
    loop();
  });
}