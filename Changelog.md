Version 0.5.0 - released 2017-01-15
-------------

- Remove deprecated functions using individual authentication params.
- Bugfix: Add special handling for integer keys to views to fix #40

Version 0.4.4 - released 2017-01-08
-------------

- Improved authentication handling: You can now add basic auth credentials to db properties, eliminating need to authenticate each function call. Thanks to @leifg
- This change makes a number of authenticated functions redundant. These functions have been deprecated and will be removed in release version 0.5

Version 0.4.3 - released 2016-12-21
-------------

- Add Map based view API and documentation
- Complement some missing specs and test cases
- Fix typo in View related deprecation message
- Add function to create database secured through basic auth. Thanks to @leifg

Version 0.4.2 - released 2016-12-04
-------------

- Add Map based update API and documentation
- Add delegates to Writer module destroy functions in top level Connector module
- Document destroy functions

Version 0.4.1 - released 2016-11-20
-------------

- Bugfix: Add Percent-encoding to query path
- Allow the use of poison 3.0 in addition to 1.5 and 2.0

Version 0.4.0 - released 2016-11-11
-------------

- Provide connector functions that yield and consume documents as Maps
- Support Elixir versions 1.2 and 1.3
- Allow wider range of httpoison versions
- Update development dependencies
- Add and improve documentation

Version 0.3.0 - released 2016-05-13
-------------

- Allow document removal
- Add admin functions for basic user and admin management
- Add basic authentication
- Integrate dialyzer to improve specs and code
- Improve documentation
- Add missing function specs
- Deprecations:
  - Writer.create/2 is now deprecated. Please use Writer.create_generate/2 instead
  - View.document_by_key/5 is now deprecated. Please use one of the new Map-based View.document_by_key functions instead
- Breaking Changes: None in public facing functions

Version 0.2.0 - released 2016-01-04
-------------

First public release
