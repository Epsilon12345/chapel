//  lhs: borrowed?  rhs: owned?  ok

class MyClass {  var x: int;  }

var rhs: owned MyClass?;

record MyRecord {
  var lhs: borrowed MyClass? = rhs;
}

var myr = new MyRecord();


