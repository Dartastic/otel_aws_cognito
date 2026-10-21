// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_cognito/otel_aws_cognito.dart';

/// Traces AWS Cognito calls with OpenTelemetry.
///
/// `otel_aws_cognito` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each AWS Cognito call in
/// [tracedAwsCognito]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-cognito-example');

  // Wraps an AWS Cognito call in a CLIENT span.
  final awsCognitoId = await tracedAwsCognito<String>(
    operation: 'create',
    invoke: () async {
      // Make the AWS Cognito call here, then report what it returned.
      const id = 'aws_cognito_8f3a2c';
      return const AwsCognitoCallResult(
          value: id,
          result: AwsCognitoResult(
              region: 'us-east-1',
              surface: 'user_pool',
              userPoolId: 'userpool_8f3a2c',
              appClientId: 'appclient_8f3a2c',
              identityPoolId: 'identitypool_8f3a2c',
              username: 'example',
              sub: 'example',
              authFlow: 'USER_SRP_AUTH',
              idpKind: 'cognito',
              challenge: 'SMS_MFA',
              mfaSetting: 'ON',
              mfaMethod: 'SMS',
              idTokenLength: 128,
              accessTokenLength: 128,
              refreshTokenLength: 128,
              expiresInSec: 1,
              userStatus: 'UNCONFIRMED',
              identityId: 'identity_8f3a2c',
              errorCode: 'NotAuthorizedException',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedAwsCognito create returned $awsCognitoId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsCognitoInstrumentationAsync.
  await runWithoutAwsCognitoInstrumentationAsync(
    () => tracedAwsCognito<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_cognito_8f3a2c';
        return const AwsCognitoCallResult(
            value: id,
            result: AwsCognitoResult(
                region: 'us-east-1',
                surface: 'user_pool',
                userPoolId: 'userpool_8f3a2c',
                appClientId: 'appclient_8f3a2c',
                identityPoolId: 'identitypool_8f3a2c',
                username: 'example',
                sub: 'example',
                authFlow: 'USER_SRP_AUTH',
                idpKind: 'cognito',
                challenge: 'SMS_MFA',
                mfaSetting: 'ON',
                mfaMethod: 'SMS',
                idTokenLength: 128,
                accessTokenLength: 128,
                refreshTokenLength: 128,
                expiresInSec: 1,
                userStatus: 'UNCONFIRMED',
                identityId: 'identity_8f3a2c',
                errorCode: 'NotAuthorizedException',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
