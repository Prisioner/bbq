## Приложение "Шашлыки"
#### Учебное приложение

#### Аннотация
Проект реализован на `Ruby on Rails` в учебных целях.

#### Краткое описание
Приложение предназначено для планирования совместных мероприятий. После регистрации пользователь может добавить мероприятие, в котором могут принять участие другие пользователи. Возможно ограничение доступа путём установки пинкода.

#### Установка и запуск
Перед запуском приложения необходимо выполнить установку всех необходимых гемов и подготовку базы данных. Для этого в консоли в директории с приложением необходимо выполнить команды:
```
bundle install
bundle exec rake db:migrate
```

Для запуска локального сервера необходимо выполнить команду:
```
bundle exec rails s
```

Список используемых гемов указан в файле `Gemfile`
