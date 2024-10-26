import 'package:chatterjii/features/auth/authdatamodel.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserModel> users;

  UsersLoaded(this.users);
}

class UsersError extends UsersState {
  final String message;

  UsersError(this.message);
}

class UserCubit extends Cubit<UsersState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserCubit() : super(UsersInitial());

  void fetchUsers() async {
    try {
      emit(UsersLoading());
      String currentUserId = AuthRepository.getCurrentUser()!.uid;
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.uid != currentUserId)
          .toList();

      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  void searchUsers(String query) async {
    try {
      emit(UsersLoading());
      String currentUserId = AuthRepository.getCurrentUser()!.uid;
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.uid != currentUserId)
          .where((user) =>
              user.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }
}
