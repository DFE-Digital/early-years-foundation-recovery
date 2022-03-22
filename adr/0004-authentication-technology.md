# Use Devise for authentication

* Status: accepted

## Context and Problem Statement

How might we authenticate users?

## Decision Drivers <!-- optional -->

* The authentication system must be secure
* The system must integrate with Gov.uk Notify which is to be used for email second factor if a built in 2FA system not already included.
* The system must be easy to update
* The system/technology must have an active community/vendor to resolve new security issues as swiftly as possible.

## Considered Options

* DfE Sign-In
* Gov.UK Sign-In
* Social Media Identity Provider integration
* Basic OAuth using 'Devise'

## Decision Outcome

Chosen option: Basic OAuth using the Ruby Gem 'Devise'. 

* DfE Sign-In requires an educational establishment to be associated with the user, which is unlikely to be the case. 
* Gov.UK Sign-in is not yet available to use (but would be an ideal long term solution in 2023). 
* Social Media identity providers has not tested well. Users concerned as to why the system would require a link to the user's social media. Also, while potentially more secure than some methods by using Authentication OTP applications, we would not like to force users to create social media accounts if at all possible. 
* Basic OAuth using 'Devise' is a well supported, often used technology which can be easily integrated with Gov.uk Notify, extended to include other identity providers in the future, e.g. Gov.uk Sign-in and is well maintained. 
