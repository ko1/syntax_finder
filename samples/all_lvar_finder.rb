require 'syntax_finder'

# Cound up all of local variable names.

class LVarFinder < SyntaxFinder
  def look node
    if node.respond_to? :locals
      node.locals.each{|lv|
        case lv
        when Symbol
          inc lv
        when Prism::BlockLocalVariableNode
          inc lv.name
        else
          pp [node.type, lv.type, node.locals].inspect
          exit
        end
      }
    end
  end

  def self.print_result
    @@result.sort_by{|lv, v| [-v, lv]}.each{|lv, v|
      puts "#{lv}\t#{v}" 
    }
  end
end
