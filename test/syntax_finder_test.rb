# frozen_string_literal: true

require "test_helper"

class SyntaxFinderTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::SyntaxFinder.const_defined?(:VERSION)
    end
  end

  test 'IfThenFinder' do
    assert do
      pid = fork do
        # kick if_then_finder.rb
        require_relative '../samples/if_then_finder'
        SyntaxFinder.run SyntaxFinder.last_finder, Dir.glob('samples/*.rb')
      end

      Process.waitpid pid
    end
  end
end
