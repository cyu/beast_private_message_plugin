class PrivateMessageMailer < ActionMailer::Base
  def notification(sender, recipient, domain, messages_url, sent_at = Time.now)
    @subject    = "[Beast] You\'ve received a private message from {sender}"[:beast_pm_email_subject, sender.display_name]
    @body       = {:sender => sender, :recipient => recipient, :domain => domain, :messages_url => messages_url}
    @recipients = recipient.email
    @from       = 'beast@' + domain.split(":").first
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def self.template_root
    File.join(Beast::Plugins::PrivateMessage::plugin_path, 'app', 'views')
  end
end
