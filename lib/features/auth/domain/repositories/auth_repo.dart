import 'package:socials_app/core/models/user_model.dart';
import 'package:socials_app/features/auth/data/dto/login_request_dto.dart';

import '../../../../core/utils/types.dart';

abstract class AuthRepo {
  FutureEither<UserModel> login(LoginRequestDto params);
}
