//  lhs: unmanaged!  rhs: shared!  error: mm

class MyClass {  var x: int;  }

var rhs = new shared MyClass();

record MyRecord {
  var lhs: unmanaged MyClass = rhs;
}

var myr = new MyRecord();

compilerError("done");
