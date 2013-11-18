part of gitfighter;

class MyMath
{

  static double radToDeg(double angle)
  {
    return angle * 180.0 / PI;
  }

  static double degTorad(double angle)
  {
    return angle * PI / 180.0;
  }

  static double pointToAngle(double deltaX, double deltaY)
  {
    double angle = atan2(deltaY, deltaX);
    if(angle < 0)
      angle = (2 * PI) + angle;
    return angle;
  }

}