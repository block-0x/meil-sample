class UserMailer < ApplicationMailer
default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url = 'http://example.com/login'
    mail(to: @user.email, subject: 'welcome to My Awesome Site')
  end
end
