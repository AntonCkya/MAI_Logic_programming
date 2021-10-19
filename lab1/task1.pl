
length1([], 0).
length1([_|T], N):-
	length1(T, N1),
	N is N1 + 1.

member1([X|_], X).
member1([_|Y], X):-
	member1(Y, X).

append1([], X, X).
append1([X|Y], Z, [X|T]):-
	append1(Y, Z, T).

remove1(X, [X|T], T).
remove1(X, [Y|T], [Y|R]):-
	remove1(X, T, R).

permute1([],[]).
permute1(X, R):-
	remove1(Y, X, T),
	permute1(T, T1),
	R = [Y|T1].

sublist1(S, R):-
	append1(X, _, S),
	append1(_, R, X).



% Усечение списка до указанной длины

% Без стандартных предикатов 

cutlist(X,0,[]).
cutlist([X|Y],K,[X|Y1]):-
    K1 is K - 1,
    cutlist(Y,K1,Y1).

% Со стандартными предикатами

cutlist2(Zs, N, Xs) :-
    length(Xs, N),
    append(Xs, _Ys, Zs).

% Вычисление позиции максимального элемента в списке

% Без стандратных предикатов

max_list([X|Xs], Max, Index):-
    max_list(Xs, X, 0, 0, Max,Index).

max_list([], OldMax, OldIndex, _, OldMax, OldIndex).

max_list([X|Xs], OldMax, _, CurrentIndex, Max, Index):-
    X > OldMax,
    NewCurrentIndex is CurrentIndex + 1,
    NewIndex is NewCurrentIndex,
    max_list(Xs, X, NewIndex, NewCurrentIndex, Max, Index).

max_list([X|Xs], OldMax, OldIndex, CurrentIndex, Max, Index):-
    X =< OldMax,
    NewCurrentIndex is CurrentIndex + 1,
    max_list(Xs, OldMax, OldIndex, NewCurrentIndex, Max, Index).
    

%со стандартными предикатами 

comparator([H|T], N):-
	N >= H,
	comparator(T, N).
comparator([], _).

max2(X, N):-
	remove1(N, X, Y),
	comparator(Y, N).

memberwithCounter([X|_], X, 0).
memberwithCounter([_|Y], X, Index):-
	memberwithCounter(Y, X, Index1),
    Index is Index1 + 1.

max_list1(List, Index):-
    max2(List, N),
    memberwithCounter(List, N, Index).
