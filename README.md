
# Что будет прогинорировано в директории terraform

- Символ (*) соответствует 0 или более символам.
- Восклицательный знак (!) в качестве первого символа инвертирует шаблон.
- Две звёздочки (**) указывают на вложенные директории.
- Строки, начинающиеся с #, игнорируются.

## Рекурсивно все директории .terraform
```
**/.terraform/*
```
## .tfstate файлы

```
*.tfstate
*.tfstate.*
```

## Файлы журнала сбоев
```
crash.log
crash.*.log
```

## Все файлы .tfvars, которые могут содержать конфиденциальные данные, такие как пароль, закрытые ключи и другие секреты

```
*.tfvars
*.tfvars.json
```

## Игнорировать файлы переопределения, так как они обычно используются для локального переопределения ресурсов 

```
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

## Включить переопределенные файлы, которые вы хотите добавить в систему управления версиями, используя инвертированный шаблон

```
# !example_override.tf
```

## Включить файлы tfplan, чтобы игнорировать вывод  команды: terraform plan -out=tfplan

```
# example: *tfplan*
```

## Файлы конфигурации CLI
```
.terraformrc
terraform.rc
```