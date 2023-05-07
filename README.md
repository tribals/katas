# Расширение для браузера

- браузер работает на веб-технологиях
- веб-технологии - это HTML, CSS и JavaScript
- расширения пишутся в основном на JavaScript
-+ создать каталог
-+ создать файл `manifest.json`
- код на JavaScript в основном асинхронный
-+ для реагирования на событие, такое как "Создана новая вкладка", используются колл-бэки
-+ колл-бэк - это функция, которую надо передать как параметр в другую функцию
-+ колл-бэки для расширений пишутся в специальном файле - "service worker"
-- написать файл `src/service-worker.js`


## Расширение

Закравает дублирующиеся вкладки.

- получить все вкладки в браузере
-++ получать событе "Создание Вкладки", записать его в лог
- найти дубликаты (по адресу, URL)
- закрыть дублирующиеся вкладки, но одну оставить

# Ссылки по теме

- https://developer.mozilla.org/ru/docs/Web/API/Document_Object_Model/Introduction
- https://developer.chrome.com/docs/extensions/mv3/getstarted/tut-quick-reference/#step-3
- https://developer.chrome.com/docs/extensions/mv3/getstarted/development-basics/#load-unpacked
