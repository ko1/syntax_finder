# SyntaxFinder

Find Ruby syntax patterns with Prism.

## How to use

Write your pattern in Ruby.

```ruby
require 'syntax_finder'

# Count up all `if` statements (if/elsif/?:) and `then` keywords.

class IfThenFinder < SyntaxFinder
  def look node
    if node.type == :if_node
      if node.if_keyword_loc # if or elsif
        inc node.if_keyword_loc.slice
        if node.then_keyword_loc
          inc 'then'
          # inc path: @file
        end
      else
        # a ? b : c
        inc '?:'
      end
    end
  end
end
```

and run the script with Ruby script file names listed in STDIN like this.

```sh
$ find ruby/ruby -name '*.rb' | ruby samples/if_then_finder.rb
[[[:FILES, 7_705], [:FAILED_PARSE, 3]],
 [["if", 14_886], ["?:", 1_806], ["elsif", 922], ["then", 184]]]
```

In this case, with *.rb files in ruby/ruby directory, there are

* There are 7_705 files
  * but 3 files are failed to prase
* In the files, there are
  * 14_886 `if` statements
  * 1_806 `?:` style if statements
  * 922 `elsif` statements
  * 184 `then` statements

You can specify files with arguments like that:

```sh
$ ruby samples/if_then_finder.rb samples/*.rb
 ruby -I ./lib/ samples/then_finder.rb samples/*
[[[:FILES, 18]], [["if", 31], ["elsif", 2], ["then", 1]]]
```

You can specify `-j` or `-jN` for parallel processing like that:

```sh
$ time find ruby/ruby -name '*.rb' | ruby -I ./lib/ samples/if_then_finder.rb
[[[:FILES, 7_705], [:FAILED_PARSE, 3]],
 [["if", 14_886], ["?:", 1_806], ["elsif", 922], ["then", 184]]]

real    0m3.952s
user    0m2.566s
sys     0m0.088s

$ time find ruby/ruby -name '*.rb' | ruby -I ./lib/ samples/if_then_finder.rb -j
[[[:FILES, 7_705], [:FAILED_PARSE, 3]],
 [["if", 14_886], ["?:", 1_806], ["elsif", 922], ["then", 184]]]

real    0m1.281s
user    0m5.822s
sys     0m1.141s
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
