module Crumble
  class Railtie < ::Rails::Railtie
    initializer 'crumble' do |_app|
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Crumble::Helper
      end
    end
  end
end
