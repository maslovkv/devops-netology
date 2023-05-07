# Домашнее задание к занятию 4 «Работа с roles»

## Подготовка к выполнению

1. Необязательно. Познакомьтесь с [LightHouse](https://youtu.be/ymlrNlaHzIY?t=929).
2. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
3. Добавьте публичную часть своего ключа к своему профилю на GitHub.

## Основная часть

Ваша цель — разбить ваш playbook на отдельные roles. 

Задача — сделать roles для ClickHouse, Vector и LightHouse и написать playbook для использования этих ролей. 

Ожидаемый результат — существуют три ваших репозитория: два с roles и один с playbook.

**Что нужно сделать**

1. Создайте в старой версии playbook файл [`requirements.yml`](playbook/requirements.yml) и заполните его содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.11.0"
       name: clickhouse 
   ```

2. При помощи `ansible-galaxy` скачайте себе эту роль.
   
   `ansible-galaxy install -r requirements.yml -p roles`

3. Создайте [новый каталог](playbook/roles/vector-role) с ролью при помощи `ansible-galaxy role init vector-role`.
4. На основе tasks из старого playbook заполните новую [role](playbook/roles/vector-role/tasks/main.yml). Разнесите переменные между [`vars`](playbook/roles/vector-role/vars/main.yml) и [`default`](playbook/roles/vector-role/defaults/main.yml). 
5. Перенести нужные шаблоны конфигов в [`templates`](playbook/roles/vector-role/templates).
6. Опишите в [`README.md`](playbook/README.md) обе роли и их параметры.
7. Повторите шаги 3–6 для LightHouse. Помните, что одна роль должна настраивать один продукт.
8. Выложите все roles в репозитории. Проставьте теги, используя семантическую нумерацию. Добавьте roles в [`requirements.yml`](playbook/requirements.yml)  в playbook.
9. Переработайте [playbook](playbook/site.yml) на использование roles. Не забудьте про зависимости LightHouse и возможности совмещения `roles` с `tasks`.
10. <details><summary>Выложите playbook в репозиторий.
    </summary> 
    
      ```commandline
      git init
      git branch -m main
      git remote add origin git@github.com:maslovkv/vector-role.git
      git add .
      git commit -m 'add v0.0.1'
      git tag v0.0.1
      git push origin --tags
      git push --set-upstream origin main -f
      ```
    </details>

11. В ответе дайте ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.
* [vector-role](https://github.com/maslovkv/vector-role)
* [lighthouse-role](https://github.com/maslovkv/lighthouse-role)

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
