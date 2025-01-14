require 'syntax_finder'

class PragmaFinder < SyntaxFinder
  def look node
    @root.magic_comments.each{|c|
      inc key = [c.key, c.value]
      note key, @file if $VERBOSE
    }

    # No need for recursive travaersal.
  end

  def traverse node
    look node
    # check only root node
  end
end
