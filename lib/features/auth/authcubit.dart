import 'package:bloc/bloc.dart';
import 'package:chatterjii/features/auth/authdatamodel.dart';
import 'package:chatterjii/features/auth/authrepo.dart';

class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  final String message;

  AuthUnauthenticated(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final Stream<UserModel?> _userStream;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _userStream = _authRepository.user;
    _userStream.listen((UserModel? user) {
      if (user != null) {
        emit(AuthAuthenticated(user as UserModel));
      } else {
        emit(AuthUnauthenticated('unauthenticated'));
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      emit(AuthLoading());
      final user =
          await _authRepository.signInWithEmailAndPassword(email, password);
      emit(AuthAuthenticated(user as UserModel));
    } catch (e) {
      emit(AuthUnauthenticated(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final user = await _authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user as UserModel));
    } catch (e) {
      emit(AuthUnauthenticated(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      emit(AuthLoading());
      final user = await _authRepository.signUpWithEmailAndPassword(
          email, password, displayName);
      emit(AuthAuthenticated(user as UserModel));
    } catch (e) {
      emit(AuthUnauthenticated(e.toString()));
    }
  }

  // Future<void> signInWithApple() async {
  //   try {
  //     emit(AuthLoading());
  //     final user = await _authRepository.signInWithApple();
  //     emit(AuthAuthenticated(user! as User));
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //     emit(AuthUnauthenticated());
  //   }
  // }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated('sign out event'));
  }
}
