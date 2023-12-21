# GOV.UK One Login

* Status: accepted

## Context and Problem Statement
The integration of GOV.UK One Login user authentication is a requirement of the service going live. This single sign on will allow users to login to the service using their GOV.UK One Login account.

## Decision Drivers
* GOV.UK One Login reccomends using an off-the-shelf OIDC library
* We currently use Devise for user authentication
* Omniauth would allow us to use Devise and integrate with GOV.UK One Login

## Considered Options
* [omniauth](https://github.com/omniauth/omniauth)
* [omniauth_openid_connect](https://github.com/omniauth/omniauth_openid_connect)

## Decision Outcome
Chosen option: [omniauth_openid_connect](https://github.com/omniauth/omniauth_openid_connect)

