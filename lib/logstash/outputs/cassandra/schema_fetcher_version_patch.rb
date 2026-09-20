# encoding: utf-8
require 'cassandra'

# cassandra-driver 3.2.5 (last released in 2020) only registers schema fetchers for
# Cassandra release versions '1.2', '2.0', '2.1', '2.2', '3.' and '4.' (see
# Cassandra::Driver#create_schema_fetcher_picker). Anything else, e.g. Cassandra 5.x,
# makes the control connection fail with:
#   Cassandra::Errors::ClientError: unsupported release version "5.0.8".
# The system_schema.* tables that the '3.'/'4.' fetcher (V3_0_x) reads from have not
# changed in a way that breaks it for Cassandra 5.x, so it's safe to reuse it here.
module LogStash; module Outputs; module Cassandra
  module SchemaFetcherVersionPatch
    def create_schema_fetcher_picker
      picker = super
      picker.when('5.') do
        ::Cassandra::Cluster::Schema::Fetchers::V3_0_x.new(schema_cql_type_parser, cluster_schema)
      end
      picker
    end
  end
end; end; end

::Cassandra::Driver.prepend(LogStash::Outputs::Cassandra::SchemaFetcherVersionPatch)
