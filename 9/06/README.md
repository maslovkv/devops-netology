# Домашнее задание к занятию 12 «GitLab»

## Подготовка к выполнению

1. Подготовьте к работе GitLab [по инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers).
2. Создайте свой новый проект.
3. Создайте новый репозиторий в GitLab, наполните его [файлами](./repository).
4. Проект должен быть публичным, остальные настройки по желанию.

## Основная часть

### DevOps

В репозитории содержится код проекта на Python. Проект — RESTful API сервис. Ваша задача — автоматизировать сборку образа с выполнением python-скрипта:

1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated).
2. Python версии не ниже 3.7.
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`.
4. Создана директория `/python_api`.
5. Скрипт из репозитория размещён в /python_api.
6. Точка вызова: запуск скрипта.
7. При комите в любую ветку должен собираться docker image с форматом имени hello:gitlab-$CI_COMMIT_SHORT_SHA . Образ должен быть выложен в Gitlab registry или yandex registry.   
8.* (задание необязательное к выполению) При комите в ветку master после сборки должен подняться pod в kubernetes. Примерный pipeline для push в kubernetes по [ссылке](https://github.com/awertoss/devops-netology/blob/main/09-ci-06-gitlab/gitlab-ci.yml).
Если вы еще не знакомы с k8s - автоматизируйте сборку и деплой приложения в docker на виртуальной машине.

[Готово](https://gitlab.com/maslovkv/nelology-python-api/-/commit/13432a89f2d9b3429282db1b2d9dbf30b6552d8a)

### Product Owner

Вашему проекту нужна бизнесовая доработка: нужно поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать [Issue](https://gitlab.com/maslovkv/nelology-python-api/-/issues/1) в котором указать:

1. Какой метод необходимо исправить.
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`.
3. Issue поставить label: feature.

### Developer

Пришёл новый Issue на доработку, вам нужно:

1. Создать отдельную [ветку](https://gitlab.com/maslovkv/nelology-python-api/-/tree/1-product-owner), связанную с этим Issue.
2. Внести [изменения](https://gitlab.com/maslovkv/nelology-python-api/-/commit/e7affef38ed0fcd0de579282c7ca121096e06853) по тексту из задания.
3. Подготовить [Merge Request](https://gitlab.com/maslovkv/nelology-python-api/-/merge_requests/1), влить необходимые изменения в `master`, проверить, что сборка прошла [успешно](https://gitlab.com/maslovkv/nelology-python-api/-/jobs/4542582785)


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:

1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность.
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый.

![tester](img/tester.png)

## Итог

В качестве ответа пришлите подробные скриншоты по каждому пункту задания:

- файл gitlab-ci.yml;
- Dockerfile; 
- лог успешного выполнения пайплайна;
- решённый Issue.

[Репозиторий](https://gitlab.com/maslovkv/nelology-python-api)

### Важно 
После выполнения задания выключите и удалите все задействованные ресурсы в Yandex Cloud.

## Необязательная часть

Автомазируйте работу тестировщика — пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер в docker или k8s и выполняет проверку, например, при помощи curl. На основе вывода будет приниматься решение об успешности прохождения тестирования.

<details><summary>Приблизительно так </summary>

```yaml
tester:
  stage: test
  script:
    - docker pull  $CI_REGISTRY/$CI_PROJECT_PATH:latest 
    - docker run --name $CI_PROJECT_PATH  $CI_REGISTRY/$CI_PROJECT_PATH:latest -p 5290:5290 -d
    - ss -nlpt | grep 5290
    - curl -s -X GET http://localhost:5290/rest/api/get_info | grep Running 
    - docker stop $CI_PROJECT_PATH
    - docker rm $(docker ps -aq)
  only:
    - test
```

</details>

