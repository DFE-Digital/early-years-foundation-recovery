# Use Active Record Encryption to protect sensitive data

* Status: accepted

## Context and Problem Statement

How might we protect sensitive data such as personally identifiable information (PII) being captured in components such as free text boxes? 

## Decision Drivers

* Protects against visibility of PII in database
* Sufficient level of security
* Out-of-the-box solution

## Considered Options

* Active Record Encryption (Ruby on Rails)
* pgcrypto (Postgres)

## Decision Outcome

Chosen option: The Ruby on Rails based [Active Record Encryption](https://guides.rubyonrails.org/active_record_encryption.html) feature is the preferred option. The benefit of data encryption at application level is that it adds an additional layer of security. This is by guarding against sensitive information being leaked in application logs, in addition to the database.  
