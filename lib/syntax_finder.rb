require 'prism'
require 'optparse'
require_relative 'syntax_finder/version'

class SyntaxFinder
  def initialize file
    @file = file
  end

  ### Traversing and looking methods

  # Please write your pattern here to investigate the node.
  # This method is called for each node.
  def look node
    # override here
  end

  # If you need to pass some context while traversing,
  # redefine this method with context like `def traverse node, context = nil`.
  def traverse node
    look node
    traverse_rest node
  end

  def traverse_rest node
    node.compact_child_nodes.each do |child|
      traverse child
    end
  end 

  ### Utility methods for look

  # node location information
  def nloc node
    "#{@file}:#{node.location.start_line}"
  end

  # node line (1st line of node lines)
  def nline node
    node.slice_lines.lines.first.chomp
  end

  # node lines
  def nlines node
    node.slice_lines
  end

  def success? r
    return true if r.success?

    if r.errors.size == 1 &&
       r.errors.first.type == :script_not_found
      true
    else
      false
    end
  end

  # any object can be a key.
  # if key is [A-Z_]+, it's system key.
  # it's returns true if the key is already exists.
  def inc key
    has_key = @@result.has_key? key
    @@result[key] += 1
    has_key
  end

  def note key, note
    @@result_notes[key] << note
  end

  def self.inc key
    @@result[key] += 1
  end

  def self.note key, note
    @@result_notes[key] << note
  end

  ### Execution management

  def start_traverse
    puts "Start #{@file}" if $DEBUG

    @root = Prism.parse_file(@file)
    if success?(@root)
      traverse @ast = @root.value
    else
      # pp [@file, @root.errors]
      # inc :FAILED, @file
      inc :FAILED_PARSE
    end
  rescue Interrupt
    exit
  rescue Exception => e
    pp [e, @file, e.backtrace] if $DEBUG
    inc [:FAILED, e.class]
  end

  @@finders = [self]

  def self.inherited klass
    @@finders << klass
  end

  def self.last_finder
    @@finders.last
  end

  @@result = Hash.new(0)
  @@result_notes = Hash.new{|h, k| h[k] = []}
  @@opt = {}

  def self.setup_parallel finder, pn
    taskq = @@opt[:taskq] = Queue.new
    resq  = @@opt[:resq] = Queue.new
    term_cmd = '-- terminate'

    @@opt[:threads] = pn.times.map{
      Thread.new _1 do |ti|
        task_r, task_w = IO.pipe
        res_r, res_w = IO.pipe

        pid = fork do
          trap(:INT, 'IGNORE')

          loop do
            file = task_r.gets.chomp

            case file
            when  term_cmd
              @@result_notes.default_proc = nil
              last_result = [@@result, @@result_notes]
              break
            else
              kick finder, file
              last_result = nil
            end
          rescue Interrupt
            STDERR.puts "Worker is interrupted (pid: #{Process.pid})"
            @@result_notes.default_proc = nil
            last_result = [@@result, @@result_notes]
            exit
          ensure
            res_w.puts Marshal.dump(last_result).dump
          end
        end

        result = nil

        while true
          file = taskq.pop
          task_w.puts file || term_cmd
          result = Marshal.load(res_r.gets.chomp.undump) # wait for the result
          
          if result
            resq << result
            break
          end
        end
      ensure
        p [Thread.current, $!] if $DEBUG
        Process.kill :KILL, pid
        Process.waitpid pid
      end
    }
  end

  def self.cleanup_parallel
    return unless taskq = @@opt[:taskq]
    trap(:INT){
      trap(:INT, 'DEFAULT')
    }
    taskq.close

    @@opt[:parallel].times do |i|
      results, notes = @@opt[:resq].pop
      @@result.merge!(results){|k, a, b| a + b}
      @@result_notes.merge!(notes)
    end
  end

  def self.parse_opt finder, argv
    o = OptionParser.new
    o.on '-v', '--verbose', 'VERBOSE mode' do
      $VERBOSE = true
    end

    o.on '-d', '--debug' do
      $DEBUG = true
    end

    o.on '-q', '--quiet' do
      @@opt[:quiet] = true
    end

    o.on '-j', '--jobs[=N]', 'Parallel mode' do
      require 'etc'

      pn = @@opt[:parallel] = _1&.to_i || Etc.nprocessors
      setup_parallel finder, pn
    end

    o.parse! argv
    pp options: @@opt if $DEBUG
  end

  def self.kick finder, file
    finder.new(file).start_traverse
  end

  def self.aggregate_results
    if @@result_notes.size > 0
      results =  @@result.sort_by{|k, v| -v}.map{|k, v|
        if !(note = @@result_notes[k]).empty?
          [k, v, note]
        else
          [k, v]
        end
      }
    else
      results = @@result.sort_by{|k, v| -v}
    end

    results.partition{|key,|
      Symbol === key && key.length > 1 && /^[A-Z_]+$/ =~ key
    }
  end

  def self.print_result
    system_results, user_results = aggregate_results
    pp [system_results, user_results]
  end

  def self.run finder, argv = ARGV
    @already_run = true
    parse_opt finder, argv

    files = argv.empty? ? ARGF : argv
    files.each do |f|
      f = f.scrub.strip
      next unless FileTest.file?(f)
  
      inc :FILES
  
      if q = @@opt[:taskq]
        q << f
      else
        kick finder, f
      end
    end
  rescue Interrupt
    STDERR.puts "-- Interrupted"
    exit
  ensure
    cleanup_parallel
    finder.print_result if finder
  end

  END{
    if !@already_run && @@finders.size == 2
      self.run last_finder
    end
  }
end

# for pretty integer results
class Integer
  def inspect
    self.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1_')
  end
end
