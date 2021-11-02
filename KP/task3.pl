father_for_both(X, Y, Z):-
	father(Z, X), father(Z, Y).

mother_for_both(X, Y, Z):-
	mother(Z, X), mother(Z, Y).

sex(X, m):-
	father(X, _).

sex(X, f):-
	mother(X, _).

%X брат Y
brother(X, Y):-
	sex(X, m),
	father_for_both(X, Y, _),
	mother_for_both(X, Y, _),
	X \= Y.

%X сестра Y
sister(X, Y):-
	sex(X, f),
	father_for_both(X, Y, _),
	mother_for_both(X, Y, _),
	X \= Y.

 % A тётя X
aunt(A,X):-
	father(Z, X),
	sister(A, Z).

aunt(A,X):-
	mother(Z, X),
	sister(A, Z).

 % A дядя X
uncle(A,X):-
	father(Z, X),
	brother(A, Z).

uncle(A,X):-
	mother(Z, X),
	brother(A, Z).

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

   







