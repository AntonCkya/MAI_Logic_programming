% Обычная рекурсия
fib(0, 0).
fib(1, 1).
fib(N, R):-
    N > 1,
    N1 is N - 1,
    N2 is N1 - 1,
    fib(N1, R1),
    fib(N2, R2),
    R is R1 + R2.



% корекурсия (Не рабочая версия :( )
fib(0, 1).
fib(1, 1).
fib(N, F) :-
    fib(N1, F1),
    fib(N2, F2),
    N is N2 + 1,
    F is F1 + F2.
    

% Хвостовая рекурсия
fib(0, 1) :- !.
fib(1, 1) :- !.
fib(N, F) :-
        fib(1,1,1,N,F).

fib(_F, F1, N, N, F1) :- !.
fib(F0, F1, I, N, F) :-
        F2 is F0+F1,
        I2 is I + 1,
        fib(F1, F2, I2, N, F).
