class PrivateMessage < ActiveRecord::Base
  def self.per_page() 25 end

  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'

  format_attribute :body

  validates_presence_of :sender_id, :recipient_id, :body, :title
  attr_accessible :title, :body
  
  def editable_by?(user)
    user && (user.id == sender_id)
  end

  def delete_by!(user)
    self.sender_deleted = true if sender?(user)
    self.recipient_deleted = true if recipient?(user)
    if sender_deleted? && recipient_deleted?
      destroy
    else
      save!
    end
  end
  
  def sender?(user)
    sender_id == user.id
  end
  
  def recipient?(user)
    recipient_id == user.id
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
      {:conditions => [ '(sender_id = ? AND recipient_id = ? AND sender_deleted = ?) OR (sender_id = ? AND recipient_id = ? AND recipient_deleted = ?)',
          user.id, other_user.id, false, other_user.id, user.id, false ]}
    end

    def self.associated_with_condition(user)
      {:conditions => [ '(sender_id = ? AND sender_deleted = ?) OR (recipient_id = ? AND recipient_deleted = ?)',
          user.id, false, user.id, false]}
    end
  
end
