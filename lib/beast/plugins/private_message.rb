module Beast
  module Plugins

    class PrivateMessage < Beast::Plugin
      author 'Calvin Yu - codeeg.com'
      version '0003'
      homepage "http://boardista.com"
      notes "Private message support for Beast"

      route :resources, 'private_messages'
      
      %w( controllers helpers models ).each do |dir|
        path = File.expand_path(File.join(plugin_path, 'app', dir))
        if File.exist?(path) && !Dependencies.load_paths.include?(path)
          Dependencies.load_paths << path
        end
      end
      
      def initialize
        super
        ::User.send :include, UserExtension
        ActionView::Base.send :include, PrivateMessagesHelper
        ApplicationController.class_eval do
          prepend_view_path File.join(PrivateMessage::plugin_path, 'app', 'views')
        end
      end
      
      module UserExtension
        def self.included(base)
          base.has_many :private_messages_sent, :foreign_key => 'sender_id',
              :class_name => 'PrivateMessage', :order => ::PrivateMessage.default_order
          base.has_many :private_messages_received, :foreign_key => 'recipient_id',
              :class_name => 'PrivateMessage', :order => ::PrivateMessage.default_order
        end
      
        def private_messages(options = {})
          ::PrivateMessage.find_associated_with(self, options)
        end
        
        def private_messages_count
          ::PrivateMessage.count_associated_with(self)
        end
        
        def private_messages_with_user(user, options = {})
          ::PrivateMessage.find_between(self, user, options)
        end
      
        def private_messages_with_user_count(user)
          ::PrivateMessage.count_between(self, user)
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
          
          add_index :private_messages, :sender_id
          add_index :private_messages, :recipient_id
        end
      
        def self.uninstall
          drop_table :private_messages
          remove_index :private_messages, :sender_id
          remove_index :private_messages, :recipient_id
        end
      
      end
    end

  end
end
