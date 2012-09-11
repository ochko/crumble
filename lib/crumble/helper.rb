module Crumble
  module Helper
    def crumbs
      crumb = (Beard.instance.trails).detect do |trail|
        trail.controller.to_sym == params[:controller].to_sym and
          trail.action.to_sym == params[:action].to_sym and
          trail.condition_met?(self)
      end
      return unless crumb
      if wrapper = Beard.instance.html[:wrapper]
        content_tag(wrapper[:element], nil, :class => wrapper[:class]) do
          calculate_breadcrumb_trail(crumb.trail).join.html_safe
        end
      else
        calculate_breadcrumb_trail(crumb.trail).join.html_safe
      end
    end
    
    def calculate_breadcrumb_trail(trail)
      trail.map do |crummy|
        crumb = Beard.instance.crumbs[crummy]
        if crummy == trail.last
          content_tag(Beard.instance.html[:trail][:element],
                      eval(%Q{"#{assemble_crumb_title(crumb)}"}),
                      Beard.instance.html[:trail][:last])
        else
          content_tag(Beard.instance.html[:trail][:element],
                      link_to(eval(%Q{"#{assemble_crumb_title(crumb)}"}),
                              fetch_crumb_url(crumb)) +
                      Beard.instance.html[:trail][:delimiter].html_safe)
        end.html_safe
      end
    end
    
    def fetch_parameterized_crumb_url(crumb)
      case crumb.params
      when Hash
        if crumb.params[:params]
          send(crumb.url, fetch_parameters_recursive(crumb.params[:params]))
        else
          result = instance_eval("@#{assemble_crumb_url_parameter(crumb.params).join(".")}")
          send(crumb.url, result)
        end
      else
        if crumb.url == :current
          params
        else
          prams = crumb.params.collect do |name|
            case name
            when Symbol
              instance_variable_get("@#{name}")
            when String
              instance_eval(name)
            end
          end
          send(crumb.url, *prams)
        end
      end
    end
    
    def fetch_crumb_url(crumb)
      if crumb.params
        fetch_parameterized_crumb_url(crumb)
      else
        send(crumb.url)
      end
    end
    
    def fetch_parameters_recursive(params_hash, parent = nil)
      parameters = {}
      case params_hash
      when Symbol
        parameters[params_hash] = (parent || params)[params_hash]
      when Array
        params_hash.each do |pram|
          parameter = (parent || params)[pram]
          parameters[pram] = parameter unless parameter.blank?
        end
      when Hash
        params_hash.each do |pram, nested|
          parameters[pram] = fetch_parameters_recursive(nested, params[pram])
        end
      end
      parameters
    end
    
    def assemble_crumb_url_parameter(params)
      result = []
      params.to_a.flatten.collect do |step|
        result << if step.is_a?(Hash)
                    assemble_crumb_url_parameter(step)
                  else
                    step
                  end
      end
      result
    end

    def assemble_crumb_title(crumb)
      if crumb.title.is_a?(Hash) # We expect the name of the parameters with the code to evaluate
        i18n_params = {}
        crumb.title.each_pair do |key, value|
          i18n_params[key] = instance_eval("@#{assemble_crumb_url_parameter(value).join(".")}")
        end
        I18n.t(crumb.name, {:scope => "breadcrumbs"}.merge!(i18n_params))
      elsif crumb.title.nil?
        I18n.t(crumb.name, :scope => "breadcrumbs")
      else
        crumb.title
      end
    end
  end
end
