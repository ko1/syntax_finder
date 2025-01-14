require 'syntax_finder'

# count all of given method names via comma separated environment variables,
# like `NAMES=map,collect`

NAMES = ENV['NAMES']&.yield_self{|m| m.split(',').map{|m| m.strip.to_sym}}.to_h{|e| [e, true]} || raise

class MethodNameFinder < SyntaxFinder
  def look node
    case t = node.type
    when :call_node, :def_node
      if NAMES[name = node.name]
        inc [t, name]
        pp [nloc(node),nlines(node).lines.first.chomp] if $VERBOSE
      end
    end
  end
end
