import 'package:injectable/injectable.dart';
import 'package:socials_app/core/config/injection.dart';
import 'package:socials_app/features/auth/data/dto/login_request_dto.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/utils/types.dart';
import '../../domain/repositories/auth_repo.dart';
import '../data_source/auth_remote_ds.dart';

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDS remoteDS = locator<AuthRemoteDS>();

  @override
  FutureEither<UserModel> login(LoginRequestDto params) async {
    return await remoteDS.login(params);
  }
}
