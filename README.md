# CouchdbConnector

[![Build Status](https://travis-ci.org/locolupo/couchdb_connector.svg)](https://travis-ci.org/locolupo/couchdb_connector)

## Description

A connector for CouchDB, the Erlang-based, JSON document database.

The connector does not implement the protocols defined in Ecto.
Reasons: CouchDB does not support transactions as known in the world of
ACID compliant, relational databases.
The concept of migrations also does not apply to CouchDB.
And since CouchDB does not implement an SQL dialect, the decision was taken
to not follow the standards established by Ecto.

The connector offers 'create', 'update' and 'read' operations through its
Writer and Reader modules.
Basic support for view operations is provided by the View module.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add couchdb_connector to your list of dependencies in `mix.exs`:

        def deps do
          [{:couchdb_connector, "~> 0.1.0"}]
        end

  2. Ensure couchdb_connector is started before your application:

        def application do
          [applications: [:couchdb_connector]]
        end

## Usage

TBD
