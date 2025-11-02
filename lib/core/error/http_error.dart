import './base_error.dart';

class HttpError extends BaseError {
  @override
  String toString() {
    return 'Something went wrong, Please try again in a minute';
  }

  @override
  List<Object> get props => [];
}
