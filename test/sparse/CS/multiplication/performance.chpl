// Sparse matrix-matrix multiplication performance benchmark

use LayoutCS;
use Random;
use Time;

// For configs and matrix multiplication routine
use correctness;

config const sparsity = 0.01,
             seed = 42;

proc main() {

  const D1 = {1..m, 1..n},
        D2 = {1..n, 1..m};

  // CSR * CSC
  {
    // Domains
    var ADom: sparse subdomain(D1) dmapped CS(row=true),
        BDom: sparse subdomain(D2) dmapped CS(row=false);

    // Arrays
    var A: [ADom] real,
        B: [BDom] real;

    // Populate
    populate(A, ADom, sparsity, seed);
    populate(B, BDom, sparsity, seed+1);

    var t: Timer;

    t.start();
    var result = multiply(A, B);
    t.stop();
    if !correctness {
      write('CSR * CSC: ');
      writeln(t.elapsed());
    }
  }


  // dense * dense
  {
    // Arrays
    var A: [D1] real,
        B: [D2] real;

    // Populate
    populate(A, sparsity, seed);
    populate(B, sparsity, seed+1);

    var t: Timer;

    t.start();
    var result = multiply(A, B);
    t.stop();
    if !correctness {
      write('dense * dense: ');
      writeln(t.elapsed());
    }
  }
}


/* Populate sparse matrix with random elements according to "sparsity" */
proc populate(ref A, ref ADom, sparsity: real, seed: int) where isSparseArr(A) {
  const nnz = (ADom._value.parentDom.size * sparsity): int;
  var indices: [1..nnz] 2*int;
  var randomIndices = makeRandomStream(eltType=int, seed=seed);
  for idx in indices {
    // Ensure no duplicates
    var newIdx = idx;
    while indices.find(newIdx)(1) {
      newIdx = (randomIndices.getNext(ADom.dim(1).low, ADom.dim(1).high), randomIndices.getNext(ADom.dim(2).low, ADom.dim(2).high));
    }
    idx = newIdx;
  }

  ADom += indices;

  var randomReals = makeRandomStream(eltType=real, seed=seed);
  for idx in ADom {
    A[idx] = randomReals.getNext();
  }
}

/* Populate dense matrix with random elements according to "sparsity" */
proc populate(ref A: [?ADom], sparsity: real, seed: int) where !isSparseArr(A) {
  const nnz= (ADom.size * sparsity): int;
  var indices: [1..nnz] 2*int;
  var randomIndices = makeRandomStream(eltType=int, seed=seed);
  for idx in indices {
    // Ensure no duplicates
    var newIdx = idx;
    while indices.find(newIdx)(1) {
      newIdx = (randomIndices.getNext(ADom.dim(1).low, ADom.dim(1).high), randomIndices.getNext(ADom.dim(2).low, ADom.dim(2).high));
    }
    idx = newIdx;
  }

  var randomReals = makeRandomStream(eltType=real, seed=seed);
  for idx in indices {
    A[idx] = randomReals.getNext();
  }
}
