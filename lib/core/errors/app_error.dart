// WHAT THIS FILE DOES:
// A sealed class hierarchy that defines every possible thing that can go wrong.
//
// KEY CONCEPTS IN THIS FILE:
// • Sealed Classes: A special type of class that allows for "Exhaustive Switching" (the compiler warns you if you forget an error type).
// • Subtyping: Specific errors (Network, Auth) inherit from the base AppError.

sealed class AppError {
  final String message;
  const AppError(this.message);
}

class NetworkError extends AppError {
  const NetworkError([super.message = "Check your internet connection."]);
}

class AuthError extends AppError {
  const AuthError([super.message = "Authentication failed."]);
}

class DatabaseError extends AppError {
  const DatabaseError([super.message = "Could not save your data."]);
}

class TimeoutError extends AppError {
  const TimeoutError([super.message = "The server took too long to respond."]);
}

class UnknownError extends AppError {
  const UnknownError([super.message = "Something went wrong."]);
}
