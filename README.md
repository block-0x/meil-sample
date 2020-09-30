# アプリケーション概要
このアプリケーションは、メール送信機能作成のためのサンプルです。
以下に `rails new` から `heroku deploy` までの工程を記載いたします。

## 使用技術
Ruby 2.6.5
Ruby on Rails 5.2.4.4
cloud Heroku
mail api [SendGrid](https://sendgrid.kke.co.jp/)

# 以下、工程

### Railsアプリケーション作成

```
$ rails _5.2.4_ new meil-sample
```

### メーラーを生成

```
$ rails generate mailer UserMailer
```

### メーラーを編集

`app/mailers/user_mailer.rb`

```
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url = 'http://example.com/login'
    mail(to: @user.email, subject: 'welcome to My Awesome Site')
  end
end
```

### ビューファイルを生成

```
$ touch app/views/user_mailer/welcome_email.html.erb 
```

### ビューファイルを編集

`app/views/user_mailer/welcome_email.html.erb`

```
<!DOCTYPE html>
<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type" />
  </head>
  <body>
    <h1><%= @user.name %>様、example.comへようこそ。</h1>
    <p>
      example.comへのサインアップが成功しました。
      your username is: <%= @user.login %>.<br>
    </p>
    <p>
      このサイトにログインするには、<%= @url %>をクリックしてください。
    </p>
    <p>ご入会ありがとうございます。どうぞお楽しみくださいませ。</p>
  </body>
</html>
```

### メールテキストファイルを生成

```
$ touch app/views/user_mailer/welcome_email.text.erb
```

### メールテキストファイルを編集

```
<%= @user.name %>様、example.comへようこそ。
==============================================

example.comへのサインアップが成功しました。ユーザー名は「<%= @user.login %>」です。

このサイトにログインするには、<%= @url %>をクリックしてください。

本サイトにユーザー登録いただきありがとうございます。
```

### ユーザを生成

```
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

### ユーザを編集

`app/controllers/users_controller.rb`

```
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        UserMailer.welcome_email(@user).deliver_later # <- 追加

        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  ```
  
### SendGridのAPI_KEYを取得
  
1. [SendGrid](https://sendgrid.kke.co.jp/)にアクセス
1. ユーザ登録する
1. ログインする
1. 以下の画像の順でAPI_KEYを取得する

![](https://devcenter0.assets.heroku.com/article-images/1473932591-00000066.png)
![](https://devcenter3.assets.heroku.com/article-images/1473932632-00000067.png)

### Herokuにログイン

```
$ heroku login
```

### Heroku appを作成

```
$ heroku create
```

### SendGridアドオンをプロビジョニング

```
$ heroku addons:create sendgrid:starter
```

### API_KEYをセットする

```
$ heroku config:set SENDGRID_API_KEY=取得したAPI_KEY
```

### SendGridに割り当てられたユーザ情報を取得

ユーザ名取得

```
$ heroku config:get SENDGRID_USERNAME
```

パスワード取得

```
$ heroku config:get SENDGRID_PASSWORD
```

### 取得したユーザ情報を登録

```
$ heroku config:set SENDGRID_USERNAME=取得したSENDGRID_USERNAME
$ heroku config:set SENDGRID_PASSWORD=取得したSENDGRID_PASSWORD
```

### 登録情報の確認

```
$ heroku config
SENDGRID_API_KEY:  API_KEY
SENDGRID_PASSWORD: 取得したSENDGRID_USERNAME
SENDGRID_USERNAME: 取得したSENDGRID_PASSWORD
```

### production.rbの編集


`config/environments/production.rb`

以下を追記する

```
config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true
config.action_mailer.smtp_settings = {
:user_name => ENV['SENDGRID_USERNAME'],
:password => ENV['SENDGRID_PASSWORD'],
:domain => 'herokuapp.com',
:address => 'smtp.sendgrid.net',
:port => 587,
:authentication => :plain,
:enable_starttls_auto => true
}
```

### Herokuにデプロイ

```
$ git add .
$ git commit -m 'mailer_sample'
$ git push heroku master
$ heroku run rails db:migrate
$ heroku open
```














