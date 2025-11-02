import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/injection.dart';
import '../../../../core/models/enums/http_method.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/network_service/api_service.dart';
import '../../../../core/services/network_service/end_points.dart';
import '../../../../core/utils/types.dart';
import '../dto/login_request_dto.dart';

abstract class AuthRemoteDS {
  FutureEither<UserModel> login(LoginRequestDto params);
}

@LazySingleton(as: AuthRemoteDS)
class AuthRemoteDsImpl implements AuthRemoteDS {

  @override
  FutureEither<UserModel> login(LoginRequestDto params) async {
    final response = await locator<ApiService>().request(
      url: Api.loginUrl,
      method: Method.post,
      requiredToken: false,
      body: params.toJson(),
    );

    return response.fold(
      (error) => Left(error),
      (response) => Right(UserModel.fromJson(response.data)),
    );
  }
}
