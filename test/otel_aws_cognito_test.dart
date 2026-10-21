// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_aws_cognito/otel_aws_cognito.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_aws_cognito-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('initiateAuth records pool + auth flow + challenge', () async {
    await tracedAwsCognito<String>(
      operation: 'initiateAuth',
      invoke: () async => const AwsCognitoCallResult(
        value: 'ok',
        result: AwsCognitoResult(
          region: 'us-east-1',
          surface: 'user_pool',
          userPoolId: 'us-east-1_abc',
          appClientId: 'abc123',
          authFlow: 'USER_SRP_AUTH',
          challenge: 'SOFTWARE_TOKEN_MFA',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('aws_cognito initiateAuth')!);
    expect(a['aws_cognito.auth_flow'], 'USER_SRP_AUTH');
    expect(a['aws_cognito.challenge'], 'SOFTWARE_TOKEN_MFA');
  });

  test('NotAuthorizedException sets span error', () async {
    await tracedAwsCognito<String>(
      operation: 'initiateAuth',
      invoke: () async => const AwsCognitoCallResult(
        value: 'ok',
        result: AwsCognitoResult(errorCode: 'NotAuthorizedException'),
      ),
    );
    expect(
      spans.findSpanByName('aws_cognito initiateAuth')!.status,
      SpanStatusCode.Error,
    );
  });

  test('UserNotConfirmedException does NOT set span error', () async {
    await tracedAwsCognito<String>(
      operation: 'initiateAuth',
      invoke: () async => const AwsCognitoCallResult(
        value: 'ok',
        result: AwsCognitoResult(errorCode: 'UserNotConfirmedException'),
      ),
    );
    expect(
      spans.findSpanByName('aws_cognito initiateAuth')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('identity pool flow records identity id', () async {
    await tracedAwsCognito<String>(
      operation: 'identityPool.getCredentialsForIdentity',
      invoke: () async => const AwsCognitoCallResult(
        value: 'ok',
        result: AwsCognitoResult(
          surface: 'identity_pool',
          identityPoolId: 'us-east-1:abc-def',
          identityId: 'us-east-1:i-1',
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName(
          'aws_cognito identityPool.getCredentialsForIdentity')!,
    );
    expect(a['aws_cognito.identity.id'], 'us-east-1:i-1');
  });

  test('suppression skips spans', () async {
    await runWithoutAwsCognitoInstrumentationAsync(() async {
      await tracedAwsCognito<String>(
        operation: 'getUser',
        invoke: () async => const AwsCognitoCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('aws_cognito '), isEmpty);
  });
}
