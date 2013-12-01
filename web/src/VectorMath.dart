part of gitfighter;

class Vec2
{

  double x;
  double y;

  Vec2(this.x, this.y);

}

class Vec3
{

  double x;
  double y;
  double z;
  double w;

  Vec3(this.x, this.y, this.z)
  {
    w = 1.0;
  }

  Vec3.direction(this.x, this.y, this.z)
  {
    w = 0.0;
  }

  operator +(Vec3 other)
  {
    return new Vec3(x + other.x, y + other.y, z + other.z);
  }

  void multiply(Matrix4 m)
  {
    double oX = x;
    double oY = y;
    double oZ = z;
    double oW = w;
    x = (m._elements[0] * oX) + (m._elements[4] * oY) + (m._elements[8] * oZ) + (m._elements[12] * oW);
    y = (m._elements[1] * oX) + (m._elements[5] * oY) + (m._elements[9] * oZ) + (m._elements[13] * oW);
    z = (m._elements[2] * oX) + (m._elements[6] * oY) + (m._elements[10] * oZ) + (m._elements[14] * oW);
    w = (m._elements[3] * oX) + (m._elements[7] * oY) + (m._elements[11] * oZ) + (m._elements[15] * oW);
  }

  void add(double aX, double aY, double aZ)
  {
    x += aX;
    y += aY;
    z += aZ;
  }

  void scale(double factor)
  {
    x *= factor;
    y *= factor;
    z *= factor;
  }

  double sqMagnitude()
  {
    return (x * x) + (y * y) + (z * z);
  }

  double magnitude()
  {
    return sqrt( sqMagnitude() );
  }

  double dot(Vec3 other)
  {
    return x*other.x + y*other.y + z*other.z;
  }

}

abstract class Matrix4
{
  
  final Float32List _elements = new Float32List(16);

  Matrix4()
  {
    for(int i = 0; i < 16; ++i)
    {
      this._elements[i] = 0.0;
    }
  }

  setElement(int i, int j, num value)
  {
    this._elements[(4*i) + j] = value;
  }
  
  void writeToUniform(UniformLocation uniform)
  {
    gl.uniformMatrix4fv(uniform, false, _elements);
  }
  
  multiply(Matrix4 m)
  {
    num x1 = this._elements[0]*m._elements[0] + this._elements[4]*m._elements[1] + this._elements[8]*m._elements[2] + this._elements[12]*m._elements[3];
    num x2 = this._elements[1]*m._elements[0] + this._elements[5]*m._elements[1] + this._elements[9]*m._elements[2] + this._elements[13]*m._elements[3];
    num x3 = this._elements[2]*m._elements[0] + this._elements[6]*m._elements[1] + this._elements[10]*m._elements[2] + this._elements[14]*m._elements[3];
    num x4 = this._elements[3]*m._elements[0] + this._elements[7]*m._elements[1] + this._elements[11]*m._elements[2] + this._elements[15]*m._elements[3];

    num y1 = this._elements[0]*m._elements[4] + this._elements[4]*m._elements[5] + this._elements[8]*m._elements[6] + this._elements[12]*m._elements[7];
    num y2 = this._elements[1]*m._elements[4] + this._elements[5]*m._elements[5] + this._elements[9]*m._elements[6] + this._elements[13]*m._elements[7];
    num y3 = this._elements[2]*m._elements[4] + this._elements[6]*m._elements[5] + this._elements[10]*m._elements[6] + this._elements[14]*m._elements[7];
    num y4 = this._elements[3]*m._elements[4] + this._elements[7]*m._elements[5] + this._elements[11]*m._elements[6] + this._elements[15]*m._elements[7];

    num z1 = this._elements[0]*m._elements[8] + this._elements[4]*m._elements[9] + this._elements[8]*m._elements[10] + this._elements[12]*m._elements[11];
    num z2 = this._elements[1]*m._elements[8] + this._elements[5]*m._elements[9] + this._elements[9]*m._elements[10] + this._elements[13]*m._elements[11];
    num z3 = this._elements[2]*m._elements[8] + this._elements[6]*m._elements[9] + this._elements[10]*m._elements[10] + this._elements[14]*m._elements[11];
    num z4 = this._elements[3]*m._elements[8] + this._elements[7]*m._elements[9] + this._elements[11]*m._elements[10] + this._elements[15]*m._elements[11];

    num t1 = this._elements[0]*m._elements[12] + this._elements[4]*m._elements[13] + this._elements[8]*m._elements[14] + this._elements[12]*m._elements[15];
    num t2 = this._elements[1]*m._elements[12] + this._elements[5]*m._elements[13] + this._elements[9]*m._elements[14] + this._elements[13]*m._elements[15];
    num t3 = this._elements[2]*m._elements[12] + this._elements[6]*m._elements[13] + this._elements[10]*m._elements[14] + this._elements[14]*m._elements[15];
    num t4 = this._elements[3]*m._elements[12] + this._elements[7]*m._elements[13] + this._elements[11]*m._elements[14] + this._elements[15]*m._elements[15];

    this._elements[0] = x1;
    this._elements[1] = x2;
    this._elements[2] = x3;
    this._elements[3] = x4;
    this._elements[4] = y1;
    this._elements[5] = y2;
    this._elements[6] = y3;
    this._elements[7] = y4;
    this._elements[8] = z1;
    this._elements[9] = z2;
    this._elements[10] = z3;
    this._elements[11] = z4;
    this._elements[12] = t1;
    this._elements[13] = t2;
    this._elements[14] = t3;
    this._elements[15] = t4;
  }

  void printMatrix()
  {
    print('┌\t\t\t\t┐');
    print('│ '+_elements[0].toStringAsFixed(5)+'\t'+_elements[4].toStringAsFixed(5)+'\t'+_elements[8].toStringAsFixed(5)+'\t'+_elements[12].toStringAsFixed(5)+'\t│');
    print('│ '+_elements[1].toStringAsFixed(5)+'\t'+_elements[5].toStringAsFixed(5)+'\t'+_elements[9].toStringAsFixed(5)+'\t'+_elements[13].toStringAsFixed(5)+'\t│');
    print('│ '+_elements[2].toStringAsFixed(5)+'\t'+_elements[6].toStringAsFixed(5)+'\t'+_elements[10].toStringAsFixed(5)+'\t'+_elements[14].toStringAsFixed(5)+'\t│');
    print('│ '+_elements[3].toStringAsFixed(5)+'\t'+_elements[7].toStringAsFixed(5)+'\t'+_elements[11].toStringAsFixed(5)+'\t'+_elements[15].toStringAsFixed(5)+'\t│');
    print('└\t\t\t\t┘');
  }

  Matrix4 clone(int rows)
  {
    Matrix4 mat;
    if(rows == 3)
    {
      mat = new Matrix4x3.make(_elements[0], _elements[1], _elements[2], _elements[4], _elements[5], _elements[6], _elements[8], _elements[9], _elements[10], _elements[12], _elements[13], _elements[14]);
    }
    else if(rows == 4)
    {
      mat = new Matrix4x4.make(_elements[0], _elements[1], _elements[2], _elements[3], _elements[4], _elements[5], _elements[6], _elements[7], _elements[8], _elements[9], _elements[10], _elements[11], _elements[12], _elements[13], _elements[14], _elements[15]);
    }
    return mat;
  }

}

class Matrix4x3 extends Matrix4
{
  
  Matrix4x3.make(num x1, num x2, num x3, num y1, num y2, num y3, num z1, num z2, num z3, num t1, num t2, num t3)
  {
    this._elements[0] = x1;
    this._elements[1] = x2;
    this._elements[2] = x3;
    this._elements[4] = y1;
    this._elements[5] = y2;
    this._elements[6] = y3;
    this._elements[8] = z1;
    this._elements[9] = z2;
    this._elements[10] = z3;
    this._elements[12] = t1;
    this._elements[13] = t2;
    this._elements[14] = t3;
    this._elements[15] = 1.0;
  }
  
  Matrix4x3.identity()
  {
    this._elements[0] = 1.0;
    this._elements[5] = 1.0;
    this._elements[10] = 1.0;
    this._elements[15] = 1.0;
  }
  
  Matrix4x3 inverse()
  {
    num it0 = -this._elements[12];
    num it1 = -this._elements[13];
    num it2 = -this._elements[14];

    num X = this._elements[0] * it0 + this._elements[1] * it1 + this._elements[2] * it2;
    num Y = this._elements[4] * it0 + this._elements[5] * it1 + this._elements[6] * it2;
    num Z = this._elements[8] * it0 + this._elements[9] * it1 + this._elements[10] * it2;
    return new Matrix4x3.make(
        this._elements[0], this._elements[4], this._elements[8],
        this._elements[1], this._elements[5], this._elements[9],
        this._elements[2], this._elements[6], this._elements[10],
        X, Y, Z);
  }

  Matrix4x3 interpolate(Matrix4x3 m, double partial)
  {
    Matrix4x3 result = new Matrix4x3.identity();
    for(int i = 0; i < 16; ++i)
    {
      result._elements[i] = (this._elements[i] * (1.0 - partial)) + (m._elements[i] * partial);
    }
    return result;
  }

}

class Matrix4x4 extends Matrix4
{
  
  Matrix4x4.make(num x1, num x2, num x3, num x4, num y1, num y2, num y3, num y4, num z1, num z2, num z3, num z4, num t1, num t2, num t3, num t4)
  {
    this._elements[0] = x1;
    this._elements[1] = x2;
    this._elements[2] = x3;
    this._elements[3] = x4;
    this._elements[4] = y1;
    this._elements[5] = y2;
    this._elements[6] = y3;
    this._elements[7] = y4;
    this._elements[8] = z1;
    this._elements[9] = z2;
    this._elements[10] = z3;
    this._elements[11] = z4;
    this._elements[12] = t1;
    this._elements[13] = t2;
    this._elements[14] = t3;
    this._elements[15] = t4;
  }
  
  Matrix4x4.identity()
  {
    this._elements[0] = 1.0;
    this._elements[5] = 1.0;
    this._elements[10] = 1.0;
    this._elements[15] = 1.0;
  }
  
}

class MatrixStack
{
  
  Matrix4x3 modelMatrix = new Matrix4x3.identity();
  Matrix4x3 viewMatrix = new Matrix4x3.identity();
  Matrix4x4 projectionMatrix = new Matrix4x4.identity();
  final Queue<Matrix4> _modelStack = new Queue();
  final Queue<Matrix4> _viewStack = new Queue();
  final Queue<Matrix4> _projectionStack = new Queue();

  pushModel()
  {
    _modelStack.addLast(modelMatrix.clone(3));
  }

  popModel()
  {
    modelMatrix = _modelStack.removeLast();
  }
  
  pushView()
  {
    _viewStack.addLast(viewMatrix.clone(3));
  }

  popView()
  {
    viewMatrix = _viewStack.removeLast();
  }

  pushProjection()
  {
    _projectionStack.addLast(projectionMatrix.clone(4));
  }

  popProjection()
  {
    projectionMatrix = _projectionStack.removeLast();
  }

}

class MatrixFactory
{
  
  static Matrix4x3 translationMatrix(num x, num y, num z)
  {
    return new Matrix4x3.make(
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
          x,   y,   z);
  }

  static Matrix4x3 scaleMatrix(num sX, num sY, num sZ)
  {
    return new Matrix4x3.make(
         sX, 0.0, 0.0,
        0.0,  sY, 0.0,
        0.0, 0.0,  sZ,
        0.0, 0.0, 0.0);
  }

  static Matrix4x3 rotationMatrix(num angle, num x, num y, num z)
  {
    num invLen = 1 / sqrt(x*x + y*y + z*z);
    x *= invLen;
    y *= invLen;
    z *= invLen;

    num s = sin(angle);
    num c = cos(angle);
    num t = 1 - c;

    return new Matrix4x3.make(
        t * x*x + c,   t * x*y + s*z, t * x*z - s*y,
        t * x*y - s*z, t * y*y + c,   t * y*z + s*x,
        t * x*z + s*y, t * y*z - s*x, t * z*z + c,
        0.0,           0.0,           0.0);
  }

  static Matrix4x4 perspectiveMatrix(num fov, num aspect, num znear, num zfar)
  {
    num top = znear * tan(fov * PI / 360.0);
    num bottom = -top;
    num left = bottom * aspect;
    num right = top * aspect;

    num X =         2 * znear / (right - left);
    num Y =         2 * znear / (top - bottom);
    num A =    (right + left) / (right - left);
    num B =    (top + bottom) / (top - bottom);
    num C =   -(zfar + znear) / (zfar - znear);
    num D = -2 * zfar * znear / (zfar - znear);

    return new Matrix4x4.make(
          X,  0.0,  0.0,  0.0,
        0.0,    Y,  0.0,  0.0,
          A,    B,    C, -1.0,
        0.0,  0.0,    D,  0.0);
  }

  static Matrix4x4 orthogonalMatrix(double xLeft, double xRight, double yTop, double yBottom, double zNear, double zFar)
  {
    double invWidth = 1.0 / (xRight - xLeft);
    double invHeight = 1.0 / (yTop - yBottom);
    double invDepth = 1.0 / (zNear - zFar);

    return new Matrix4x4.make(
         2.0*invWidth,                 0.0,                           0.0,                       0.0,
         0.0,                          2.0*invHeight,                 0.0,                       0.0,
         0.0,                          0.0,                           2.0*invDepth,              0.0,
        -1.0*(xLeft+xRight)*invWidth, -1.0*(yBottom+yTop)*invHeight, -1.0*(zFar+zNear)*invDepth, 1.0);
  }

}

class VectorMath
{

  static double sqDistanceToLine(Vec3 line1, Vec3 line2, Vec3 point)
  {
    Vec3 line = new Vec3(line2.x-line1.x, line2.y-line1.y, line2.z-line1.z);
    double length = line.magnitude();
    line.scale(1.0/length);
    Vec3 projection = new Vec3(point.x-line1.x, point.y-line1.y, point.z-line1.z);
    double distance = projection.dot(line);
    Vec3 closest;
    if(distance < 0)
    {
      closest = new Vec3(line1.x, line1.y, line1.z);
    }
    else if(distance > length)
    {
      closest = new Vec3(line2.x, line2.y, line2.z);
    }
    else
    {
      line.scale(distance);
      closest = new Vec3(line1.x+line.x, line1.y+line.y, line1.z+line.z);
    }
    closest.add(-point.x, -point.y, -point.z);
    return closest.sqMagnitude();
  }

}