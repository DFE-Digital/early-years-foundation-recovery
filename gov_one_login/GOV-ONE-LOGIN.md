# GOV.UK One Login

## Integration Environment
- __Base URI__: https://oidc.integration.account.gov.uk
- __Redirect URLs__:
    - http://localhost:3000/users/auth/openid_connect/callback
- __Post-logout redirect URLs__:
    - http://localhost:3000/users/sign_out


## Technical Checklist

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
| __For the private_key_jwt confirm that each jti claim value in the JWT assertion is used once.__ | &check; |

### Token validation requirements 
| Requirement | Response |
| --- | --- |
| __Confirm you validate the iss claim is https://oidc.account.gov.uk/__ | &check; |
| __Confirm you validate the aud claim matches your client_id__ | &check; |
| __Confirm you validate the nonce claim matches the your application generated__ | &check; |
| __Confirm you validate the current time is before the time in the exp claim__  | &check; |
| __Confirm you validate the current time is between the time in the auth_time claim and the exp claim__ | &check; |
| __Confirm you validate the signature on the id-token__ | &check; |
| __Describe how you handle token endpoint errors__ | The error is logged and the user is redirected to the homepage with an alert informing them of a problem  |
| __Describe how you ensure that the GOV.UK One Login Access Token is not exposed to unauthorised parties outside of your trusted backend server__  | The access token is not exposed to the user and is only used to make requests to the UserInfo endpoint during the user session. Communication with GOV.UK One Login is over HTTPS. |

### UserInfo request requirements  
| Requirement | Response |
| --- | --- |
| __Confirm you validate the sub claim in the UserInfo response matches the id-token sub claim__  | &check; |
| __Describe how you handle UserInfo endpoint errors__ | The error is logged and the user is redirected to the homepage with an alert informing them of a problem |
| __If you’re using the email address scope, confirm that you’re aware this represents the GOV.UK One Login username and may not be the user’s preferred contact email address__ | &check; |

### Key management requirements 
| Requirement | Response |
| --- | --- |
| __If using the GOV.UK One Login OpenID Provider JWKS Endpoint for signature validation describe your approach to key rotation__ | The keys are cached and the cache expires every 24 hours |

### Session management requirements  
| Requirement | Response |
| --- | --- |
| __Confirm that you’ve implemented logout functionality and that your service calls the GOV.UK One Login logout endpoint__ | &check; |
