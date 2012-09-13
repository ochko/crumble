require 'singleton'

module Crumble
  class Beard
    include Singleton
    Trail = Struct.new(:controller, :action, :trail, :options, :line) do
      def condition_met?(obj)
        if options[:if]
          evaluate(obj, options[:if])
        elsif options[:unless]
          !evaluate(obj, options[:unless])
        else
          true
        end
      end
      
      def evaluate(obj, condition)
        if condition.respond_to?(:call)
          condition.call(obj.controller)
        else
          obj.send(condition)
        end
      end
    end
    
    Crumb = Struct.new(:name, :title, :url, :params)
    
    attr_accessor :trails, :crumbs
    
    def initialize
      @last_crumb_linked = true
    end
    
    def self.configure(&blk)
      instance.crumbs = {}
      instance.trails = []
      instance.instance_eval &blk
      instance.validate
    end
    
    def trail(controller, actions, trail, options = {})
      @trails ||= []
      actions = Array(actions)
      actions.each do |action|
        roller = (@contexts + [controller]).map(&:to_s).join('/').to_sym
        @trails << Trail.new(roller, action, trail, options, caller[2].split(":")[1])
      end
    end
    
    def crumb(name, title, url, *params)
      params = params.first if params.any? && params.first.is_a?(Hash)
      @crumbs ||= {}
      @crumbs[name] = Crumb.new(name, title, url, params)
    end
    
    def context(name)
      @contexts ||= []
      @contexts.push name
      yield
      @contexts.pop
    end

    def html_options options
      @options = options
    end
    def html
      @options
    end

    def validate
      invalid_trails = []
      trails.each do |trail|
        trail.trail.collect do |t|
          invalid_trails << [trail, t] if crumbs[t].nil?
        end
      end
      
      if invalid_trails.any?
        messages = []
        invalid_trails.each do |trail|
          messages << "Trail for #{trail.first.controller}/#{trail.first.action} references non-existing crumb '#{trail.last}' (configuration file line: #{trail.first.line})"
        end
        raise messages.join("\n")
      end
    end
  end
end