// import 'dart:io';

// import 'package:base/src/widgets/custom_dialog.dart';
// import 'package:http_interceptor/models/models.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart';
// import 'package:http_interceptor/extensions/extensions.dart';

// import 'error_interceptor.dart';

// /// Enum representation of all http methods.
// enum Method {
//   HEAD,
//   GET,
//   POST,
//   PUT,
//   PATCH,
//   DELETE,
// }

// /// Parses an string into a Method Enum value.
// Method methodFromString(String method) {
//   switch (method) {
//     case "HEAD":
//       return Method.HEAD;
//     case "GET":
//       return Method.GET;
//     case "POST":
//       return Method.POST;
//     case "PUT":
//       return Method.PUT;
//     case "PATCH":
//       return Method.PATCH;
//     case "DELETE":
//       return Method.DELETE;
//   }
//   throw ArgumentError.value(method, "method", "Must be a valid HTTP Method.");
// }

// // Parses a Method Enum value into a string.
// String methodToString(Method method) {
//   switch (method) {
//     case Method.HEAD:
//       return "HEAD";
//     case Method.GET:
//       return "GET";
//     case Method.POST:
//       return "POST";
//     case Method.PUT:
//       return "PUT";
//     case Method.PATCH:
//       return "PATCH";
//     case Method.DELETE:
//       return "DELETE";
//   }
// }

// abstract class InterceptorContract {
//   Future<RequestData> interceptRequest({required RequestData data});

//   Future<ResponseData> interceptResponse({required ResponseData data});
// }

// ///Class to be used by the user to set up a new `http.Client` with interceptor supported.
// ///call the `build()` constructor passing in the list of interceptors.
// ///Example:
// ///```dart
// /// InterceptedClient httpClient = InterceptedClient.build(interceptors: [
// ///     Logger(),
// /// ]);
// ///```
// ///
// ///Then call the functions you want to, on the created `httpClient` object.
// ///```dart
// /// httpClient.get(...);
// /// httpClient.post(...);
// /// httpClient.put(...);
// /// httpClient.delete(...);
// /// httpClient.head(...);
// /// httpClient.patch(...);
// /// httpClient.read(...);
// /// httpClient.readBytes(...);
// /// httpClient.close();
// ///```
// ///Don't forget to close the client once you are done, as a client keeps
// ///the connection alive with the server.
// ///
// ///Note: `send` method is not currently supported.
// ///
// const REQUEST_TIME_OUT = 3;

// class CustomInterceptedClient extends BaseClient {
//   List<InterceptorContract> interceptors;
//   Duration? requestTimeout;
//   RetryPolicy? retryPolicy;
//   String Function(Uri)? findProxy;
//   Function(Exception error)? onError;

//   int _retryCount = 0;
//   late Client _inner;

//   CustomInterceptedClient._internal({
//     required this.interceptors,
//     this.requestTimeout,
//     this.retryPolicy,
//     this.findProxy,
//     Client? client,
//     this.onError,
//   }) : _inner = client ?? Client();

//   factory CustomInterceptedClient.build({
//     required List<InterceptorContract> interceptors,
//     Duration requestTimeout = const Duration(seconds: REQUEST_TIME_OUT),
//     RetryPolicy? retryPolicy,
//     String Function(Uri)? findProxy,
//     Client? client,
//   }) =>
//       CustomInterceptedClient._internal(
//         interceptors: interceptors,
//         requestTimeout: requestTimeout,
//         retryPolicy: retryPolicy,
//         findProxy: findProxy,
//         client: client,
//       );

//   @override
//   Future<Response> head(
//     Uri url, {
//     Map<String, String>? headers,
//   }) =>
//       _sendUnstreamed(
//         method: Method.HEAD,
//         url: url,
//         headers: headers,
//       );
//   @override
//   Future<Response> get(
//     Uri url, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//   }) =>
//       _sendUnstreamed(
//         method: Method.GET,
//         url: url,
//         headers: headers,
//         params: params,
//       );

//   @override
//   Future<Response> post(
//     Uri url, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//     Object? body,
//     Encoding? encoding,
//   }) =>
//       _sendUnstreamed(
//         method: Method.POST,
//         url: url,
//         headers: headers,
//         params: params,
//         body: body,
//         encoding: encoding,
//       );

//   @override
//   Future<Response> put(
//     Uri url, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//     Object? body,
//     Encoding? encoding,
//   }) =>
//       _sendUnstreamed(
//         method: Method.PUT,
//         url: url,
//         headers: headers,
//         params: params,
//         body: body,
//         encoding: encoding,
//       );

//   @override
//   Future<Response> patch(
//     Uri url, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//     Object? body,
//     Encoding? encoding,
//   }) =>
//       _sendUnstreamed(
//         method: Method.PATCH,
//         url: url,
//         headers: headers,
//         params: params,
//         body: body,
//         encoding: encoding,
//       );

//   @override
//   Future<Response> delete(
//     Uri url, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//     Object? body,
//     Encoding? encoding,
//   }) =>
//       _sendUnstreamed(
//         method: Method.DELETE,
//         url: url,
//         headers: headers,
//         params: params,
//         body: body,
//         encoding: encoding,
//       );

//   @override
//   Future<String> read(
//     Uri url, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//   }) {
//     return get(url, headers: headers, params: params).then((response) {
//       _checkResponseSuccess(url, response);
//       return response.body;
//     });
//   }

//   @override
//   Future<Uint8List> readBytes(
//     Uri url, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//   }) {
//     return get(url, headers: headers, params: params).then((response) {
//       _checkResponseSuccess(url, response);
//       return response.bodyBytes;
//     });
//   }

//   @override
//   Future<StreamedResponse> send(BaseRequest request) {
//     return _inner.send(request);
//   }

//   Future<Response> _sendUnstreamed({
//     required Method method,
//     required Uri url,
//     Map<String, String>? headers,
//     Map<String, dynamic>? params,
//     Object? body,
//     Encoding? encoding,
//   }) async {
//     url = url.addParameters(params);

//     Request request = Request(methodToString(method), url);
//     if (headers != null) request.headers.addAll(headers);
//     if (encoding != null) request.encoding = encoding;
//     if (body != null) {
//       if (body is String) {
//         request.body = body;
//       } else if (body is List) {
//         request.bodyBytes = body.cast<int>();
//       } else if (body is Map) {
//         request.bodyFields = body.cast<String, String>();
//       } else {
//         throw ArgumentError('Invalid request body "$body".');
//       }
//     }

//     var response = await _attemptRequest(request);

//     // Intercept response
//     response = await _interceptResponse(response);

//     return response;
//   }

//   void _checkResponseSuccess(Uri url, Response response) {
//     if (response.statusCode < 400) return;
//     var message = "Request to $url failed with status ${response.statusCode}";
//     if (response.reasonPhrase != null) {
//       message = "$message: ${response.reasonPhrase}";
//     }
//     throw ClientException("$message.", url);
//   }

//   /// Attempts to perform the request and intercept the data
//   /// of the response
//   Future<Response> _attemptRequest(Request request) async {
//     Response response;
//     try {
//       // Intercept request
//       final interceptedRequest = await _interceptRequest(request);

//       var stream = requestTimeout == null
//           ? await send(interceptedRequest)
//           : await send(interceptedRequest).timeout(requestTimeout!);

//       response = await Response.fromStream(stream);
//       if (retryPolicy != null &&
//           retryPolicy!.maxRetryAttempts > _retryCount &&
//           await retryPolicy!.shouldAttemptRetryOnResponse(
//               ResponseData.fromHttpResponse(response))) {
//         _retryCount += 1;
//         return _attemptRequest(request);
//       }
//     } on Exception catch (error) {
//       if (retryPolicy != null &&
//           retryPolicy!.maxRetryAttempts > _retryCount &&
//           retryPolicy!.shouldAttemptRetryOnException(error)) {
//         _retryCount += 1;
//         return _attemptRequest(request);
//       } else {
//         AppLoading.closeLoading();
//         if (onError != null) {
//           onError!(error);
//         } else {
//           _onError(error);
//         }
//         rethrow;
//       }
//     }

//     _retryCount = 0;
//     return response;
//   }

//   /// This internal function intercepts the request.
//   Future<Request> _interceptRequest(Request request) async {
//     for (InterceptorContract interceptor in interceptors) {
//       RequestData interceptedData = await interceptor.interceptRequest(
//         data: RequestData.fromHttpRequest(request),
//       );
//       request = interceptedData.toHttpRequest();
//     }

//     return request;
//   }

//   /// This internal function intercepts the response.
//   Future<Response> _interceptResponse(Response response) async {
//     for (InterceptorContract interceptor in interceptors) {
//       ResponseData responseData = await interceptor.interceptResponse(
//         data: ResponseData.fromHttpResponse(response),
//       );
//       response = responseData.toHttpResponse();
//     }

//     return response;
//   }

//   void _onError(Exception error) {
//     if (error is SocketException) {
//       HandleException.onSocket();
//       return;
//     } else if (error is TimeoutException) {
//       HandleException.onTimeout();
//       return;
//     } else if (error is HttpException) {
//       HandleException.onHttp();
//       return;
//     } else {
//       HandleException.onUnhandled();
//       return;
//     }
//   }

//   @override
//   void close() {
//     _inner.close();
//   }
// }
