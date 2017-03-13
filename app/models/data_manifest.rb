# This is a list of requests for variables.
#
# The request comes in this form:
# [
#   [ "var_name", "calculation" ]
# ]
#
# A calculation is an infix expression:
#
#   x / y
#
# The terms in a calculation are:
# 1) A String, Number, Boolean
# 2) A List of each of these.
# 3) A function
#
#
# An example manifest:
#
# {
#   "record_name": {
#     type: "formula",
#     value: '"IPIMEL069.T1"'
#   },
#   "experiment_name: {
#     type: "question",
#     value: [ "sample", [ "sample_name", "::equals", "@record_name" ], "::first", "patient", "experiment", "name" ]
#   },
#   "qc": {
#     type: "table",
#     value: {
#       rows: [ "sample", [ "patient", "experiment", "name", "::equals", "@experiment_name" ] ],
#       columns: {
#         treg_cd45_count: [ "population", [ "stain", "::equals", "treg" ], [ "name", "::equals", "CD45+" ], "::first", "count" ],
#         nktb_cd45_count: [ "population", [ "stain", "::equals", "nktb" ], [ "name", "::equals", "CD45+" ], "::first", "count" ],
#         sort_cd45_count: [ "population", [ "stain", "::equals", "sort" ], [ "name", "::equals", "CD45+" ], "::first", "count" ],
#         dc_cd45_count: [ "population", [ "stain", "::equals", "dc" ], [ "name", "::equals", "CD45+" ], "::first", "count" ],
#         treg_live_count: [ "population", [ "stain", "::equals", "treg" ], [ "name", "::equals", "Live" ], "::first", "count" ],
#         nktb_live_count: [ "population", [ "stain", "::equals", "nktb" ], [ "name", "::equals", "Live" ], "::first", "count" ],
#         sort_live_count: [ "population", [ "stain", "::equals", "sort" ], [ "name", "::equals", "Live" ], "::first", "count" ],
#         dc_live_count: [ "population", [ "stain", "::equals", "dc" ], [ "name", "::equals", "Live" ], "::first", "count" ],
#       }
#     }
#   },
#   heights: {
#     type: "vector",
#     value: {
#       items: [
#         "@qc.treg_cd45_count / @qc.nktb_cd45_count",
#         "@qc.treg_cd45_count / @qc.nktb_cd45_count",
#       ]
#     }
#   }
# }

class DataManifest
  attr_reader :vars
  def initialize manifest
    @manifest = manifest
    @vars = {}
    @env = InfixParser::Environment.create(@vars)
  end

  def fill
    Rails.logger.info("Manifest is #{@manifest.to_json}")
    @manifest.each do |variable, query|
      begin
      @vars[variable] = resolve(query)
      rescue RLTK::NotInLanguage => e
        raise "Could not resolve #{query}"
      end
    end
  end

  def payload
    Hash[
      @vars.map do |var, value|
        value = case value
        when Vector
          value.to_a
        when DataTable
          value.to_matrix
        else
          value
        end
        [ var, value ]
      end
    ]
  end

  private

  def resolve(query)
    InfixParser::parse(InfixLexer::lex(query),env: @env)
  end
end