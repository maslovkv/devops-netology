## [Playbook](site.yml)

содержит два play: Install Clickhouse и Install Vector.

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

Для создания окружения использовался [vagrant](vagrant).



