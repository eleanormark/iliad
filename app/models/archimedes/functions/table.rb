module Archimedes
  class Table < Archimedes::Function
    # This retrieves a matrix of data from Magma. Now it should use
    # the new-and-improved Vector predicate
   
    def initialize *args
      super
      query, @opts = @args
      @opts ||= {}

      # 
      if query[1].is_a?(Archimedes::Vector)
        @column_queries = query[3]
      else
        @column_queries = query[2]
      end
      @query = query.to_values
      @order = @opts['order']

      raise ArgumentError, "table requires a Vector query" unless @column_queries.is_a?(Archimedes::Vector)
      raise ArgumentError, "column names must be unique" unless col_names.uniq == col_names

    end

    def call
      Archimedes::Matrix.new(
        ordered(row_names), col_names, ordered(rows)
      )
    end

    private

    def ordered array
      if ordering
        array.values_at(*ordering)
      else
        array
      end
    end

    def ordering
      return nil unless @order && column = col_names.index(@order)
      @ordering ||= rows.map.with_index do |row, i|
        [ row[column], i ]
      end.sort do |a,b|
        (a.first && b.first) ? (a.first <=> b.first) : (a.first ? -1 : 1 )
      end.map(&:last)
    end

    def rows
      answer.map do |(row_name, row)|
        Vector.new(col_names.zip(row))
      end
    end

    def row_names
      @row_names ||= answer.map(&:first)
    end

    def col_names
      @column_queries.to_labels
    end

    def answer
      @answer ||= 
        begin
          response = client.query(
            @token, @project_name,
            @query
          )
          json = JSON.parse(response.body, symbolize_names: true)
          json[:answer]
        end
    end

    def client
      Magma::Client.instance
    end
  end
end
