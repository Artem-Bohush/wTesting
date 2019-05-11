# Задачі та цілі модульного тестування

Загальна інформація про утиліту wTesting.

Фреймворк для юніт-тестування. Фреймворк надає розробнику інтуітивний інтерфейс, просту структуру тестів, асинхронне виконання тестів, кольоровий вивід звіту про виконання, контроль за кількістю виведеної інформації та інше. Використовуючи `wTesting`, ви позбавитесь від рутинної роботи по юніт-тестуванню автоматизувавши її.

Модульні тести (юніт тести), пишуться для того, щоб протестувати чи працює данний модуль(юніт). Сам юніт тест - це код - який тестує юніти (частини) кода: функції, модулі або класси. 

Юніт тести - найбільш прості для написання та найбільш прості для розуміння. Суть юніт тестування полягає в тому, щоб подати щось на вход юніта і перевірити результат на виході. Наприклад, на вхід подаємо параметри функції, а на виході отримаемо значення. Юніт тести дають впевненність, що программа працює як задумано. Такі тести можно запускати багатократно. Успішне виконання тестів покаже розробнику, що його зміни нічого не зламали. Тест, що провалився дозволе виявити, що зроблені в коді зміни, змінили чи зламали його поведінку. Дослідження помилки, яку видає тест, що провалився та порівняння очікуваного результата з отриманим, дасть можливисть зрозуміти, де виникла помилка. Усі залежності виключаються, а це значить, що ми надаємо підроблені залежності (фейки) для модуля. Крім того необхідно писати код таким чином, щоб це дозволяло тестувати юніти окремо.