# ci-templates

### В репозитории находятся шаблоны для деплоя сервисов группы Alfa-travel


### Использование

Для того чтобы использовать шаблон деплоя необходимо в репозитории с сервисом создать файл `.gitlab-ci.yml` со следующим содержимым:

```
include:
  - project: 'alfa-travel/ci-templates'
    ref: master
    file: 'alfa-travel-jdk17.gitlab-ci.yml'

variables:
  ARTIFACT_NAME: "artifact-name"
  NEXUS_PATH: "nexus-path"
  SKIP_SONAR: "true"
```

Где 
* **ref** - ссылка на ветку в этом репозитории(ci-templates);
* **file** - шаблон для деплоя(11 или 17 JDK);
* **ARTIFACT_NAME** - имя приложения (например, для alfa-plata-server: _ap-server_);
* **NEXUS_PATH** - путь в нексусе (например, для alfa-plata-server: _alfa-plata_);
* **SKIP_SONAR** - флаг пропуска проверки кода SONAR-ом, по умолчанию _"false"_, можно не указывать.