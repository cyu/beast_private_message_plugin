require 'private_message/plugin'

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

Class.class_eval do
  def inherited_with_extensions(klass)
    User.send(:include, UserExtension) if klass == User
    inherited_without_extensions(klass)
  end
  alias_method_chain :inherited, :extensions
end
