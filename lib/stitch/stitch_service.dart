import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/geo_exception.dart';
import 'package:geo_monitor/library/data/stitch/token_response.dart';
import 'package:geo_monitor/library/emojis.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

import '../library/data/stitch/payment_request.dart';
import '../library/functions.dart';

late StitchService stitchService;

class StitchService {
  static const url = 'https://secure.stitch.money/connect/token';
  static const audience = 'https://secure.stitch.money/connect/token';
  static const clientId = 'test-b0b553b7-0d97-4ba4-9c33-5a866b7eb59c';
  static const secret =
      'm5Vwl7/WNLkXKrZveS33nzn3t8cLHBZClHmmZHL+WgRRgfHgWyEsm5vFaToeSkKwnyeNeC9zXmKX7LTooGkFSg==';

  final mm = '🍐🍐🍐🍐🍐🍐🍐 StitchService: ✅';
  final http.Client httpClient;
  String getPay = """
  mutation CreatePaymentRequest(
    \$amount: MoneyInput!,
    \$payerReference: String!,
    \$beneficiaryReference: String!,
    \$externalReference: String,
    \$beneficiaryName: String!,
    \$beneficiaryBankId: BankBeneficiaryBankId!,
    \$beneficiaryAccountNumber: String!) {
  clientPaymentInitiationRequestCreate(input: {
      amount: \$amount,
      payerReference: \$payerReference,
      beneficiaryReference: \$beneficiaryReference,
      externalReference: \$externalReference,
      beneficiary: {
          bankAccount: {
              name: \$beneficiaryName,
              bankId: \$beneficiaryBankId,
              accountNumber: \$beneficiaryAccountNumber
          }
      }
    }) {
    paymentInitiationRequest {
      id
      url
    }
  }
}
  """;
  String mutation = '''
    mutation CreatePaymentRequest(
      \$amount: MoneyInput!,
      \$payerReference: String!,
      \$beneficiaryReference: String!,
      \$externalReference: String,
      \$beneficiaryName: String!,
      \$beneficiaryBankId: BankBeneficiaryBankId!,
      \$beneficiaryAccountNumber: String!
    ) {
      clientPaymentInitiationRequestCreate(input: {
        amount: \$amount,
        payerReference: \$payerReference,
        beneficiaryReference: \$beneficiaryReference,
        externalReference: \$externalReference,
        beneficiary: {
          bankAccount: {
            name: \$beneficiaryName,
            bankId: \$beneficiaryBankId,
            accountNumber: \$beneficiaryAccountNumber
          }
        }
      }) {
        paymentInitiationRequest {
          id
          url
        }
      }
    }
  ''';
  late GraphQLClient client;

  StitchService(this.httpClient);

  void main() {
    getToken();
  }

  Future<String> getToken() async {
    var mUrl = Uri.parse(url);
    pp('$mm getToken mUrl: $mUrl');
    final start = DateTime.now();
    try {
      var response = await httpClient.post(
        mUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'audience': audience,
          'scope': 'client_paymentrequest',
          'client_secret': secret,
        },
      );
      final end = DateTime.now();

      pp('$mm response statusCode: ${response.statusCode} body: ${response.body}');
      pp('$mm elapsed time: ${end.difference(start).inSeconds} seconds - ${end.difference(start).inMilliseconds} ms');

      if (response.statusCode == 200) {
        final bb = response.body;
        var token = jsonDecode(bb)['access_token'];
        var tr = TokenResponse.fromJson(jsonDecode(bb));
        pp('$mm Stitch ACCESS TOKEN via TokenResponse : 🍎${tr.toJson()} 🍎');
        pp('$mm Stitch ACCESS TOKEN via TokenResponse.accessToken : 🍎${tr.accessToken} 🍎');

        pp('$mm Stitch ACCESS TOKEN: 🍎$token 🍎');
        return token;
      } else {
        pp('${E.redDot} Request failed with status: ${response.statusCode}');
        var gex = GeoException(
            message: 'Stitch request for token failed',
            translationKey: 'tokenFailed',
            errorType: 'paymentError',
            url: url);
        errorHandler.handleError(exception: gex);
        throw gex;
      }
    } catch (e) {
      pp('${E.redDot} Request failed with: $e');
      var gex = GeoException(
          message: 'Stitch request for token failed',
          translationKey: 'tokenFailed',
          errorType: 'paymentError',
          url: url);
      errorHandler.handleError(exception: gex);
      throw gex;
    }
  }

  Future getTokenUsingDio() async {
    var dio = Dio();
    var url = 'https://secure.stitch.money/connect/token';

    try {
      var response = await dio.post(
        url,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
        data: {
          'grant_type': 'client_credentials',
          'client_id': 'test-b0b553b7-0d97-4ba4-9c33-5a866b7eb59c',
          'audience': 'https://secure.stitch.money/connect/token',
          'scope': 'client_paymentrequest',
          'client_secret':
              'm5Vwl7/WNLkXKrZveS33nzn3t8cLHBZClHmmZHL+WgRRgfHgWyEsm5vFaToeSkKwnyeNeC9zXmKX7LTooGkFSg==',
        },
      );

      if (response.statusCode == 200) {
        pp('$mm Stitch : ${response.data}');
        return response.data;
      } else {
        pp('$mm Request failed with status: ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        // Error with response received
        pp('$mm Request failed with status: ${e.response!.statusCode}');
        pp('$mm Error response: ${e.response!.data}');
      } else {
        // Error with the request
        pp('$mm Request failed with error: $e');
      }
    } catch (e) {
      pp('$mm Error: $e');
    }
  }



  ///
  /// The table below describes the different statuses an InstantPay request can have,
  /// with the initial status always being PaymentInitiationRequestPending:
  //
  /// Status	Description
  /// PaymentInitiationRequestCompleted	This is a final payment state.
  /// PaymentInitiationRequestPending	The user hasn't yet completed the payment initiation request, or they exited the Stitch dialog box before completing the bank selection process.
  /// PaymentInitiationRequestCancelled	The payment initiation request was manually cancelled by the client. More information on this can be found here.
  /// PaymentInitiationRequestExpired	The payment initiation request has expired while awaiting user interaction. More information on this can be found here.
/*
When creating a payment initiation request, please note that:
The payerReference field is restricted to a maximum of 12 characters.
The beneficiaryReference field is restricted to a maximum of 20 characters.
The beneficiaryName field is restricted to a maximum of 20 characters.
The externalReference field is restricted to a maximum of 4096 characters.
 */
  Future sendGraphQlPaymentRequest(
      GioPaymentRequest request, String token) async {
    pp('$mm sendGraphQlPaymentRequest; token: $token');
    await _initialize(token);
    var user = await prefsOGx.getUser();
    var payerRef = request.payerReference!
        .substring(0, min(request.payerReference!.length, 12));
    var beneficiaryReference = request.beneficiaryReference!
        .substring(0, min(request.beneficiaryReference!.length, 20));
    var beneficiaryName = request.beneficiaryName!
        .substring(0, min(request.beneficiaryName!.length, 20));

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: <String, dynamic>{
        'amount': request.amount!.toJson(), // Replace with the actual amount
        'payerReference': payerRef,
        'beneficiaryReference': beneficiaryReference,
        'externalReference': user!.organizationId,
        'beneficiaryName': beneficiaryName,
        'beneficiaryBankId': request.beneficiaryBankId,
        'beneficiaryAccountNumber': request.beneficiaryAccountNumber,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      pp('$mm ${E.redDot} GraphQL Error: ${result.exception}');
    } else {
      pp('$mm Payment Request ID: 🍎${result.data?['clientPaymentInitiationRequestCreate']['paymentInitiationRequest']['id']}');
      pp('$mm Payment Request URL: 🍎${result.data?['clientPaymentInitiationRequestCreate']['paymentInitiationRequest']['url']}');
      pp('$mm Payment Request data: 🔶${result.data} 🔶');
    }
    var id = result.data?['clientPaymentInitiationRequestCreate']['paymentInitiationRequest']['id'];
    var url = result.data?['clientPaymentInitiationRequestCreate']['paymentInitiationRequest']['url'];
    return {
      'id': id,
      'url': url,
    };
  }

  Future _initialize(String token) async {
    final HttpLink httpLink = HttpLink(
      'https://api.stitch.money/graphql',
      httpClient: httpClient,
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        return 'Bearer $token';
      },
    );

    final Link link = authLink.concat(httpLink);

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }
}
