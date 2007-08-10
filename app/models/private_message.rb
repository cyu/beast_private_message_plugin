class PrivateMessage < ActiveRecord::Base
  def self.per_page() 25 end

  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'

  format_attribute :body

  validates_presence_of :sender_id, :recipient_id, :body, :title
  attr_accessible :title, :body
  
  def read
    self.mark_read = true
  end

  def editable_by?(user)
    user && (user.id == sender_id)
  end

  def self.find_associated_with(user, opts = {})
    find_options = associated_with_condition(user).merge!(:order => default_order)
    find_options.merge!(opts)
    find(:all, find_options)
  end

  def self.count_associated_with(user)
    count(associated_with_condition(user))
  end

  def self.find_between(user, other_user, opts = {})
    find_options = between_condition(user, other_user).merge!(:order => default_order)
    find_options.merge!(opts)
    find(:all, find_options)
  end

  def self.count_between(user, other_user)
    count(between_condition(user, other_user))
  end

  def self.default_order
    "#{table_name}.created_at DESC"
  end
  
  protected
  
    def self.between_condition(user, other_user)
      {:conditions => [ '(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)',
          user.id, other_user.id, other_user.id, user.id ]}
    end

    def self.associated_with_condition(user)
      {:conditions => [ 'sender_id = ? OR recipient_id = ?', user.id, user.id ]}
    end
  
end
