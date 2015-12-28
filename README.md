# CouchdbConnector

[![Build Status](https://travis-ci.org/locolupo/couchdb_connector.svg)](https://travis-ci.org/locolupo/couchdb_connector)
[![Coverage Status](https://coveralls.io/repos/locolupo/couchdb_connector/badge.svg?branch=master&service=github)](https://coveralls.io/github/locolupo/couchdb_connector?branch=master)

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

All create and update operations expect valid JSON documents. All read
operations return JSON strings exactly as they come from CouchDB.

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

    For the subsequent steps, let's assume that we work in iex and that we use these database properties:

    iex>db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_dev", port: 5984}

### Create a database

    Couchdb.Connector.Storage.storage_up(db_props)

    You should see
    {:ok, "{\"ok\":true}\n"}

    In case the database already exists of course, you would see
    {:error,
      "{\"error\":\"file_exists\",\"reason\":\"The database could not be created, the file already exists.\"}\n"}

### Write to a database

    Now that the database exits, we can create documents in it.

    Couchdb.Connector.Writer.create(db_props, "{\"key\": \"value\"}")

    You should see something similar to this

    {:ok,
      "{\"ok\":true,\"id\":\"6b66e9bd59c1c35f3ab51165b10889a7\",\"rev\":\"1-59414e77c768bc202142ac82c2f129de\"}\n",
        [{"Server", "CouchDB/1.6.1 (Erlang OTP/18)"},
        {"Location",
        "http://localhost:5984/couchdb_connector_dev/6b66e9bd59c1c35f3ab51165b10889a7"},
        {"ETag", "\"1-59414e77c768bc202142ac82c2f129de\""},
        {"Date", "Sun, 27 Dec 2015 22:28:15 GMT"},
        {"Content-Type", "text/plain; charset=utf-8"}, {"Content-Length", "95"},
        {"Cache-Control", "must-revalidate"}]}

    In the previous example, we had CouchDB assign a generated id to the document. This will do for most cases. In case you want to provide an id and you are sure that it does not yet exist in the database, you can do this:

    Couchdb.Connector.Writer.create(db_props, "{\"key\": \"value\"}", "unique_id")

    You should then see something like

    {:ok,
      "{\"ok\":true,\"id\":\"unique_id\",\"rev\":\"1-59414e77c768bc202142ac82c2f129de\"}\n",
        [{"Server", "CouchDB/1.6.1 (Erlang OTP/18)"},
        {"Location", "http://localhost:5984/couchdb_connector_dev/unique_id"},
        {"ETag", "\"1-59414e77c768bc202142ac82c2f129de\""},
        {"Date", "Sun, 27 Dec 2015 22:32:45 GMT"},
        {"Content-Type", "text/plain; charset=utf-8"}, {"Content-Length", "72"},
        {"Cache-Control", "must-revalidate"}]}

### Read from a database

    Given we have a document under the id "unique_id" in the database that we created in one of the steps above, the following "GET" should return the desired document.

    So let's try

    Couchdb.Connector.Reader.get(db_props, "unique_id")

    You should see something akin to this:

    {:ok,
      "{\"_id\":\"unique_id\",\"_rev\":\"1-59414e77c768bc202142ac82c2f129de\",\"key\":\"value\"}\n"}

    In case you ask for a non existing document, like in this example

    Couchdb.Connector.Reader.get(db_props, "wrong_id")

    You should see something this:

    {:error,  "{\"error\":\"not_found\",\"reason\":\"missing\"}\n"}

### Create a View

    TBD

### Query a View

     TBD

### Destroy a database

    Couchdb.Connector.Storage.storage_down(db_props)

    You should see
    {:ok, "{\"ok\":true}\n"}

    Just in case that database never existed, you shoud see
    {:error, "{\"error\":\"not_found\",\"reason\":\"missing\"}\n"}

## Next

    Love to hear from you. Meanwhile, here are some things we'd like to tackle next:

    - authentication
    - retry on (HTTPoison.Error) :closed errors
    - enhance view query capabilities
    - implement wrappers to take / return Maps instead of JSON strings
    - cache UUIDs
    - pool HTTP connections
