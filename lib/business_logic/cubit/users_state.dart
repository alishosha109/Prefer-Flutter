part of 'users_cubit.dart';

@immutable
abstract class UsersState {}

class UsersInitial extends UsersState {}

class usersLoaded extends UsersState {
  final List<User> users;

  usersLoaded(this.users);
}

class usersignupcomplete extends UsersState {
  final User user;
  final bool signed;
  final int amount;
  usersignupcomplete(this.user, this.signed, this.amount);
}

class usersignupcompleteWithPromo extends UsersState {
  final User user;
  final bool signed;
  final int amount;
  usersignupcompleteWithPromo(this.user, this.signed, this.amount);
}

class usersignuperror extends UsersState {
  final String message;
  final bool signed;
  final bool loading;
  usersignuperror(this.message, this.signed, this.loading);
}

class userloading extends UsersState {
  final bool loading;
  userloading(this.loading);
}

class usersignincomplete extends UsersState {
  final User user;
  final bool signed;

  usersignincomplete(this.user, this.signed);
}

class usersigninerror extends UsersState {
  final String message;
  final bool signed;
  final bool loading;
  usersigninerror(this.message, this.signed, this.loading);
}

class numbersloaded extends UsersState {
  final List values;
  numbersloaded(this.values);
}

class promocode_valid extends UsersState {
  final int amount;

  promocode_valid(this.amount);
}

class promocode_notvalid extends UsersState {
  promocode_notvalid();
}
