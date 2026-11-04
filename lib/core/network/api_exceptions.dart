// lib/core/network/api_exceptions.dart

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Check your internet connection and try again'])
      : super(statusCode: null);
}

class TimeoutException extends ApiException {
  TimeoutException([super.message = 'The request timed out. Please try again'])
      : super(statusCode: 408);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Session expired. Please log in again'])
      : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException([super.message = 'Access denied'])
      : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Resource not found'])
      : super(statusCode: 404);
}

class ConflictException extends ApiException {
  ConflictException([super.message = 'An account with these details already exists'])
      : super(statusCode: 409);
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.details})
      : super(statusCode: 422);
}
