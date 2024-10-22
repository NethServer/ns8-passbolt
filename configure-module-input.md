# configure-module input Schema

```txt
http://schema.nethserver.org/passbolt/configure-module-input.json
```

Configure passbolt

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [configure-module-input.json](passbolt/configure-module-input.json "open original schema") |

## configure-module input Type

`object` ([configure-module input](configure-module-input.md))

## configure-module input Examples

```json
{
  "host": "passbolt.gs.nethserver.net",
  "lets_encrypt": true
}
```

# configure-module input Properties

| Property                       | Type      | Required | Nullable       | Defined by                                                                                                                                                                           |
| :----------------------------- | :-------- | :------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [host](#host)                  | `string`  | Required | cannot be null | [configure-module input](configure-module-input-properties-host.md "http://schema.nethserver.org/passbolt/configure-module-input.json#/properties/host")                             |
| [lets\_encrypt](#lets_encrypt) | `boolean` | Required | cannot be null | [configure-module input](configure-module-input-properties-lets-encrypt-certificate.md "http://schema.nethserver.org/passbolt/configure-module-input.json#/properties/lets_encrypt") |

## host

Host name for Passbolt, like 'passbolt.nethserver.org'

`host`

* is required

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-host.md "http://schema.nethserver.org/passbolt/configure-module-input.json#/properties/host")

### host Type

`string`

### host Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:&#x20;

```regexp
\.
```

[try pattern](https://regexr.com/?expression=%5C. "try regular expression with regexr.com")

**hostname**: the string must be a hostname, according to [RFC 1123, section 2.1](https://tools.ietf.org/html/rfc1123 "check the specification")

## lets\_encrypt

Request a valid Let's Encrypt certificate.

`lets_encrypt`

* is required

* Type: `boolean` ([Let's Encrypt certificate](configure-module-input-properties-lets-encrypt-certificate.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-lets-encrypt-certificate.md "http://schema.nethserver.org/passbolt/configure-module-input.json#/properties/lets_encrypt")

### lets\_encrypt Type

`boolean` ([Let's Encrypt certificate](configure-module-input-properties-lets-encrypt-certificate.md))
