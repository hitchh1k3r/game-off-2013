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

class GameStates
{

  _StateBuffer buffer = new _StateBuffer();
  _StateBuffer states = new _StateBuffer();
  int tickKeyRate;

  GameStates(int tickRate)
  {
    tickKeyRate = 80 ~/ tickRate;
    window.onKeyDown.listen((KeyboardEvent e)
    {
      int kc = e.keyCode;
      if(!buffer.keyMap.containsKey(kc) || buffer.keyMap[kc] == 0)
      {
        buffer.keyMap[kc] = 1;
      }
    });
    window.onKeyUp.listen((KeyboardEvent e)
    {
      int kc = e.keyCode;
      buffer.keyMap[kc] = 0;
    });
  }

  void _poll()
  {
    states = buffer.clone();
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
  }

  bool isKeyDown(int keyCode)
  {
    return states.keyMap.containsKey(keyCode) && states.keyMap[keyCode] > 0;
  }

  bool keyPress(int keyCode)
  {
    return states.keyMap.containsKey(keyCode) && states.keyMap[keyCode] == 1;
  }

  bool keyPressOrRepeat(int keyCode)
  {
    return states.keyMap.containsKey(keyCode) && (states.keyMap[keyCode] == 1 || states.keyMap[keyCode] == 2 + tickKeyRate + tickKeyRate + tickKeyRate);
  }

}