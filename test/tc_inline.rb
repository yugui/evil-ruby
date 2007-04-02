$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
$LOAD_PATH.unshift File.dirname(__FILE__)

require "test-extract"
require "evil"

glob = File.join(File.dirname(__FILE__), "../lib/*")
Dir[glob].each do |file|
  next unless File.file?(file)
  Extracter.process(file)
end
