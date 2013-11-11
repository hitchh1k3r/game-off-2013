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
part 'Entity.dart';
part 'VectorMath.dart';
part 'Sounds.dart';
part 'GameStates.dart';
part 'Node.dart';
part 'Camera.dart';

RenderingContext gl;
MatrixStack matrixStack;
Program program;
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
DAG_Node scene;
DAG_Node spinNode;
Camera camera = new Camera();
const bool DEBUG = true;
const int TICKRATE = 20;
Entity mesh;
int frame = 0;
int tickCount = 0;
bool game_textured = false;
bool game_3d = true;

void init()
{
  CanvasElement canvas = querySelector("#canvas");
  gl = canvas.getContext3d();
  matrixStack = new MatrixStack();
  gl.enable(DEPTH_TEST);
  gl.enable(CULL_FACE);
  gl.frontFace(CW);
  gl.cullFace(BACK);
  gl.clearColor(0, 0, 0, 1);
  
  Sound.init();
  // Sound sounda = new Sound('sounds/a.wav');
  // Sound soundb = new Sound('sounds/b.wav');
  // Sound soundc = new Sound('sounds/c.wav');
  // Music music = new Music('music/song.ogg');
  mesh = new Entity('entities/space-ship.json');
  spinNode = new DAG_Node([mesh]);
  List<drawable> children = new List<drawable>();
  for(int x = -1; x <= 1; ++x)
  {
    for(int y = -1; y <= 1; ++y)
    {
      for(int z = -1; z <= 1; ++z)
      {
        DAG_Node newNode = new DAG_Node([spinNode]);
        newNode.transform = MatrixFactory.translationMatrix((x * 100.0), (y * 100.0), (z * 100.0));
        children.add(newNode);
      }
    }
  }
  scene = new DAG_Node(children);
}

void tick(GameStates states)
{
  ++tickCount;
  camera.tick();
  camera.camTilt(1.0);
  camera.camPan(1.1);
  camera.camRoll(1.0);
  if(states.isKeyDown(49))
  {
    print('holding 1');
  }
  if(states.keyPress(50))
  {
    print('pressed 2');
  }
  if(states.keyPressOrRepeat(51))
  {
    print('pressed or held 3');
  }
}

void draw(double partialTickTime)
{
  ++frame;
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  spinNode.transform = MatrixFactory.rotationMatrix(frame/100, 0.0, 0.0, 1.0);
  matrixStack.viewMatrix = camera.getMatrix(partialTickTime).inverse();
  matrixStack.viewMatrix.writeToUniform(uniformVMatrix);
  gl.uniform1i(uniformRender3D, game_3d ? 1 : 0);
  gl.uniform1i(uniformUseTexture, game_textured ? 1 : 0);
  scene.draw();
}

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
  
  loadProgram('shaders/vertex-shader.txt', 'shaders/fragment-shader.txt', (Program prog) {
    program = prog;
    attribVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
    attribVertexNormal = gl.getAttribLocation(program, 'aVertexNormal');
    attribVertexTextureCoord = gl.getAttribLocation(program, 'aVertexTextureCoord');
    uniformMMatrix = gl.getUniformLocation(program, 'uMMatrix');
    uniformPMatrix = gl.getUniformLocation(program, 'uPMatrix');
    uniformVMatrix = gl.getUniformLocation(program, 'uVMatrix');
    uniformRender3D = gl.getUniformLocation(program, 'uRender3D');
    uniformUseTexture = gl.getUniformLocation(program, 'uUseTexture');
    uniformRed = gl.getUniformLocation(program, 'uRed');
    uniformGreen = gl.getUniformLocation(program, 'uGreen');
    uniformBlue = gl.getUniformLocation(program, 'uBlue');
    gl.useProgram(program);
    matrixStack.projectionMatrix = MatrixFactory.perspectiveMatrix(45, 1.8, 0.01, 1000);
    // matrixStack.projectionMatrix = MatrixFactory.orthogonalMatrix(0.0, 900.0, 0.0, 500.0, 255.0, 0.0);
    matrixStack.projectionMatrix.writeToUniform(uniformPMatrix);
    loop();
  });
}