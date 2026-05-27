// WHAT THIS FILE DOES:
// A generic wrapper for any data coming from a Repository or Service.
//
// KEY CONCEPTS IN THIS FILE:
// • Generics <T>: Allows this class to hold any type of data (User, Game, etc.).
// • Pattern Matching: Makes it easy for the UI to show either a success screen or an error banner.

import 'app_error.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}
