bring http;

bring "./url.w" as url;

pub interface OAuth2Provider {
  inflight getAccessToken(code: str): str;
  inflight getUser(accessToken: str): Json;
}

pub struct OAuth2ProviderOptions {
  clientId: str;
  clientSecret: str;
  redirectUri: str;
}

inflight class BaseProvider {
  options: OAuth2ProviderOptions;

  new(options: OAuth2ProviderOptions) {
    this.options = options;
  }

  pub inflight getToken(url_: str, code: str): str {
    let params = {
      client_id: this.options.clientId,
      client_secret: this.options.clientSecret,
      redirect_uri: this.options.redirectUri,
      code: code,
    };

    log("getToken: params={params}");

    let response = http.post(
      url_,
      body: url.Url.urlSearchParams(params).toString(),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    log("getToken: response.body={response.body}");

    if !response.ok {
      throw "Login failed";
    }

    return response.body;
  }
}

pub inflight class Github extends BaseProvider impl OAuth2Provider {
  new(options: OAuth2ProviderOptions) {
    super(options);
  }

  pub inflight getAccessToken(code: str): str {
    let token = this.getToken("https://github.com/login/oauth/access_token", code);

    let bodyParams = url.Url.urlSearchParams(unsafeCast(token));

    log("getAccessToken: bodyParams={token}");

    return bodyParams.get("access_token");
  }

  pub inflight getUser(accessToken: str): Json {
    let response = http.get(
      "https://api.github.com/user",
      headers: {
        Authorization: "Bearer {accessToken}",
      },
    );

    log("getUser: response.body={response.body}");

    if !response.ok {
      throw "Get user info failed";
    }

    return Json.parse(response.body);
  }
}

pub inflight class Meta extends BaseProvider impl OAuth2Provider {
  new(options: OAuth2ProviderOptions) {
    super(options);
  }

  pub inflight getAccessToken(code: str): str {
    let token = this.getToken("https://graph.facebook.com/v18.0/oauth/access_token", code);

    let bodyParams = Json.parse(token);

    log("getAccessToken: bodyParams={token}");

    return bodyParams.get("access_token").asStr();
  }

  pub inflight getUser(accessToken: str): Json {
    let params = url.Url.urlSearchParams({
      "access_token": accessToken,
    });

    let response = http.get(
      "https://graph.facebook.com/me?" + params.toString(),
    );

    log("getUser: response.body={response.body}");

    if !response.ok {
      throw "Get user info failed";
    }

    return Json.parse(response.body);
  }
}
