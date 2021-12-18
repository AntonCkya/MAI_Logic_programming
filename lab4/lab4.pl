true(river_volga).
true(pupil_vasya).
true(true).


calculate(L,R):-
	solver(L,[R]).

solver(['(',true,')'|T],R):-
	solver([true|T],R).
solver(['(',false,')'|T],[false|T]):-
	solver([false|T],R).

solver([A,'&',B | T], R):-
	true(A),
	true(B),
	check(A),
	check(B),
	solver([true|T],R),
	!.

solver([A,'&',B | T], R):-
	check(A),
	check(B),
	solver([false|T],R).

solver([A,'=>',B | T], R):-
	(not(true(A));true(B)),
	check(A),
	check(B),
	solver([true|T],R),
	!.

solver([A,'=>',B | T], R):-
	check(A),
	check(B),
	solver([false|T],R).

solver(['~',B | T], R):-
	true(B),
	check(B),
	solver([false|T],R),
	!.

solver(['~',B | T], R):-
	check(B),
	solver([true|T],R).

solver([A,'&',B | T], R):-
	check(A),
	check(B),
	solver([false|T],R).

solver([A,'V',B | T], R):-
	(true(A);true(B)),
	check(A),
	check(B),
	solver([true|T],R),
	!.

solver([A,'V',B | T], R):-
	check(A),
	check(B),
	solver([false|T],R).

solver([A|[B|T]],R):-
	solver([B|T],Y),
	[B|T] \= Y,
	solver([A|Y],R),!.

solver(X,X).

check(X):-
	X \= '(',
	X \= ')',
	X \= '~',
	X \= 'V',
	X \= '&',
	X \= '=>'.


%% solver([true,'&','(','river_volga','&',true,')'],R).