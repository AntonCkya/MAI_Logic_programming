# Отчет по курсовому проекту
## по курсу "Логическое программирование"

### студент: <Сысоев Максим Алексеевич>

## Результат проверки

Вариант задания:

 - [ ] стандартный, без NLP (на 3)
 - [x] стандартный, с NLP (на 3-4)
 - [ ] продвинутый (на 3-5)
 
| Преподаватель     | Дата         |  Оценка       |
|-------------------|--------------|---------------|
| Сошников Д.В. |              |               |
| Левинская М.А.|              |               |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*

## Введение

В результате выполнения курсового проекта, надеюсь научиться решать повседневные задачи на языке Prolog, уметь мыслить исключительно в рамках парадигмы логического программирования.

## Задание

1. Скачать файл родословной европейской знати в формате GEDCOM. Изучить каким образом располагаются данные в нём.   
2. Преобразовать файл в формате GEDCOM в набор утверждений на языке Prolog, используя следующее представление: с использованием предикатов `father(отец, потомок)` и `mother(мать, потомок)`.   
3. Реализовать предикат проверки/поиска двоюродного брата.  
4. Реализовать программу на языке Prolog, которая позволит определять степень родства двух произвольных индивидуумов в дереве   
5. [На оценки хорошо и отлично] Реализовать естественно-языковый интерфейс к системе, позволяющий задавать вопросы относительно степеней родства, и получать осмысленные ответы.   

## Получение родословного дерева

Реализовал своё родословное дерево при помощи сайта  `MyHeritage.com`. По итогу, получилось родословное дерево на 41 персону.

## Конвертация родословного дерева

Для конвертации использовал императивный язык программирования Python, так как считаю, что он отлично подходит для парсинга текста в данной задаче и, при этом уже был опыт работы с ним. <br>  
Основные моменты программы:   
1. Считываем из файла GEDCOM строки, содержащие теги:
 - NAME - имя + /фамилия/;
 - FAMS - семья его родителей (где он был ребенком);
 - FAMC - семья (или семьи), где он сам был родителем;
 - SEX - пол;
 ```python
    res = []
    gedcomFile = open(sys.argv[1], "r", encoding='utf-8')
    for line in gedcomFile:
        for each in ["NAME", "FAMS", "FAMC", "SEX"]:
            if each in line:
                res.append(line)
    gedcomFile.close()
 ```
 2. Очищаем данные от лишней информации, представляем в удобном виде и переводим имена на английский язык:
 ```python

    for i in range(1, len(res)):
        listOfWords = res[i].split(' ') # Разбиваем строку на слова
        del listOfWords[0] # Удаляем число, обозначающее уровень
        res[i] = listOfWords
        for k in range(len(res[i])):
            res[i][k] = res[i][k].replace("\n", "") # Убираем символ перевода строки у слова


    for i in range(1, len(res)):
        if res[i][0] == "NAME":
            res[i][2] = res[i][2].replace("/", "")
            res[i][1] = res[i][1] + " " + res[i][2]
            del res[i][2]
            res[i][1] = translator(res[i][1])  # Переводим имена на английский язык

 ```
3. Собираем список семей в формате [номер семьи, [родители], [дети]].
4. Обходим список семей и генерируем строки в формате фактов Prolog:
```python
 for family in families:
        if len(family[2]) == 0:
            continue
        for child in family[2]:
            for parent in family[1]:
                if parent[1] == "M":
                    facts.append("father(\'" + parent[0] + "\', \'" + child[0] + "\').\n")
                else:
                    facts.append("mother(\'" + parent[0] + "\', \'" + child[0] + "\').\n")
```

**Примечание:** результат преобразования находится файле `facts.pl`, 

## Предикат поиска родственника

Двоюродный брат - сын дяди или тёти. Реализовал предикат дяди и тёти. Дядя - брат матери или отца. Тётя - сестра матери или отца.   
**Замечание:** в связи с таким представлением (mother и father) невозможно определить пол человека, если он не родитель. Из-за чего не получится определить двоюродных братьев без детей.   
Все необходимые предикаты находятся в файле `task3.pl`.
```prolog
% Двоюродный брат – сын дяди или тетки
% X двоюродный брат Y
cousin(X, Y):-
	uncle(Z, X),
	father(Z, Y),
	sex(Y,m).

cousin(X, Y):-
	aunt(Z, X),
	mother(Z, Y),
	sex(Y,m).

```
Примеры запуска на произвольных данных:
```
?- cousin('Maxim', 'Dima').
true.

?- cousin('Maxim', Y).
Y = 'Dima'.
```

## Определение степени родства

Реализовал предикаты поиска жены/мужа, бабушки/дедушки, внучки/внука, дочери/сына. Остальное взял из `task3.pl`. 
Сначала рассматриваем тривиальные случаи, когда родство находится сразу же:
```prolog
relative('father', X, Y):- father(X, Y).
relative('mother', X, Y):- mother(X, Y).
...
```

Когда совпадений не нашлось, необходимо искать более глубокие связи родства. Для этого воспользуемся поиском в глубину (В данном случае выбор пал в сторону экономии памяти). Предикат `dfs` находит все пути из A в B и затем переводит список имён в список отношений:
```prolog
relative(W, X, Y):- 
	dfs(X, Y, W).

% Для перевода списка имён в список отношений.

translator([X, Y], [R]):-
	relative(R, X, Y).
translator([X, Y|T], [P, Q|R]):-
	relative(P, X, Y),
	translator([Y|T], [Q|R]), !.

move(X, Y):-
	father(X, Y);
	mother(X, Y);
	brother(X, Y);
	sister(X, Y);
	son(X, Y);
	daughter(X, Y);
	husband(X, Y);
	wife(X, Y),
	grandfather(X, Y),
	grandmother(X, Y),
	grandson(X, Y),
	granddaughter(X, Y).

% Depth-First Search
prolong([X|T], [Y, X|T]):-
	move(X, Y),
	not(member(Y, [X|T])).
path1([X|T], X, [X|T]).
path1(L, Y, R):-
	prolong(L, T),
	path1(T, Y, R).
dfs(X, Y, R2):-
	path1([X], Y, R1),
	translator(R1, R2).
```
Пример запуска:
```prolog
?- relative(W, 'Elena Zatsepina', 'Elena Sysoeva').
W = grandmother;
W = [daughter, daughter] ;
W = [sister, daughter, daughter] ;
W = [sister, sister, daughter, daughter] ;
W = [sister, sister, daughter, daughter] ;
W = [daughter, father, sister, daughter, daughter] ;
W = [daughter, father, sister, daughter, daughter] ;
W = [daughter, father, daughter, daughter] ;
W = [sister, daughter, father, daughter, daughter] ;
W = [sister, daughter, father, daughter, daughter] ;
W = [sister, daughter, daughter] ;
W = [sister, sister, daughter, daughter] ;
W = [daughter, father, sister, daughter, daughter] ;
W = [sister, daughter, daughter] ;
W = [sister, sister, daughter, daughter] ;
W = [daughter, father, sister, daughter, daughter] ;
W = [daughter, father, daughter, daughter] ;
W = [sister, daughter, father, daughter, daughter] ;
W = [daughter, father, daughter, daughter] ;
W = [sister, daughter, father, daughter, daughter].
 ```

## Естественно-языковый интерфейс

## Выводы

Сформулируйте *содержательные* выводы по курсовому проекту в целом. Чему он вас научила? 
Над чем заставила задуматься? Помните, что несодержательные выводы -
самая частая причина снижения оценки.
