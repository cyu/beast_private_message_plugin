module Beast::Plugins

  class PrivateMessage < Beast::Plugin
    author 'Calvin Yu - codeeg.com'
    version '0001'
    homepage "http://blog.codeeg.com"
    notes "Private message support for Beast"
    
    route :pm, 'pm/:action/:id', :controller => 'private_messages'
    
    Dependencies.load_paths << File.expand_path(File.join(RAILS_ROOT, 'vendor', 'plugins',
        PrivateMessage::plugin_name, 'app'))

    def initialize
      super
      ActionView::Base.send :include, PrivateMessagesHelper
      ApplicationController.class_eval do
        prepend_view_path File.join(PrivateMessage::plugin_path, 'views')
      end
    end
    
    class Schema < ActiveRecord::Migration
  
      def self.install
        create_table :private_messages do |t|
          t.column :sender_id, :integer
          t.column :recipient_id, :integer
          t.column :title, :string
          t.column :body, :text
          t.column :body_html, :text
          t.column :mark_read, :boolean, :default => false
          t.timestamps 
        end
      end
    
      def self.uninstall
        drop_table :private_messages
      end
    
    end
  end

end
