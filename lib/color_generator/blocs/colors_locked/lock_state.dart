part of 'lock_bloc.dart';

abstract class LockState extends Equatable {
  const LockState();
}

class LockSuccess extends LockState {
  final List<bool>? lockedColors;

  @override
  List<Object> get props => <Object>[isLocked];

  const LockSuccess({this.lockedColors});

  bool isLocked(int index) => lockedColors?[index] ?? false;
}

class LockFailure extends LockState {
  @override
  List<Object> get props => <Object>[];

  const LockFailure();
}
