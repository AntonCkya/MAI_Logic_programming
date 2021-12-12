% Проверка, что X = числу от 0 до 3
check(X):-
    member(X, [0,1,2,3]).

% Проверка на возможность такого состояния. 
% Для того чтобы не было 4 каннибала на берегу и т.п.
is_possible_state(state([LM, LK], [RM, RK], _)):-
    check(LM),     % от 0 до 3
    check(LK),
    check(RM),
    check(RK),
    SUMM is LM + RM, SUMM = 3,    % в сумме 3 миссионера
    SUMK is LK + RK, SUMK = 3, !. % в сумме 3 каннибала

% Проверка на безопасность состояния. 
% Для того чтобы каннибалы не съели миссионеров.
in_safe(state([LM, LK], [RM, RK], _)):-     % миссионеров должно быть не меньше, чем каннибалов
    LM >= LK, RM >= RK, !.
in_safe(state([0, _], [_, _], _)):-!.   % либо, если на одном из берегов миссионеров нет,
                                        % то им ничего не угрожает
in_safe(state([_, _], [0, _], _)).

% переправа с левого на правый берег
crossing(state([LM, LK], [RM, RK], l), state([X, Y], [V, W], r)):-
   	check(M),    % не больше 3-х миссионеров в лодку
    check(K),    % не больше 3-х каннибалов в лодку
    (M >= K; M = 0),     % в лодке либо не должно быть миссионеров совсем,
                            % либо должно быть не меньше, чем каннибалов
    SUM is M + K, 
    SUM =< 3,         % в лодке не больше 3-х пассажиров,
    SUM > 0,          % пустая лодка, не может уплыть
                    % (должен быть минимум один в качестве гребца)
    X is LM - M,   % M миссионеров уплыло
    Y is LK - K,   % K каннибалов уплыло
    V is RM + M,   % M миссионеров приплыло
    W is RK + K,   % K каннибалов приплыло
   	is_possible_state(state([X, Y], [V, W], r)),     % проверка на возможность состояния
    in_safe(state([X, Y], [V, W], r)).      % проверка на безопасность состояния

% Переправа с правого на левый берег
crossing(state([LM, LK], [RM, RK], r), state([X, Y], [V, W], l)):- 
   	check(M),
    check(K),
    (M >= K; M = 0),
    SUM is M + K, 
    SUM =< 3, 
    SUM > 0,
    X is LM + M, 
    Y is LK + K,
    V is RM - M, 
    W is RK - K, 
   	is_possible_state(state([X, Y], [V, W], l)), 
    in_safe(state([X, Y], [V, W], l)).


print_list(L):-
    member(P, L),
    write(P), nl,
    fail.
print_list(_).

% Поиск в ширину
b_path([[Cur|T]|_], Cur, [Cur|T]).  % если конец текущего пути -- целевое состояние, то путь найден
b_path([[Cur|T]|TT], Goal, Result):-  
    setof(                              % получаем список продолженных  путей
        [Next, Cur|T],
    	(crossing(Cur, Next), not(member(Next, [Cur|T]))),
    	New
    ), 
    append(TT, New, RR), !,     % добавляем его в конец очереди, удалив уже обработанный путь
    b_path(RR, Goal, Result);   
    b_path(TT, Goal, Result).   % если текущий путь -- тупик, и у него нет продолжений,
                                % то ищем продолжения для следующих в очереди

bfs(Start, Finish, Path, Time):-   
	get_time(Start_time),   % замер времени выполнения для анализа
    b_path([[Start]], Finish, Reversed_path),   % находим путь (список состояний получается инвертированным)
    reverse(Reversed_path, Path),               % переворачиваем чтобы получить в прямом порядке
    get_time(Finish_time), 
    Time is Finish_time - Start_time.

% Поиск в глубину
path([Cur|T], Cur, [Cur|T]).    
path([Cur|T], Goal, Result):-   
    crossing(Cur, Next),                
    not(member(Next, [Cur|T])),         
    path([Next, Cur|T], Goal, Result).  

dfs(Start, Finish, Path, Time):-
	get_time(Start_time),   
    path([Start], Finish, Reversed_path),   
    reverse(Reversed_path, Path),           
    get_time(Finish_time), 
    Time is Finish_time - Start_time.

% Поиск пути с ограниченной длинной
lim_path([Cur|T], Cur, 1, [Cur|T]).    % 1 для предотвращения повторной генерации путей меньшей длины
                                            
lim_path([Cur|T], Goal, N, Result):-
    N > 0,
    crossing(Cur, Next),            % продляем путь смежной с последней вершиной в графе состояний
    not(member(Next, [Cur|T])),     % такой, которую еще не посетили
    N1 is N - 1,                    
    lim_path([Next, Cur|T], Goal, N1, Result).  
% Т.о. будет найден путь длины не больше N, если он существует 

% Генератор натуральных чисел начиная с 1
int(1).
int(X):-
    int(Y),
    X is Y + 1. 

depth_limit(40).    % ограничение для глубины поиска с итеративным заглублением

ids(Start, Finish, Path, Time):-
	get_time(Start_time), 
    int(N),             % получаем очередное значение максимальной глубины
                        % каждый раз на 1 болшее предыдущего
    depth_limit(Lim),   % получаем предел глубин
    (N > Lim, !, fail;  % если достигли предела, то прекращаем искать
    lim_path([Start], Finish, N, Reversed_path),    % иначе ищем очередной путь
    reverse(Reversed_path, Path)),                      
    get_time(Finish_time), 
    Time is Finish_time - Start_time.

% Перевод из пары состояний, в действие, приведшее к переходу
action(state([LM,LK], _, _), state([X,Y], _, D), A):-
    M is abs(LM - X),  
    K is abs(LK - Y),  
    A = carry([M, K], D).   
% carry([M, K], D) означает, что в результате перехода
% перевезено M миссионеров и K каннибалов на берег D.


% Перевод списка состояний в список действий
translate([State1, State2], [Act]):-
    action(State1, State2, Act).
translate([State1, State2|T], [Act|TT]):-
    translate([State2|T], TT),
    action(State1, State2, Act).

% Вывод информации для анализа работы поисков
analysis:-
    nl,
    write('Search\tPath length\tExecution time'), nl,
	dfs(state([3,3],[0,0],l),state([0,0],[3,3],r), DFS_path, DFS_time),
	bfs(state([3,3],[0,0],l),state([0,0],[3,3],r), BFS_path, BFS_time),
	ids(state([3,3],[0,0],l),state([0,0],[3,3],r), ID_path, ID_time),
    length(DFS_path, DFS_len),
    length(BFS_path, BFS_len),
    length(ID_path, ID_len),
    write('DFS\t'), write(DFS_len), write('\t\t'), write(DFS_time), nl,
    write('BFS\t'), write(BFS_len), write('\t\t'), write(BFS_time), nl,
    write('ID\t'), write(ID_len), write('\t\t'), write(ID_time), nl, !.


% Вывод решения задачи
solution:-
    bfs(state([3,3],[0,0],l),state([0,0],[3,3],r), BFS_path, _), 
    write('The best way to cross:'), nl,
    translate(BFS_path, Acts), print_list(Acts),
    length(Acts, Acts_count),           % находим количество действий
    write('Includes '), write(Acts_count), write(' actions.'), !.