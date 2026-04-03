## checkdev_generator

### Описание проекта

`checkdev_generator` — микросервис экосистемы **CheckDev**, предназначенный для **генерации и обновления статистики по вакансиям**, а также для работы с **экзаменами и ключами направлений**.
Он собирает и анализирует данные с внешних источников (например, **HeadHunter**), обновляет статистику, обрабатывает экзаменационные данные и предоставляет REST API для получения агрегированных показателей.

Сервис является частью микросервисной архитектуры CheckDev и взаимодействует с другими сервисами (например, `auth`, `desc`, `eureka`).


### Основные возможности

* Получение и обработка данных о вакансиях (через **HeadHunter API**).
* Генерация и обновление статистики по вакансиям (`VacancyStatistic`).
* Управление экзаменами и ключами направлений (`Exam`, `Key`).
* Периодическое обновление данных статистики.
* REST API для получения статистики и экзаменов.
* Безопасный доступ к API через Spring Security.
* Миграции базы данных через **Liquibase**.


### Архитектура проекта

```
ru.checkdev.generator/
├── GeneratorSrv.java                            # Точка входа в приложение
├── component/
│   └── SemanticFetcher.java                     # Компонент для извлечения семантических данных
├── config/
│   └── SecurityConfig.java                      # Конфигурация безопасности
├── controller/                                  # REST API контроллеры
│   ├── ExamController.java
│   └── StatisticController.java
├── domain/                                      # JPA-сущности
│   ├── Exam.java
│   ├── Key.java
│   ├── LastStatisticUpdateDateTime.java
│   └── VacancyStatistic.java
├── dto/                                         # DTO-объекты
│   ├── DirectionKey.java
│   └── VacancyStatisticWithDates.java
├── repository/                                  # Репозитории Spring Data JPA
│   ├── KeyRepository.java
│   ├── LastStatisticUpdateTimeRepository.java
│   └── VacancyStatisticRepository.java
├── service/                                     # Сервисы бизнес-логики
│   ├── ExamService.java
│   ├── KeyService.java
│   ├── KeyServiceImpl.java
│   └── vacancy/
│       ├── HeadHunterVacancyService.java
│       ├── VacancyService.java
│       └── statistic/
│           ├── HeadHunterVacancyStatisticService.java
│           ├── StatisticUpdateTimeService.java
│           ├── VacancyStatisticBroadcastReceiver.java
│           └── VacancyStatisticService.java
└── util/                                        # Утилиты и вспомогательные классы
    ├── PropertiesTokenProvider.java
    ├── RestCall.java
    ├── StatisticCountComparator.java
    ├── TokenProvider.java
    ├── date/
    │   ├── PropertiesStatisticUpdateTimeProvider.java
    │   └── TimeProvider.java
    └── parser/
        ├── HeadHunterParser.java
        └── Parser.java
```


### Технологический стек

| Компонент           | Назначение                             |
|---------------------| -------------------------------------- |
| **Java 21+**        | Язык реализации                        |
| **Spring Boot**     | Фреймворк приложения                   |
| **Spring Data JPA** | Работа с базой данных                  |
| **Spring Security** | Авторизация и защита API               |
| **Liquibase**       | Управление миграциями базы данных      |
| **PostgreSQL**      | Основная база данных                   |
| **REST API**        | Взаимодействие с клиентами и сервисами |
| **HeadHunter API**  | Внешний источник данных                |
| **Maven**           | Система сборки                         |
| **Jenkins**         | CI/CD пайплайн                         |


### Конфигурация приложения

Пример `application.properties`:

```properties
spring.application.name=generator
server.port=9012

spring.datasource.url=jdbc:postgresql://localhost:5432/checkdev_generator
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.jpa.hibernate.ddl-auto=validate
spring.liquibase.change-log=classpath:db/db.changelog-master.xml

eureka.client.service-url.defaultZone=http://localhost:9009/eureka
```


### База данных

**Liquibase** управляет миграциями через файл `src/main/resources/db/db.changelog-master.xml`.
Основные таблицы:

* `exam` — данные экзаменов;
* `key` — ключи направлений или тем;
* `vacancy_statistic` — статистика по вакансиям;
* `last_statistic_update_date_time` — контроль обновлений статистики.


### REST API (основные эндпоинты)

| Метод                                  | Путь                                            | Назначение |
| -------------------------------------- | ----------------------------------------------- | ---------- |
| `GET /exams`                           | Получить список экзаменов                       |            |
| `GET /exam/{id}`                       | Получить экзамен по ID                          |            |
| `POST /exam`                           | Создать новый экзамен                           |            |
| `GET /statistics`                      | Получить актуальную статистику                  |            |
| `POST /statistics/update`              | Принудительно обновить статистику               |            |
| `GET /vacancies`                       | Получить вакансии с агрегированными данными     |            |
| `GET /vacancies/headhunter`            | Запрос вакансий с HeadHunter                    |            |
| `GET /vacancies/statistic/last-update` | Проверить дату последнего обновления статистики |            |

*(точные пути могут отличаться, см. `ExamController` и `StatisticController`)*


### Интеграции

#### HeadHunter API

Классы:

* `HeadHunterParser` — парсинг JSON-ответов HeadHunter;
* `HeadHunterVacancyService` — получение вакансий через HTTP;
* `HeadHunterVacancyStatisticService` — обновление статистики на основе данных HH;
* `RestCall` и `TokenProvider` — HTTP-запросы и авторизация.


### Как запустить локально

#### 1. Сборка

```bash
mvn clean package
```

#### 2. Запуск

```bash
java -jar target/checkdev_generator-0.0.1-SNAPSHOT.jar
```

или:

```bash
mvn spring-boot:run
```

#### 3. Доступ

После запуска сервер будет доступен по адресу:
[http://localhost:9012](http://localhost:9012)


### Интеграция с Eureka

Для регистрации в `cd_eureka`:

```properties
eureka.client.register-with-eureka=true
eureka.client.fetch-registry=true
eureka.client.service-url.defaultZone=http://localhost:9009/eureka
```


### Jenkins (CI/CD)

`Jenkinsfile` описывает стандартный pipeline:

1. **Build** — сборка через Maven;
2. **Test** — запуск юнит-тестов;
3. **Deploy** — публикация артефакта или Docker-образа.


### Dockerfile (пример)

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/checkdev_generator-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 9012
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Сборка:

```bash
docker build -t checkdev-generator .
```

Запуск:

```bash
docker run -p 9012:9012 checkdev-generator
```

## Запуск проекта через Docker desktop
Перед началом убедитесь, что у вас установлены:

Docker Desktop
### Клонирование проекта
Проект состоит из нескольких сервисов (каждый в отдельном репозитории).
Необходимо скачать все части проекта в одну папку.


### Подготовка структуры проекта
#### Файл docker-compose.yml находится в репозитории checkdev_auth.
Необходимо: переместить его в корень проекта (checkdev/)

Итоговая структура:
```
checkdev/
├── docker-compose.yml   ← ВАЖНО (должен быть здесь)
├── checkdev_auth/
├── checkdev_eureka/
├── checkdev_generator/
├── checkdev_mock/
├── checkdev_desc/
├── checkdev_site/
├── checkdev_notification/
```
### Сборка и запуск

Перейдите в корень проекта

#### Соберите и запустите контейнеры:

docker compose build

docker compose up

#### перейдите по http://localhost:8080


### Важно

Если проект не запустится, необходимо будет вручную запустить контейнеры, сначала все базы данных,
затем сервисы в следующем порядке:

auth->eureka->generator->mock->desc->site->notification
## Запуск проекта k8s
Перед началом убедитесь, что у вас установлены:

Docker Desktop

Minikube

### Клонирование проекта
Проект состоит из нескольких сервисов (каждый в отдельном репозитории).
Необходимо скачать все части проекта в одну папку.

### Подготовка структуры проекта
#### Файл docker-compose.yml и директория k8s находятся в репозитории checkdev_auth.
Необходимо: переместить их в корень проекта (checkdev/)

Итоговая структура:
```
checkdev\
│
├─ docker-compose.yml
├─ k8s\
│   ├─ auth-spring-deployment.yml
│   ├─ desc-spring-deployment.yml
│   └─ ...
│
├─ checkdev_auth\
│   └─ Dockerfile
├─ checkdev_desc\
│   └─ Dockerfile
├─ checkdev_generator\
│   └─ Dockerfile
├─ checkdev_mock\
│   └─ Dockerfile
├─ checkdev_site\
│   └─ Dockerfile
└─ checkdev_notification\
    └─ Dockerfile
```
### Сборка и запуск

сначала необходимо создать образы с помощью команды docker compose build

далее необходимо загрузить каждый образ в миникуб с помощью команды minikube load image <название образа>

далее перейдите в директорию k8s и откройте консоль, необходимо применить все манифесты с помощью команды kubectl apply -f .

далее откройте сайт с помощью команды minikube service site-service