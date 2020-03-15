# README

Простой микросервис для приёма и ретрансляции tcp соединений.
## Функциональные возможности:

* Управление о HTTP пулом пар входных и выходных портов

* Метод HealthCheck (HTTP) для получения оперативной информации о состоянии приложения и пар соединений

* Мониторинг - отправка всего трафика, проходящего через порт в канал Redis

## Настройка и запуск
* Сервис запускается в docker контейнере. Сборка и запуск контейнера описаны в файле docker_build.txt
* Для настройки сервиса используются две переменные окружения REDIS_CLOUD_URL - url используемого redis сервера, PAIRS_OF_SERVERS - преднастроенный список пар портов(может быть пустым. Тогда по умолчанию сервис ничего не слушает, ждёт команды по управляющему порту).
* Порт для управления сервисом 3000. Может быть изменён в командной строке запуска микросервиса на любой другой.
* Интерфейс управдения описан здесь app/controllers/api/swagger.yaml

## Режимы работы smart и dumb
Пара портов может работать в двух режимах:
* dumb - при потере соединения на любом порту пары второй порт разрывается принудительно
* smart - при потере соединения на любом порту пары второй порт сохраняет соединение и при восстановлении соединения на первом порту продолжит с ним работу.

## Пример настройки переменных окружения
PAIRS_OF_SERVERS = '[{"pair": [3001, 3002], "mode": "dumb"}, {"pair": [3003, 3004]}]'

REDIS_CLOUD_URL = 'redis://localhost:6379'
