import '../../bean/pair.dart';
import '../../bean/triple.dart';

/// Dart 3 原生 Records 与传统 Pair/Triple 的桥接与互转扩展
extension PairRecordExtension<T, U> on (T, U) {
  T get first => $1;
  U get second => $2;

  Pair<T, U> toPair() => Pair<T, U>($1, $2);
}

extension PairToRecordExtension<T, U> on Pair<T, U> {
  (T, U) toRecord() => (first, second);
}

extension TripleRecordExtension<F, S, T> on (F, S, T) {
  F get first => $1;
  S get second => $2;
  T get third => $3;

  Triple<F, S, T> toTriple() => Triple<F, S, T>($1, $2, $3);
}

extension TripleToRecordExtension<F, S, T> on Triple<F, S, T> {
  (F, S, T) toRecord() => (first, second, third);
}
