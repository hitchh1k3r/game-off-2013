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

  static const int TEXT_GAME = 0;
  static const int UPGRADE_SCREEN = 1;
  static const int GRAPHIC_GAME = 2;
  static const int POST_GAME = 3;

  _StateBuffer buffer = new _StateBuffer();
  _StateBuffer states = new _StateBuffer();
  Point mousePoint = new Point(0, 0);
  _MouseBuffer mouseBuffer = new _MouseBuffer();
  _MouseBuffer mouseStates = new _MouseBuffer();
  int currentMode = TEXT_GAME;
  int hoverButton = 0;
  int upgradeButton = 0;
  bool buttonHovered = false;
  bool buttonClicked = false;

  int tickKeyRate;

  GameStates(int tickRate)
  {
    tickKeyRate = tickRate ~/ 5; // 5 key repeates a second
    window.onKeyDown.listen((KeyboardEvent e)
    {
      int kc = e.keyCode;
      if(!buffer.keyMap.containsKey(kc) || buffer.keyMap[kc] == 0)
      {
        buffer.keyMap[kc] = 1;
      }
      if(currentMode != TEXT_GAME)
      {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
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
      if(bn == 0)
      {
        upgradeButton = hoverButton;
        buttonClicked = (hoverButton != 0);
      }
      return false;
    });
    window.onMouseUp.listen((MouseEvent e) {
      e.preventDefault();
      e.stopPropagation();
      int bn = e.button;
      mouseBuffer.buttonMap[bn] = 0;
      if(bn == 0)
      {
        upgradeButton = 0;
        buttonClicked = false;
      }
      return false;
    });
    window.onContextMenu.listen((MouseEvent e) {
      if(currentMode != TEXT_GAME)
      {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    });
    Element button1 = querySelector("#button1");
    Element button2 = querySelector("#button2");
    Element button3 = querySelector("#button3");
    Element button4 = querySelector("#button4");
    Element button5 = querySelector("#button5");
    Element button6 = querySelector("#button6");
    Element button7 = querySelector("#button7");
    Element button8 = querySelector("#button8");
    Element bend1 = querySelector("#bend1");
    Element bend2 = querySelector("#bend2");
    Element bend3 = querySelector("#bend3");
    Element bend4 = querySelector("#bend4");
    Element bend5 = querySelector("#bend5");
    Element bend6 = querySelector("#bend6");
    Element bend7 = querySelector("#bend7");
    Element bend8 = querySelector("#bend8");
    Element line1 = querySelector("#line1");
    Element line2 = querySelector("#line2");
    Element line3 = querySelector("#line3");
    Element line4 = querySelector("#line4");
    Element arrow1 = querySelector("#arrow1");
    Element arrow2 = querySelector("#arrow2");
    void setActive(Element el, bool active)
    {
      if(active)
      {
        el.classes.add("active");
      }
      else
      {
        el.classes.remove("active");
      }
    }
    void updateUpgradeGraphics()
    {
      setActive(button1, (hoverButton == 1));
      setActive(button2, (hoverButton == 2));
      setActive(button3, (hoverButton == 3));
      setActive(button4, (hoverButton == 4));
      setActive(button5, (hoverButton == 5));
      setActive(button6, (hoverButton == 6));
      setActive(button7, (hoverButton == 7));
      setActive(button8, (hoverButton == 8));
      setActive(bend1, (hoverButton == 1));
      setActive(bend2, (hoverButton == 2));
      setActive(bend3, (hoverButton == 3));
      setActive(bend4, (hoverButton == 4));
      setActive(bend5, (hoverButton == 5));
      setActive(bend6, (hoverButton == 6));
      setActive(bend7, (hoverButton == 7));
      setActive(bend8, (hoverButton == 8));
      setActive(line1, (hoverButton == 1 || hoverButton == 2));
      setActive(line2, (hoverButton == 3 || hoverButton == 4));
      setActive(line3, (hoverButton == 5 || hoverButton == 6));
      setActive(line4, (hoverButton == 7 || hoverButton == 8));
      setActive(arrow1, (hoverButton == 1 || hoverButton == 2 || hoverButton == 3 || hoverButton == 4));
      setActive(arrow2, (hoverButton == 5 || hoverButton == 6 || hoverButton == 7 || hoverButton == 8));
    }
    button1.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 1);
      hoverButton = 1;
      updateUpgradeGraphics();
    });
    button2.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 2);
      hoverButton = 2;
      updateUpgradeGraphics();
    });
    button3.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 3);
      hoverButton = 3;
      updateUpgradeGraphics();
    });
    button4.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 4);
      hoverButton = 4;
      updateUpgradeGraphics();
    });
    button5.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 5);
      hoverButton = 5;
      updateUpgradeGraphics();
    });
    button6.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 6);
      hoverButton = 6;
      updateUpgradeGraphics();
    });
    button7.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 7);
      hoverButton = 7;
      updateUpgradeGraphics();
    });
    button8.onMouseOver.listen((MouseEvent e) {
      buttonHovered = (hoverButton != 8);
      hoverButton = 8;
      updateUpgradeGraphics();
    });
    button1.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 1)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
    });
    button2.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 2)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
    });
    button3.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 3)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
    });
    button4.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 4)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
    });
    button5.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 5)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
    });
    button6.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 6)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
    });
    button7.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 7)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
    });
    button8.onMouseOut.listen((MouseEvent e) {
      if(hoverButton == 8)
      {
        hoverButton = 0;
        upgradeButton = 0;
        buttonHovered = false;
        updateUpgradeGraphics();
      }
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
        if(++buffer.keyMap[key] > 2 + tickKeyRate)
        {
          buffer.keyMap[key] = 2;
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
    return states.keyMap.containsKey(keyCode) && (states.keyMap[keyCode] == 2 + tickKeyRate);
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

  int upgradePressed()
  {
    if(!buttonClicked)
      return 0;
    buttonClicked = false;
    return upgradeButton;
  }

  bool upgradeHovered()
  {
    if(buttonHovered)
    {
      buttonHovered = false;
      return true;
    }
    return false;
  }

  bool areAnyKeysPressed()
  {
    for(int state in states.keyMap.values)
    {
      if(state > 0)
        return true;
      
    }
    return false;
  }

}