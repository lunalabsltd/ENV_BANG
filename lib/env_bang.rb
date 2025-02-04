require "env_bang/version"
require "env_bang/classes"
require "env_bang/formatter"

class ENV_BANG
  class << self
    def config(&block)
      instance_eval(&block)
    end

    def use(var, *args)
      var = var.to_s
      description = args.first.is_a?(String) ? args.shift : nil
      options = args.last.is_a?(Hash) ? args.pop : {}

      unless ENV.has_key?(var)
        ENV[var] = options.fetch(:default) { raise_formatted_error(var, description) }.to_s
      end

      vars[var] = options

      # Make sure reading/coercing the value works. If it's going to raise an error, raise it now.
      self[var]
    end

    def raise_formatted_error(var, description)
      return if ENV['ENV_BANG'] == 'false'

      e = KeyError.new(Formatter.formatted_error(var, description))
      e.set_backtrace(caller[3..-1])

      raise e
    end

    def vars
      @vars ||= {}
    end

    def keys
      vars.keys
    end

    def values
      keys.map { |k| self[k] }
    end

    def [](var)
      var = var.to_s
      raise KeyError.new("ENV_BANG is not configured to use var #{var}") unless vars.has_key?(var)

      Classes.cast ENV[var], vars[var]
    end

    def method_missing(method, *args, &block)
      ENV.send(method, *args, &block)
    end

    def add_class(klass, &block)
      Classes.send :define_singleton_method, klass.to_s, &block
    end

    def default_class(*args)
      if args.any?
        Classes.default_class = args.first
      else
        Classes.default_class
      end
    end
  end
end

def ENV!
  ENV_BANG
end
