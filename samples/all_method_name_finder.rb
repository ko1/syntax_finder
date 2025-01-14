require 'syntax_finder'

# Cound up all of method names.

class MethodNameFinder < SyntaxFinder
  def look node
    if node.type == :call_node
      inc [:call, node.name]
      # pp [nloc(node),nlines(node).lines.first.chomp] unless @@opt[:quiet]
    elsif node.type == :def_node
      inc [:def, node.name]
      # pp [nloc(node),nlines(node).lines.first.chomp] unless @@opt[:quiet]
    end
  end

  def self.print_result
    @@result.sort_by{|(t, m), v| [t, -v]}.each{|(t, m), v|
      puts "#{v}\t#{t}\t#{m}" 
    }
  end
end

