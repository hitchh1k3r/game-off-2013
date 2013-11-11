part of gitfighter;

class Camera
{
  // camera attributes
    Vec3 up = new Vec3(0.0, 0.0, 1.0);
    Vec3 front = new Vec3(-1.0, 0.0, 0.0);
    Vec3 right = new Vec3(0.0, 1.0, 0.0);
    Vec3 position = new Vec3(-50.0, 0.0, 20.0);
  
  // X: pitch, Y: yaw, Z: roll
    Vec3 lastRotations = new Vec3(0.0, 0.0, 0.0);
    Vec3 rotations = new Vec3(0.0, 0.0, 0.0);

  void setYaw(double value)
  {
    rotations.y = deg2rad(value);
  }

  void setPitch(double value)
  {
    rotations.x = deg2rad(value);
  }

  void setRoll(double value)
  {
    rotations.z = deg2rad(value);
  }

  void camPan(double offset)
  {
    rotations.y += deg2rad(offset);
  }

  void camTilt(double offset)
  {
    rotations.x += deg2rad(offset);
  }

  void camRoll(double offset)
  {
    rotations.z += deg2rad(offset);
  }

  void tick()
  {
    lastRotations.x = rotations.x;
    lastRotations.y = rotations.y;
    lastRotations.z = rotations.z;
  }

  Matrix4x3 getMatrix(double interpolation)
  {
    double pitch = (interpolation * (rotations.x - lastRotations.x)) + lastRotations.x;
    double yaw = (interpolation * (rotations.y - lastRotations.y)) + lastRotations.y;
    double roll = (interpolation * (rotations.z - lastRotations.z)) + lastRotations.z;
    Vec3 tUp = new Vec3(up.x, up.y, up.z);
    Vec3 tFront = new Vec3(front.x, front.y, front.z);
    Vec3 tRight = new Vec3(right.x, right.y, right.z);
    Matrix4x3 pitchMatrix = MatrixFactory.rotationMatrix(pitch, 0.0, 1.0, 0.0);
    Matrix4x3 yawMatrix = MatrixFactory.rotationMatrix(yaw, 0.0, 0.0, 1.0);
    Matrix4x3 rollMatrix = MatrixFactory.rotationMatrix(roll, -1.0, 0.0, 0.0);
    tUp.multiply(rollMatrix);
    tUp.multiply(pitchMatrix);
    tUp.multiply(yawMatrix);
    tFront.multiply(rollMatrix);
    tFront.multiply(pitchMatrix);
    tFront.multiply(yawMatrix);
    tRight.multiply(rollMatrix);
    tRight.multiply(pitchMatrix);
    tRight.multiply(yawMatrix);
    return new Matrix4x3.make(tRight.x, tRight.y, tRight.z, tUp.x, tUp.y, tUp.z, tFront.x, tFront.y, tFront.z, position.x, position.y, position.z);
  }

}