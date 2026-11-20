sealed class SyncFailure implements Exception {
  const SyncFailure();

  bool get isRetryable => switch (this) {
    NoConnection() || QueryError() => false,
    RequestTimeout() ||
    RateLimited() ||
    ServerError() ||
    PartialResponse() ||
    InvalidResponse() ||
    CallBudgetExhausted() => true,
  };
}

final class NoConnection extends SyncFailure {
  const NoConnection();

  @override
  String toString() => 'NoConnection';
}

final class RequestTimeout extends SyncFailure {
  const RequestTimeout();

  @override
  String toString() => 'RequestTimeout';
}

final class RateLimited extends SyncFailure {
  const RateLimited({this.retryAfter});

  final Duration? retryAfter;

  @override
  bool operator ==(Object other) =>
      other is RateLimited && other.retryAfter == retryAfter;

  @override
  int get hashCode => Object.hash(RateLimited, retryAfter);

  @override
  String toString() => 'RateLimited(retryAfter: $retryAfter)';
}

final class ServerError extends SyncFailure {
  const ServerError(this.statusCode);

  final int statusCode;

  @override
  bool operator ==(Object other) =>
      other is ServerError && other.statusCode == statusCode;

  @override
  int get hashCode => Object.hash(ServerError, statusCode);

  @override
  String toString() => 'ServerError($statusCode)';
}

final class PartialResponse extends SyncFailure {
  const PartialResponse();

  @override
  String toString() => 'PartialResponse';
}

final class QueryError extends SyncFailure {
  const QueryError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is QueryError && other.message == message;

  @override
  int get hashCode => Object.hash(QueryError, message);

  @override
  String toString() => 'QueryError($message)';
}

final class InvalidResponse extends SyncFailure {
  const InvalidResponse();

  @override
  String toString() => 'InvalidResponse';
}

final class CallBudgetExhausted extends SyncFailure {
  const CallBudgetExhausted(this.until);

  final DateTime until;

  @override
  bool operator ==(Object other) =>
      other is CallBudgetExhausted && other.until == until;

  @override
  int get hashCode => Object.hash(CallBudgetExhausted, until);

  @override
  String toString() => 'CallBudgetExhausted(until: $until)';
}
