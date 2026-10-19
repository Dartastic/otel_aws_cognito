// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_cognito_suppression.dart';

const _tracerName = 'dartastic_otel_libs_aws_cognito';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class AwsCognitoResult {
  const AwsCognitoResult({
    this.region,
    this.surface,
    this.userPoolId,
    this.appClientId,
    this.identityPoolId,
    this.username,
    this.sub,
    this.authFlow,
    this.idpKind,
    this.challenge,
    this.mfaSetting,
    this.mfaMethod,
    this.idTokenLength,
    this.accessTokenLength,
    this.refreshTokenLength,
    this.expiresInSec,
    this.userStatus,
    this.identityId,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// AWS region.
  final String? region;

  /// `user_pool`, `identity_pool`, `hosted_ui`, `oauth`.
  final String? surface;

  final String? userPoolId;
  final String? appClientId;
  final String? identityPoolId;

  /// Caller username (preferred_username / email / phone / cognito user).
  final String? username;

  /// Cognito `sub` claim.
  final String? sub;

  /// `USER_SRP_AUTH`, `USER_PASSWORD_AUTH`, `CUSTOM_AUTH`,
  /// `REFRESH_TOKEN_AUTH`, `ADMIN_NO_SRP_AUTH`,
  /// `ADMIN_USER_PASSWORD_AUTH`.
  final String? authFlow;

  /// `cognito`, `google`, `facebook`, `apple`, `amazon`, `oidc`, `saml`.
  final String? idpKind;

  /// `SMS_MFA`, `SOFTWARE_TOKEN_MFA`, `EMAIL_OTP`, `SELECT_MFA_TYPE`,
  /// `MFA_SETUP`, `PASSWORD_VERIFIER`, `CUSTOM_CHALLENGE`,
  /// `DEVICE_SRP_AUTH`, `DEVICE_PASSWORD_VERIFIER`, `ADMIN_NO_SRP_AUTH`,
  /// `NEW_PASSWORD_REQUIRED`.
  final String? challenge;

  /// `ON`, `OPTIONAL`, `OFF`.
  final String? mfaSetting;

  /// `SMS`, `TOTP`, `EMAIL`.
  final String? mfaMethod;

  final int? idTokenLength;
  final int? accessTokenLength;
  final int? refreshTokenLength;
  final int? expiresInSec;

  /// `UNCONFIRMED`, `CONFIRMED`, `ARCHIVED`, `COMPROMISED`,
  /// `UNKNOWN`, `RESET_REQUIRED`, `FORCE_CHANGE_PASSWORD`,
  /// `EXTERNAL_PROVIDER`.
  final String? userStatus;

  /// Identity Pool identity id.
  final String? identityId;

  /// AWS error code (`NotAuthorizedException`, `UserNotConfirmedException`,
  /// `UserNotFoundException`, `UsernameExistsException`,
  /// `InvalidPasswordException`, `CodeMismatchException`,
  /// `ExpiredCodeException`, `PasswordResetRequiredException`,
  /// `LimitExceededException`, `TooManyRequestsException`,
  /// `TooManyFailedAttemptsException`, `UserLambdaValidationException`,
  /// `MFAMethodNotFoundException`, `SoftwareTokenMFANotFoundException`).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class AwsCognitoCallResult<T> {
  const AwsCognitoCallResult({required this.value, this.result});
  final T value;
  final AwsCognitoResult? result;
}

/// Wraps an AWS Cognito call in a CLIENT span. [operation] is one of
/// `signUp`, `confirmSignUp`, `resendConfirmationCode`, `initiateAuth`,
/// `respondToAuthChallenge`, `forgotPassword`, `confirmForgotPassword`,
/// `changePassword`, `globalSignOut`, `revokeToken`, `getUser`,
/// `updateUserAttributes`, `verifyUserAttribute`,
/// `getUserAttributeVerificationCode`, `deleteUser`,
/// `associateSoftwareToken`, `verifySoftwareToken`, `setUserMFAPreference`,
/// `setUserPoolMFAConfig`, `getDevice`, `forgetDevice`, `listDevices`,
/// `confirmDevice`, `adminCreateUser`, `adminDeleteUser`,
/// `adminGetUser`, `adminUpdateUserAttributes`, `adminAddUserToGroup`,
/// `adminRemoveUserFromGroup`, `adminInitiateAuth`,
/// `adminRespondToAuthChallenge`, `adminUserGlobalSignOut`,
/// `adminEnableUser`, `adminDisableUser`, `adminResetUserPassword`,
/// `adminSetUserPassword`, `adminListGroupsForUser`,
/// `adminLinkProviderForUser`, `adminDisableProviderForUser`,
/// `identityPool.getId`, `identityPool.getCredentialsForIdentity`,
/// `identityPool.getOpenIdToken`, `identityPool.getOpenIdTokenForDeveloperIdentity`.
Future<T> tracedAwsCognito<T>({
  required String operation,
  required Future<AwsCognitoCallResult<T>> Function() invoke,
}) async {
  if (awsCognitoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'aws_cognito',
    'rpc.method': operation,
    'aws_cognito.operation': operation,
  };

  final span = _tracer().startSpan(
    'aws_cognito $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.region != null) {
        extras.add(OTelAPI.attributeString('aws_cognito.region', res.region!));
      }
      if (res.surface != null) {
        extras
            .add(OTelAPI.attributeString('aws_cognito.surface', res.surface!));
      }
      if (res.userPoolId != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.user_pool.id',
          res.userPoolId!,
        ));
      }
      if (res.appClientId != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.app_client.id',
          res.appClientId!,
        ));
      }
      if (res.identityPoolId != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.identity_pool.id',
          res.identityPoolId!,
        ));
      }
      if (res.username != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.username',
          res.username!,
        ));
      }
      if (res.sub != null) {
        extras.add(OTelAPI.attributeString('aws_cognito.sub', res.sub!));
      }
      if (res.authFlow != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.auth_flow',
          res.authFlow!,
        ));
      }
      if (res.idpKind != null) {
        extras
            .add(OTelAPI.attributeString('aws_cognito.idp.kind', res.idpKind!));
      }
      if (res.challenge != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.challenge',
          res.challenge!,
        ));
      }
      if (res.mfaSetting != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.mfa.setting',
          res.mfaSetting!,
        ));
      }
      if (res.mfaMethod != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.mfa.method',
          res.mfaMethod!,
        ));
      }
      if (res.idTokenLength != null) {
        extras.add(OTelAPI.attributeInt(
          'aws_cognito.id_token.length',
          res.idTokenLength!,
        ));
      }
      if (res.accessTokenLength != null) {
        extras.add(OTelAPI.attributeInt(
          'aws_cognito.access_token.length',
          res.accessTokenLength!,
        ));
      }
      if (res.refreshTokenLength != null) {
        extras.add(OTelAPI.attributeInt(
          'aws_cognito.refresh_token.length',
          res.refreshTokenLength!,
        ));
      }
      if (res.expiresInSec != null) {
        extras.add(OTelAPI.attributeInt(
          'aws_cognito.expires_in_sec',
          res.expiresInSec!,
        ));
      }
      if (res.userStatus != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.user.status',
          res.userStatus!,
        ));
      }
      if (res.identityId != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.identity.id',
          res.identityId!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.error.code',
          res.errorCode!,
        ));
        // user-confirmable errors are non-error from infra perspective
        if (res.errorCode != 'UserNotConfirmedException' &&
            res.errorCode != 'PasswordResetRequiredException') {
          span.setStatus(SpanStatusCode.Error, 'Cognito ${res.errorCode}');
        }
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'aws_cognito.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 500) {
          span.setStatus(
            SpanStatusCode.Error,
            'Cognito HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
