//
//  Generated code. Do not modify.
//  source: chat/chat.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'chat.pb.dart' as $0;

export 'chat.pb.dart';

@$pb.GrpcServiceName('chat.ChatService')
class ChatServiceClient extends $grpc.Client {
  static final _$connect = $grpc.ClientMethod<$0.User, $0.Message>(
      '/chat.ChatService/Connect',
      ($0.User value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Message.fromBuffer(value));
  static final _$sendMessage = $grpc.ClientMethod<$0.Message, $0.Empty>(
      '/chat.ChatService/SendMessage',
      ($0.Message value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));

  ChatServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.Message> connect($0.User request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$connect, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$0.Empty> sendMessage($0.Message request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }
}

@$pb.GrpcServiceName('chat.ChatService')
abstract class ChatServiceBase extends $grpc.Service {
  $core.String get $name => 'chat.ChatService';

  ChatServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.User, $0.Message>(
        'Connect',
        connect_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.User.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Message, $0.Empty>(
        'SendMessage',
        sendMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Message.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Stream<$0.Message> connect_Pre($grpc.ServiceCall call, $async.Future<$0.User> request) async* {
    yield* connect(call, await request);
  }

  $async.Future<$0.Empty> sendMessage_Pre($grpc.ServiceCall call, $async.Future<$0.Message> request) async {
    return sendMessage(call, await request);
  }

  $async.Stream<$0.Message> connect($grpc.ServiceCall call, $0.User request);
  $async.Future<$0.Empty> sendMessage($grpc.ServiceCall call, $0.Message request);
}
