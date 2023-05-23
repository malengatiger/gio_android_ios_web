class TokenResponse {
  TokenResponse({
    this.accessToken,
    this.expiresIn,
    this.tokenType,
    this.scope,
  });

  TokenResponse.fromJson(dynamic json) {
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    tokenType = json['token_type'];
    scope = json['scope'];
  }
  String? accessToken;
  int? expiresIn;
  String? tokenType;
  String? scope;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['access_token'] = accessToken;
    map['expires_in'] = expiresIn;
    map['token_type'] = tokenType;
    map['scope'] = scope;
    return map;
  }
}
