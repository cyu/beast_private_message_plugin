class PrivateMessagesController < ApplicationController
  before_filter :find_message, :only => [:edit, :update]
  before_filter :login_required
  
  def create
    @private_message = current_user.private_messages_sent.build(params[:private_message])
    @private_message.recipient_id = params[:private_message][:recipient_id]
    @private_message.save!
    
    begin
      PrivateMessageMailer.deliver_notification(current_user, @private_message.recipient,
          request.host_with_port, profile_url(@private_message.recipient))
    rescue Net::SMTPServerBusy, Net::SMTPUnknownError, \
      Net::SMTPSyntaxError, Net::SMTPFatalError, TimeoutError => e
      logger.error("error sending email to #{@private_message.recipient.email}: #{e}")
    end
    
    respond_to do |format|
      format.html { redirect_to user_path(@private_message.recipient_id) }
    end
  end

  def update
    @private_message.attributes = params[:private_message]
    @private_message.recipient_id = params[:private_message][:recipient_id]
    @private_message.save!
    respond_to do |format|
      format.html { redirect_to pm_path }
    end
  end
  
  protected
    def find_message
      @private_message = PrivateMessage.find params[:id]
    end
  
    def authorized?
      (not ['edit', 'update'].include?(action_name)) || @private_message.editable_by?(current_user)
    end
end
