# Runs all tests.

$LOAD_PATH.unshift "lib"

test_dir = File.split(Dir.pwd).last == "test" ? "." : "test"

tests = Dir["#{test_dir}/**/*.rb"].reject { |file| file == "tc_all.rb" }
tests.each { |test| require test  }
