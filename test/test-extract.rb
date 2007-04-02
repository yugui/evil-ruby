require 'test/unit/testcase'
require 'test/unit/ui/console/testrunner'

class Extracter
  def self.process(fn)
    new(File.read(fn))
  end
  
  def initialize(content)
    comment_block_re = /((?:^\s*?(?:#.*?)?\n)+)/m
    component_re = /\s*(?:class|def|module|alias)\s+:?([^\s()]+)?/
    blocks = content.scan(/#{comment_block_re}#{component_re}/)

    test_suite = Class.new(Test::Unit::TestCase)

    has_test = false
    blocks.each do |(comment, component)|
      code_in_doc_re = /^(\s*#  +(?:.*?)$)/
      tests = comment.scan(code_in_doc_re)
      body = tests.map do |test|
        test.map do |raw_line|
          line = raw_line.sub(/^\s*#\s{0,3}/, "")
          if md = /(.*?)#\s*(=>|~>|raises?)\s*(.*?)$/.match(line)
            new_line, type, result = *md.captures
            new_line.strip!
            case type
              when "=>"
                ["begin",
                 "  assert_equal(#{result}, #{new_line})",
                 "rescue => err",
                 "  assert_equal(#{result.inspect}, (#{new_line}).inspect)",
                 "end"].join("\n")
              when "~>", "raise", "raises"
                "assert_raises(Object.const_get(#{result.inspect})) { #{new_line} }"
            end
          else
            line
          end
        end.join("\n")
      end.join("\n")

      unless component
        if $DEBUG
          STDERR.puts "Can't get name for this code:",
            body.gsub(/(?:\r?\n){2}/, "\n")
        end
        component = test.hash.abs
      end

      if body and not body.empty?
        has_test = true
        begin
          test_suite.class_eval %{
            def #{test_method_name(component)}
              #{body}
            end
          }
        rescue Object => err
          STDERR.puts "Error in #{test_method_name(component)}: ",
            err, "", "Code is: ", body, "" if $DEBUG
        end
      end
    end

    if not has_test
      test_suite.class_eval do
        def test_main; end
      end
    end

    Test::Unit::UI::Console::TestRunner.new(test_suite).start
  end

  def test_method_name(component)
    result = "test_#{component}"
    {
      "+"	=> "op_plus",
      "-"	=> "op_minus",
      "+@"	=> "op_plus_self",
      "-@"	=> "op_minus_self",
      "*"	=> "op_mul",
      "**"	=> "op_pow",
      "/"	=> "op_div",
      "%"	=> "op_mod",
      "<<"	=> "op_lshift",
      ">>"	=> "op_rshift",
      "~"	=> "op_tilde",
      "<=>"	=> "op_cmp",
      "<"	=> "op_lt",
      ">"       => "op_gt",
      "=="	=> "op_equal",
      "<="	=> "op_lt_eq",
      ">="	=> "op_gt_eq",
      "==="	=> "op_case_eq",
      "=~"	=> "op_apply",
      "|"	=> "op_or",
      "&"	=> "op_and",
      "^"	=> "op_xor",
      "[]"	=> "op_fetch",
      "[]="	=> "op_store"
    }.each do |(what, by)|
      result.gsub!(what, by)
    end
    return result
  end
end

if __FILE__ == $0
  file = ARGV.shift
  load(file)
  Extracter.process(file)
end
