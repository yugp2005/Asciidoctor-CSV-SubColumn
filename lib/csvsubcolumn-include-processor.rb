RUBY_ENGINE == 'opal' ? (require 'csvsubcolumn-include-processor/extension') : (require_relative 'csvsubcolumn-include-processor/extension')

Extensions.register do
  include_processor CsvSubcolumnIncludeProcessor 
end
