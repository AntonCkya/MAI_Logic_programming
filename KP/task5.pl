% add database
:- load_files(['facts.pl']).
% add rules and relative chain search 
:- load_files(['task4.pl']).
% :- debug.

% req(['Does', 'Aleksey Sysoev', 'father', 'of', 'Ilya Sysoev'])
% Does X 'relation' of Z
question1(W1, W2, W3, W4, W5):-
	is_question1(W1),
	is_prist(W4),
	res1(W3, W2, W5).

% req(['Who', 'is', 'Vyacheslav Sysoev', 'of', 'Maksim Sysoev'])
% Who is X of Y
question2(W1, W2, W3, W4, W5):-
	is_question2(W1),
	is_is(W2),
    is_prist(W4),
	res2(P, W3, W5).

req(L):-
	append(T1, T2, L),
	append(W1, T3, T1),
	append(W2, W3, T3),
	append(W4, W5, T2),
	(
    question1(W1, W2, W3, W4, W5);
    question2(W1, W2, W3, W4, W5)
    ).

is_question1([X]):-
	question_list1(L),
	member(X, L).

is_question2([X]):-
	question_list2(L),
	member(X, L).

is_prist([X]):-
	prist_list(L),
	member(X, L).

is_is([X]):-
	is_lists(L),
	member(X, L).

question_list1(L):-
	L = ['Does', 'does']. 

question_list2(L):-
    L = ['Who', 'who']. 

prist_list(L):-
	L = ['of', 'have'].

is_lists(L):-
	L = ['is', 'are'].

res1([Relation], [Person1], [Person2]):-
	relative(Relation, Person1, Person2),
	write('Yes, '), write(Person1), write(' is '), write(Relation), write(' of '), write(Person2), nl.

res1([Relation], [Person1], [Person2]):-
	not(relative(Relation, Person1, Person2)),
	atomic(Relation),
	write('No, '), write(Person1), write(' isn\'t '), write(Relation), write(' of '), write(Person2), nl.

res1([Relation], [Person1], [Person2]):-
	not(relative(Relation, Person1, Person2)),
	not(atomic(Relation)),
	write('No, '), write(Person1), write(' isn\'t in relation with anybody'), nl.

res2([Relation], [Person1], [Person2]):-
	relative(Relation, Person1, Person2),
	write(Person1), write(' is '), write(Relation), write(' of '), write(Person2), nl.




