# Мини-проект "Printf на nasm"
## Краткое описание проекта
Основной целью данного проекта является разработка функции printf на ассемблере nasm, имеющей схожий функционал с одноименной функцией стандартной библиотеки языка С. Подробную информацию о функции `printf` стандартной библотеки `stdio.h` языка С можно прочитать [здесь](https://learn.microsoft.com/ru-ru/cpp/c-runtime-library/format-specification-syntax-printf-and-wprintf-functions?view=msvc-170).

Данная проектная работа является частью курса "Основы промышленного программирования" от [И.Р. Дединского](https://github.com/ded32) на Факультете Радиотехники и Компьютерных Технологий (ФРКТ) МФТИ. Задание носит обучающий характер.

## Описание задачи

Моя функция printf должна поддерживать следующие спецификаторы вывода:
- `%b` - выводит число в двоичной системе счисления
- `%o` - выводит число в восьмеричной системе счисления
- `%d` - выводит число в десятичной системе счисления
- `%x` - выводит число в шестнадцатиричной системе счисления
- `%с` - выводит символ
- `%s` - выводит строку


## Описание реализованных функций

Для достижения поставленных целей будем использован ассемблер __NASM 64__.

Вывод символов на экран реализован через `syscall`:

<details>
<summary><b>Вывод с помощью syscall</b></summary>

~~~nasm
mov rsi, buffer
mov rdx, r9 		   	; msg len
mov rdi, 1	 		   	; stdout
mov rax, 1       	 	; syscall for write()

syscall
~~~
</details>
<br>

Из файла `printf_c.cpp` вызывается моя функция `MyPrint()`, которая находится в файле `printf.asm`.

Также с целью тестирования реализован вызов функции `printf()` стандартной библиотеки С из ассемблерного файла `printf.asm`. Это сделано с помощью директивы `extern printf` и соответствующих манипуляций при линковке в Makefile. 


## Cборка проекта
Чтобы запустить программу, необходимо использовать Makefile, прилагающийся к проекту. Для этого нужно клонировать этот репозиторий на ваш компьютер:

```git clone git@github.com:MatveevDmtr/printf.git```

Далее необходимо в теминале из папки репозитория написать "make".



## Заключение

В данном проекте реализован аналог стандартной функции `printf` на ассемблере __NASM 64__. 

Преимуществом использования моей функции на asm является высокая скорость работы по сравнению со стандратной функции C. Также в ассемблерном варианте реализован спецификатор `%b`, которого нет в стандартной функции.

Из недостатков можно выделить сложности при переносе программ между различными платформами. 