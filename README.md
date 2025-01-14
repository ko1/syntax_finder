# SyntaxFinder

Find Ruby syntax patterns with Prism.

## How to use

Write your pattern in Ruby.

```ruby
# samples/if_then_finder.rb

require 'syntax_finder'

# Count up all `if` statements and `then` keywords.

class IfThenFinder < SyntaxFinder
  def look node
    if node.type == :if_node
      inc :if
      inc :then if node.then_keyword_loc
    end
  end
end
```

and run the script with Ruby script file names listed in STDIN like this.

```sh
$ find ruby/ruby -name '*.rb' | ruby samples/if_then_finder.rb
[[:if, 32153], [:FILES, 9558], [:then, 3627], [:FAILED_PARSE, 5]]
```

In this case, with *.rb files in ruby/ruby directory, there are

* 9,558 files
* 32,153 if statements
* 3,627 then keywords
* 5 files are failed because of parsing.

You can specify files with arguments like that:

```sh
$ ruby samples/if_then_finder.rb samples/*.rb
[[[:FILES, 16]], [[:if, 26], [:then, 1]]]
```

You can specify `-j` or `-jN` for parallel processing like that:

```sh
$ time find ruby/ruby -name '*.rb' | ruby samples/if_then_finder.rb
[[:if, 32153], [:FILES, 9558], [:then, 3627], [:FAILED_PARSE, 5]]

real    0m3.627s
user    0m3.451s
sys     0m0.219s

$ time find ruby/ruby -name '*.rb' | ruby samples/if_then_finder.rb -j
[[:if, 32153], [:FILES, 9558], [:then, 3627], [:FAILED_PARSE, 5]]

real    0m0.962s
user    0m7.944s
sys     0m0.854s
```

## How to write a finder

1. Define a class derived with `SyntaxFinder` class.
2. Define a `look(node)` method with your expected pattern. `node` is Prism's node.
3. Use `inc(key)` if you want to aggregate the statistics in `look()`.

See `examples/` for more examples.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ko1/syntax_finder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
