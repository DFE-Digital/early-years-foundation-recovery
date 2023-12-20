# GOV.UK One Login

## ADR
### Context
The integration of GOV.UK One Login user authentication is a requirement of the service going live. This single sign on will allow users to login to the service using their GOV.UK One Login account.

### Decision
We have decided to use the `omniauth_openid_connect` gem. This decision was based on the fact that `omniauth_openid_connect` is an off-the-shelf OIDC library as was recommended by GOV.UK One Login, it integrates well with Devise (which we are already using for user authentication) and it has a good level of community support. Auth URIs and client secrets are stored in Rails credentials files which is a secure way of storing sensitive information and allows us to use different credentials for different environments.

### Consequences
By using the `omniauth_openid_connect` gem we have been able to implement the GOV.UK One Login user authentication in a way that is consistent with the rest of the application and has allowed us to use the existing Devise functionality that we have already implemented for user authentication. 


## Checklist

### Authentication request requirements
| Requirement | Response |
| --- | --- |
| __Describe how you’re using the state parameter to prevent CSRF attacks__ | The state is generated as a random uuid, which is then stored in the Rails session storage. The state parameter for authorisation request responses must match the state stored in the session before the user is authenticated. 
| __Describe how you’re generating the nonce parameter__ | The nonce is a randomly generated alphanumeric string of 25 characters, it is used to verify the `id_token`. |
| __Describe how you handle authorise endpoint errors__  | The errors are logged and the user is redirected to the homepage with an alert informing them of a problem  |
| __Describe how you’re handling access_denied errors where session state is also missing__ | The user is redirected to the homepage with an alert informing them of a problem and encouraging them to try again |

### Token request requirements 
| Requirement | Response |
| --- | --- |
| __Describe how you ensure that your client secret / private key is not exposed to unauthorised parties__ | These are encrypted and stored in Rails credentials |
| __For the private_key_jwt confirm that each jti claim value in the JWT assertion is used once.__ | <input type="checkbox" checked> |

### Token validation requirements 
| Requirement | Response |
| --- | --- |
| __Confirm you validate the iss claim is https://oidc.account.gov.uk/__ | <input type="checkbox" checked> |
| __Confirm you validate the aud claim matches your client_id__ | <input type="checkbox" checked> |
| __Confirm you validate the nonce claim matches the your application generated__ | <input type="checkbox" checked> |
| __Confirm you validate the current time is before the time in the exp claim__  | <input type="checkbox" checked> |
| __Confirm you validate the current time is between the time in the auth_time claim and the exp claim__ | <input type="checkbox" checked> |
| __Confirm you validate the signature on the id-token__ | <input type="checkbox" checked> |
| __Describe how you handle token endpoint errors__ | The error is logged and the user is redirected to the homepage with an alert informing them of a problem  |
| __Describe how you ensure that the GOV.UK One Login Access Token is not exposed to unauthorised parties outside of your trusted backend server__  | The access token is not exposed to the user and is only used to make requests to the UserInfo endpoint during the user session. Communication with GOV.UK One Login is over HTTPS. |

### UserInfo request requirements  
| Requirement | Response |
| --- | --- |
| __Confirm you validate the sub claim in the UserInfo response matches the id-token sub claim__  | <input type="checkbox" checked> |
| __Describe how you handle UserInfo endpoint errors__ | The error is logged and the user is redirected to the homepage with an alert informing them of a problem |
| __If you’re using the email address scope, confirm that you’re aware this represents the GOV.UK One Login username and may not be the user’s preferred contact email address__ | <input type="checkbox" checked> |

### Key management requirements 
| Requirement | Response |
| --- | --- |
| __If using the GOV.UK One Login OpenID Provider JWKS Endpoint for signature validation describe your approach to key rotation__ | The keys are cached and the cache expires every 24 hours |

### Session management requirements  
| Requirement | Response |
| --- | --- |
| __Confirm that you’ve implemented logout functionality and that your service calls the GOV.UK One Login logout endpoint__ | <input type="checkbox" checked> |
