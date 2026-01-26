# GOV.UK One Login

- [Service page](https://www.sign-in.service.gov.uk)
- [Status updates](https://status.account.gov.uk)
- [Admin tool](https://admin.sign-in.service.gov.uk/sign-in)
- [Prototype]()

## Integration Environment

- **Base URI**: https://oidc.integration.account.gov.uk
- **Redirect URLs**:
  - http://localhost:3000/users/auth/openid_connect/callback
- **Post-logout redirect URLs**:
  - http://localhost:3000/users/sign_out

## Technical Checklist

### Authentication request requirements

| Requirement                                                                               | Response                                                                                                                                                                                                                         |
| ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Describe how you’re using the state parameter to prevent CSRF attacks**                 | The state is generated as a random uuid, which is then stored in the Rails session storage. The state parameter for authorisation request responses must match the state stored in the session before the user is authenticated. |
| **Describe how you’re generating the nonce parameter**                                    | The nonce is a randomly generated alphanumeric string of 25 characters, it is used to verify the `id_token`.                                                                                                                     |
| **Describe how you handle authorise endpoint errors**                                     | The errors are logged and the user is redirected to the homepage with an alert informing them of a problem                                                                                                                       |
| **Describe how you’re handling access_denied errors where session state is also missing** | The user is redirected to the homepage with an alert informing them of a problem and encouraging them to try again                                                                                                               |

### Token request requirements

| Requirement                                                                                              | Response                                            |
| -------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| **Describe how you ensure that your client secret / private key is not exposed to unauthorised parties** | These are encrypted and stored in Rails credentials |
| **For the private_key_jwt confirm that each jti claim value in the JWT assertion is used once.**         | &check;                                             |

### Token validation requirements

| Requirement                                                                                                                                      | Response                                                                                                                                                                           |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Confirm you validate the iss claim is https://oidc.account.gov.uk/**                                                                           | &check;                                                                                                                                                                            |
| **Confirm you validate the aud claim matches your client_id**                                                                                    | &check;                                                                                                                                                                            |
| **Confirm you validate the nonce claim matches the your application generated**                                                                  | &check;                                                                                                                                                                            |
| **Confirm you validate the current time is before the time in the exp claim**                                                                    | &check;                                                                                                                                                                            |
| **Confirm you validate the current time is between the time in the auth_time claim and the exp claim**                                           | &check;                                                                                                                                                                            |
| **Confirm you validate the signature on the id-token**                                                                                           | &check;                                                                                                                                                                            |
| **Describe how you handle token endpoint errors**                                                                                                | The error is logged and the user is redirected to the homepage with an alert informing them of a problem                                                                           |
| **Describe how you ensure that the GOV.UK One Login Access Token is not exposed to unauthorised parties outside of your trusted backend server** | The access token is not exposed to the user and is only used to make requests to the UserInfo endpoint during the user session. Communication with GOV.UK One Login is over HTTPS. |

### UserInfo request requirements

| Requirement                                                                                                                                                                    | Response                                                                                                 |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| **Confirm you validate the sub claim in the UserInfo response matches the id-token sub claim**                                                                                 | &check;                                                                                                  |
| **Describe how you handle UserInfo endpoint errors**                                                                                                                           | The error is logged and the user is redirected to the homepage with an alert informing them of a problem |
| **If you’re using the email address scope, confirm that you’re aware this represents the GOV.UK One Login username and may not be the user’s preferred contact email address** | &check;                                                                                                  |

### Key management requirements

| Requirement                                                                                                                     | Response                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **If using the GOV.UK One Login OpenID Provider JWKS Endpoint for signature validation describe your approach to key rotation** | The JWKS is cached with expiry set from the JWKS endpoint's Cache-Control: max-age header. If a JWT is received with a kid not present in the cached JWKS, the cache is cleared, JWKS is refetched, and verification is retried once. If JWKS cannot be refreshed (e.g., network error), the cached keys are used until a refresh is possible. The JWKS URI is dynamically obtained from the OpenID discovery endpoint. All JWKS refreshes, cache misses, and failures are logged. |

### Session management requirements

| Requirement                                                                                                               | Response |
| ------------------------------------------------------------------------------------------------------------------------- | -------- |
| **Confirm that you’ve implemented logout functionality and that your service calls the GOV.UK One Login logout endpoint** | &check;  |
