part of gitfighter;

class Sound
{

  static AudioContext audio;
  static bool useWebAudio;
  double volume = 0.6;
  Object element;
  bool loaded = false;
  
  static void init()
  {
    if(window.navigator.userAgent.contains('Firefox'))
    {
      useWebAudio = false; // The newest version of Firefox breaks my WebAudio implementation...
      return;             //  So we force the fallback system on FF.
    }
    try
    {
      audio = new AudioContext();
      useWebAudio = true;
    }
    catch(e)
    {
      useWebAudio = false;
    }
  }

  Sound(String url)
  {
    if(useWebAudio)
    {
      HttpRequest.request(url, method: 'GET', responseType: 'arraybuffer').then((HttpRequest request) {
        audio.decodeAudioData(request.response).then((AudioBuffer buffer) {
          element = buffer;
          loaded = true;
        });
      });
    }
    else
    {
      element = new AudioElement();
      document.body.append(element);
      (element as AudioElement).onCanPlay.listen((Event e) {
        if(!loaded)
        {
          loaded = true;
        }
      });
      (element as AudioElement).src = url;
      (element as AudioElement).preload = 'auto';
      (element as AudioElement).controls = false;
    }
  }

  Sound.andPlay(String url)
  {
    if(useWebAudio)
    {
      HttpRequest.request(url, method: 'GET', responseType: 'arraybuffer').then((HttpRequest request) {
        audio.decodeAudioData(request.response).then((AudioBuffer buffer) {
          element = buffer;
          loaded = true;
          play();
        });
      });
    }
    else
    {
      element = new AudioElement();
      document.body.append(element);
      (element as AudioElement).onCanPlay.listen((Event e) {
        if(!loaded)
        {
          loaded = true;
          play();
        }
      });
      (element as AudioElement).src = url;
      (element as AudioElement).preload = 'auto';
      (element as AudioElement).controls = false;
    }
  }

  Object play()
  {
    if(loaded)
    {
      if(useWebAudio)
      {
        AudioBufferSourceNode source = audio.createBufferSource();
        GainNode gain = audio.createGainNode();
        gain.gain.value = volume;
        source.connectNode(gain);
        gain.connectNode(audio.destination);
        source.buffer = element;
        source.noteOn(0);
        return source;
      }
      else
      {
        (element as AudioElement).volume = volume;
        (element as AudioElement).currentTime = 0;
        (element as AudioElement).play();
        return element;
      }
    }
  }

}

class Music extends Sound
{

  static Object activeMusic;
  
  Music(String url) : super(url)
  {
    volume = 0.3;
  }

  Music.andPlay(String url) : super.andPlay(url)
  {
    volume = 0.3;
  }
  
  Object play()
  {
    if(loaded)
    {
      stop();
      activeMusic = super.play();
      if(Sound.useWebAudio)
      {
        (activeMusic as AudioBufferSourceNode).loop = true;
      }
      else
      {
        (activeMusic as AudioElement).loop = true;
      }
    }
    return activeMusic;
  }
  
  static void stop()
  {
    if(activeMusic != null)
    {
      if(Sound.useWebAudio)
      {
        (activeMusic as AudioBufferSourceNode).noteOff(0);
      }
      else
      {
        (activeMusic as AudioElement).pause();
        (activeMusic as AudioElement).currentTime = 0;
      }
      activeMusic = null;
    }
  }

}