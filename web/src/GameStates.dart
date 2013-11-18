part of gitfighter;

class _StateBuffer
{

  Map<int, int> keyMap = new Map<int, int>();

  _StateBuffer clone()
  {
    _StateBuffer copy = new _StateBuffer();
    copy.keyMap = keyMap;
    return copy;
  }

}

class _MouseBuffer
{

  Map<int, int> buttonMap = new Map<int, int>();

  _MouseBuffer clone()
  {
    _MouseBuffer copy = new _MouseBuffer();
    copy.buttonMap = buttonMap;
    return copy;
  }

}

class GameStates
{

  _StateBuffer buffer = new _StateBuffer();
  _StateBuffer states = new _StateBuffer();
  Point mousePoint = new Point(0, 0);
  _MouseBuffer mouseBuffer = new _MouseBuffer();
  _MouseBuffer mouseStates = new _MouseBuffer();

  int tickKeyRate;

  GameStates(int tickRate)
  {
    tickKeyRate = tickRate ~/ 5; // 5 key repeates a second
    window.onKeyDown.listen((KeyboardEvent e)
    {
      e.preventDefault();
      e.stopPropagation();
      int kc = e.keyCode;
      if(!buffer.keyMap.containsKey(kc) || buffer.keyMap[kc] == 0)
      {
        buffer.keyMap[kc] = 1;
      }
      return false;
    });
    window.onKeyUp.listen((KeyboardEvent e)
    {
      e.preventDefault();
      e.stopPropagation();
      int kc = e.keyCode;
      buffer.keyMap[kc] = 0;
      return false;
    });
    window.onMouseMove.listen((MouseEvent e) {
      mousePoint = e.client - new Point(canvas.parent.offsetLeft, canvas.parent.offsetTop);
    });
    window.onMouseDown.listen((MouseEvent e) {
      e.preventDefault();
      e.stopPropagation();
      int bn = e.button;
      if(!mouseBuffer.buttonMap.containsKey(bn) || mouseBuffer.buttonMap[bn] == 0)
      {
        mouseBuffer.buttonMap[bn] = 1;
      }
      return false;
    });
    window.onMouseUp.listen((MouseEvent e) {
      e.preventDefault();
      e.stopPropagation();
      int bn = e.button;
      mouseBuffer.buttonMap[bn] = 0;
      return false;
    });
    window.onContextMenu.listen((MouseEvent e) {
      e.preventDefault();
      e.stopPropagation();
      return false;
    });
  }

  void _poll()
  {
    states = buffer.clone();
    mouseStates = mouseBuffer.clone();
  }

  void _postTick()
  {
    for(int key in buffer.keyMap.keys)
    {
      if(buffer.keyMap[key] > 0)
      {
        if(++buffer.keyMap[key] > 2 + tickKeyRate + tickKeyRate + tickKeyRate)
        {
          buffer.keyMap[key] = 2 + tickKeyRate + tickKeyRate;
        }
      }
    }
    for(int button in mouseBuffer.buttonMap.keys)
    {
      if(mouseBuffer.buttonMap[button] > 0)
      {
        if(++mouseBuffer.buttonMap[button] > 2 + tickKeyRate)
        {
          mouseBuffer.buttonMap[button] = 2;
        }
      }
    }
  }

  bool isKeyDown(int keyCode)
  {
    return states.keyMap.containsKey(keyCode) && states.keyMap[keyCode] > 0;
  }

  bool keyPress(int keyCode)
  {
    return states.keyMap.containsKey(keyCode) && states.keyMap[keyCode] == 1;
  }

  bool keyRepeat(int keyCode)
  {
    return states.keyMap.containsKey(keyCode) && (states.keyMap[keyCode] == 2 + tickKeyRate + tickKeyRate + tickKeyRate);
  }

  bool isMouseDown(int buttonNumber)
  {
    return mouseStates.buttonMap.containsKey(buttonNumber) && mouseStates.buttonMap[buttonNumber] > 0;
  }

  bool mousePress(int buttonNumber)
  {
    return mouseStates.buttonMap.containsKey(buttonNumber) && mouseStates.buttonMap[buttonNumber] == 1;
  }

  bool mouseRepeat(int buttonNumber)
  {
    return mouseStates.buttonMap.containsKey(buttonNumber) && (mouseStates.buttonMap[buttonNumber] == 2 + tickKeyRate);
  }

}