import 'package:flutter/cupertino.dart';

enum ErrorType {
  SUCCESS,
  INVALID_INPUT,
  PERMISSION_DENIED,
  SERVER_ERROR,
}

extension ErrorTypeExtension on ErrorType {
  String name() {
    switch (this) {
      case ErrorType.SUCCESS:
        return "SUCCESS";
      case ErrorType.INVALID_INPUT:
        return "INVALID_INPUT";
      case ErrorType.PERMISSION_DENIED:
        return "PERMISSION_DENIED";
      case ErrorType.SERVER_ERROR:
        return "SERVER_ERROR";
    }
    return '';
  }
}

class ErrorCode {
  ErrorType errorType;
  String message = '';

  ErrorCode({@required int errorType, this.message}) {
    this.errorType = int2errorType[errorType];
  }

  static final int2errorType = {
    0: ErrorType.SUCCESS,
    1: ErrorType.INVALID_INPUT,
    2: ErrorType.PERMISSION_DENIED,
    3: ErrorType.SERVER_ERROR,
  };

  bool isSuccess() {
    return errorType == ErrorType.SUCCESS;
  }

  @override
  String toString() {
    return '${errorType.name()}: $message';
  }
}
