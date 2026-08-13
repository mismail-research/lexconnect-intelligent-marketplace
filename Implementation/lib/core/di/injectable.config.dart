// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:lexbid/core/di/register_module.dart' as _i223;
import 'package:lexbid/features/approval/data/dataSources/approval_remote_ds.dart'
    as _i579;
import 'package:lexbid/features/approval/data/repositories/approval_remote_ds_impl.dart'
    as _i496;
import 'package:lexbid/features/approval/domain/repositories/approval_repository.dart'
    as _i950;
import 'package:lexbid/features/approval/domain/usecase/listen_approval_status.dart'
    as _i646;
import 'package:lexbid/features/approval/presentation/bloc/approval_bloc.dart'
    as _i482;
import 'package:lexbid/features/auth/bloc/auth_bloc.dart' as _i255;
import 'package:lexbid/features/auth/data/datasources/firebase_auth_service.dart'
    as _i610;
import 'package:lexbid/features/auth/data/repository/auth_repository_impl.dart'
    as _i59;
import 'package:lexbid/features/auth/domain/repositories/auth_repository.dart'
    as _i311;
import 'package:lexbid/features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i934;
import 'package:lexbid/features/auth/domain/usecases/login_usecase.dart'
    as _i1022;
import 'package:lexbid/features/auth/domain/usecases/logout_usecase.dart'
    as _i174;
import 'package:lexbid/features/auth/domain/usecases/signup_usecase.dart'
    as _i302;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.auth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => registerModule.firestore);
    gh.lazySingleton<_i892.FirebaseMessaging>(() => registerModule.messaging);
    gh.lazySingleton<_i610.FirebaseAuthService>(
      () => _i610.FirebaseAuthService(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i311.AuthRepository>(
      () => _i59.AuthRepositoryImpl(gh<_i610.FirebaseAuthService>()),
    );
    gh.lazySingleton<_i934.ForgotPasswordUseCase>(
      () => _i934.ForgotPasswordUseCase(gh<_i311.AuthRepository>()),
    );
    gh.lazySingleton<_i1022.LoginUseCase>(
      () => _i1022.LoginUseCase(gh<_i311.AuthRepository>()),
    );
    gh.lazySingleton<_i302.SignUpUseCase>(
      () => _i302.SignUpUseCase(gh<_i311.AuthRepository>()),
    );
    gh.lazySingleton<_i579.ApprovalRemoteDataSource>(
      () => _i579.ApprovalRemoteDataSourceImpl(
        gh<_i974.FirebaseFirestore>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i174.LogoutUseCase>(
      () => _i174.LogoutUseCase(gh<_i311.AuthRepository>()),
    );
    gh.lazySingleton<_i950.ApprovalRepository>(
      () => _i496.ApprovalRepositoryImpl(gh<_i579.ApprovalRemoteDataSource>()),
    );
    gh.factory<_i646.ListenApprovalStatus>(
      () => _i646.ListenApprovalStatus(gh<_i950.ApprovalRepository>()),
    );
    gh.singleton<_i255.AuthBloc>(
      () => _i255.AuthBloc(
        loginUseCase: gh<_i1022.LoginUseCase>(),
        signUpUseCase: gh<_i302.SignUpUseCase>(),
        logoutUseCase: gh<_i174.LogoutUseCase>(),
        forgotPasswordUseCase: gh<_i934.ForgotPasswordUseCase>(),
      ),
    );
    gh.factory<_i482.ApprovalBloc>(
      () => _i482.ApprovalBloc(gh<_i646.ListenApprovalStatus>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i223.RegisterModule {}
