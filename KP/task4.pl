:- load_files(['facts.pl']).
% :- debug.

father_for_both(X, Y, Z):-
	father(Z, X), father(Z, Y).

mother_for_both(X, Y, Z):-
	mother(Z, X), mother(Z, Y).

sex(X, m):-
	father(X, _).

sex(X, f):-
	mother(X, _).

% X брат Y
brother(X, Y):-
	sex(X, m),
	father_for_both(X, Y, _),
	mother_for_both(X, Y, _),
	X \= Y.

% X сестра Y
sister(X, Y):-
	sex(X, f),
	father_for_both(X, Y, _),
	mother_for_both(X, Y, _),
	X \= Y.

% A тётя X
aunt(A, X):-
	father(Z, X),
	sister(A, Z).

aunt(A, X):-
	mother(Z, X),
	sister(A, Z).

% A дядя X
uncle(A, X):-
	father(Z, X),
	brother(A, Z).

uncle(A, X):-
	mother(Z, X),
	brother(A, Z).

% X двоюродный брат Y
cousin(X, Y):-
	uncle(Z, X),
	father(Z, Y),
	sex(Y,m), !.

cousin(X, Y):-
	aunt(Z, X),
	mother(Z, Y),
	sex(Y,m), !.

grandson_search(X, Y):-
	father(Z, X),
	father(Y, Z).

grandson_search(X, Y):-
	mother(Z, X),
	father(Y, Z).

% X внук Y
grandson(X, Y):-
	sex(X, 'm'),
	grandson_search(X, Y).

% X внучка Y
granddaughter(X, Y):-
	sex(X, 'f'),
	grandson_search(X, Y).

% X родитель Y
parent(X, Y):-
	father(X, Y).
parent(X, Y):-
	mother(X, Y).

% X сын Y
son(X, Y):-
	sex(X, 'm'),
	parent(Y, X).

% X дочь Y
daughter(X, Y):-
	sex(X, 'f'),
	parent(Y, X).

% X дедушка Y
grandfather(X, Y):-
	father(X, Z),
	parent(Z, Y).

% X бабушка Y
grandmother(X, Y):-
	mother(X, Z),
	parent(Z, Y).

% X муж Y
husband(X, Y):-
	father(X, Z),
	mother(Y, Z).

% X жена Y
wife(X, Y):-
	mother(X, Z),
	father(Y, Z).

% Обработка тривиального случая
relative('father', X, Y):- father(X, Y).
relative('mother', X, Y):- mother(X, Y).
relative('husband', X, Y):- husband(X, Y).
relative('wife', X ,Y):- wife(X, Y).
relative('brother', X, Y):- brother(X, Y).
relative('sister', X, Y):- sister(X, Y).
relative('son', X, Y):- son(X, Y).
relative('daughter', X, Y):- daughter(X, Y).
relative('grandson', X, Y):- grandson(X, Y).
relative('granddaughter', X, Y):- granddaughter(X, Y).
relative('grandfather', X, Y):- grandfather(X, Y).
relative('grandmother', X, Y):- grandmother(X, Y).
relative('aunt', X, Y):- aunt(X, Y).
relative('uncle', X, Y):- uncle(X, Y).
relative('cousin', X, Y):- cousin(X, Y).

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
	granddaughter(X, Y),
	aunt(X, Y),
	uncle(X, Y),
	cousin(X, Y).

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

