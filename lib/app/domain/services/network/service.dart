import 'dart:async';

import '/app/domain/models/network_request.dart';
import '/app/domain/models/network_response.dart';

export '/app/domain/models/network_request.dart';
export '/app/domain/models/network_response.dart';

abstract interface class NetworkService {
  void addInterceptor(NetworkRequestInterceptor interceptor);

  void removeInterceptor(NetworkRequestInterceptor interceptor);

  Future<NetworkResponseData> request(NetworkRequestData data);
}

abstract class NetworkRequestInterceptor {
  const NetworkRequestInterceptor();

  FutureOr<NetworkRequestData> onRequest(NetworkRequestData data) => data;

  FutureOr<NetworkResponseData> onResponse(NetworkResponseData data) => data;
}
