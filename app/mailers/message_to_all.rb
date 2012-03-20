class MessageToAll < ActionMailer::Base
  default from: "bothunter@myhotspot.ru"

  def broadcast_message email_to, subject, body_text
    @body_text = body_text

    mail(to: email_to,
         subject: subject) do |format|
      format.html { render text: @body_text }
      format.text { render text: @body_text }
    end
  end
end
