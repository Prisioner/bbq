## Приложение "Шашлыки"
#### Учебное приложение

#### Аннотация
Проект реализован на `Ruby on Rails (v5.1.3)` в учебных целях.

#### Краткое описание
Приложение предназначено для планирования совместных мероприятий. После регистрации пользователь может добавить мероприятие, в котором могут принять участие другие пользователи. Возможно ограничение доступа путём установки пинкода.

#### Опробованные/использованные технологии:
+ [reCaptcha](https://www.google.com/recaptcha/intro/), в том числе (в последней версии) `Invisible Recapthca`
+ Связь many-to-many (функционал подписок)
+ Отправка электронной почты через `SendGrid`
+ Загрузка и хранение файлов на [Google Cloud Storage](https://cloud.google.com/)
+ Обработка изображений на сервере (`CarrierWave`, `rmagick`)

#### Установка и запуск
Перед запуском приложения необходимо выполнить установку всех необходимых гемов и подготовку базы данных. Для этого в консоли в директории с приложением необходимо выполнить команды:
```
bundle install
bundle exec rake db:migrate
```

А так же необходимо установить переменные окружения для работы:

+ `reCaptcha`
```
RECAPTCHA_BBQ_SECRET_KEY
RECAPTCHA_BBQ_SITE_KEY
```
+ `Google Cloud Storage`
```
GOOGLE_STORAGE_ACCESS_KEY
GOOGLE_STORAGE_BUCKET_NAME
GOOGLE_STORAGE_SECRET_KEY
```
+ `SendGrid`
```
SENDGRID_USERNAME
SENDGRID_PASSWORD
```

Для запуска локального сервера необходимо выполнить команду:
```
bundle exec rails s
```

Полный список всех используемых гемов указан в файле `Gemfile`

#### Демо
Последняя актуальная версия приложения крутится [здесь](https://bestbbq.herokuapp.com)