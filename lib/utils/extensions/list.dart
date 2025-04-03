extension MapIndexed<E> on List<E> {
  List<T> mapIndexed<T>(T Function(int index, E e) toElement) {
    List<T> newList = [];
    for (int i = 0; i < length; i++) {
      newList.add(toElement(i, this[i]));
    }
    return newList;
  }
}
