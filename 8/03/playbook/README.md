## [Playbook](site.yml)

содержит три play: 
- Install Clickhouse
- Install Vector
- Install and configuring lighthouse

### Install Clickhouse.

#### [Переменные](group_vars/clickhouse/vars.yml)

Определяют версию clickhouse и устанавливаемые пакеты.

#### Tasks:

1. Get clickhouse distrib - скачивает дистрибутив нужной версии.
2. Install clickhouse packages - устанавливает полученный дистрибутив.
   Через handler (Start clickhouse service) запускает service clickhouse. 
3. Pause for 10 seconds - пауза 10 секунд для перезапуска  clickhouse.
4. Create database - создаёт базу данных `logs`.

### Install Vector.

#### [Переменные](group_vars/vector/vars.yml)

Определяют следующие параметры vector:
* версию
* путь куда будет установлен
* путь для хранения данных
* путь до config-файла

#### Tasks:

1. Get Vector version - проверяет установлен ли vector.
2. Create directory vector - создает дирректорию для установки.
3. Get vector distrib - скачивает требуемую версию vector.
4. Unarchive vector - распаковывает дистрибутив.
5. Create a symbolic link - создает символическую ссылку, чтобы не менять `$PATH`.
6. Create vector unit flie - создает по [шаблону](templates/vector.service.j2) unit-файл.
7. Mkdir vector data - создает дирректорию для хранения данных.
8. Vector config create - создает по [шаблону](templates/vector.toml.j2) config-файл.
9. Configuring service vector - настраивает работу vector в качестве сервиса и запускает его. 

Все tasks имеют tag `vector`.

Все кроме "Get Vector version" имеют условие выполнения.
Условие позволяет не запускать повторно установку и настройку vector.

Handler 'Restart Vector' не используется. Оставил для примера.


### Install and configuring lighthouse.

#### [Переменные](group_vars/lighthouse/vars.yml)

Определяют следующие параметры nginx:
* Путь для файла репозитория.
* Путь ко корневой директории.
* Путь до конфига по умолчанию.

Определяют следующие параметры lighthouse:
* Директорию для дистрибутива.
* Путь для архива с дистрибутивом.
* [Url](https://github.com/VKCOM/lighthouse/archive/refs/heads/master.zip)
для получения дистрибутива.

#### Tasks:
#### Install and configuring nginx:

* Add repositories nginx - создает по [шаблону](templates/nginx.repo.j2) файл репозитория.
* Install nginx - устанавливает nginx.
* Configuring service nginx - настраивает работу nginx в качестве сервиса и запускает его.

#### Install and configuring lighthouse:

* Create directory lighthouse - создает директорию для lighthouse.
* Get lighthouse distrib - скачивает дистрибутив lighthouse.
* Install unzip - устанавливает unzip.
* Unarchive lighthouse - распаковывает дистрибутив lighthouse.
* Apply nginx config - изменяет по [шаблону](templates/nginx.conf.j2) конфиг nginx и перезапускает его.