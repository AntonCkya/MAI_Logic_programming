sub_start([X|_], [X]).

sub_start([X|LT], [X|ST]) :-
  sub_start(LT, ST).

sub_start([_|T], S) :-
  sub_start(T, S).

% Перебор подмножеств множества L
sublist(L, S) :-
  sub_start(L, S).

sublist([_|T], S) :-
  sublist(T, S).

for(I, I, _).
for(I, CUR, TO):-
  CUR < TO, 
  CUR1 is CUR+1, 
  for(I, CUR1, TO).

% Делит 20 рублей на 3 разных части
% % M - Маргарита, F - отец, A - Алёша
create_the_list([M, F, A]) :-
  % Разделите свои деньги каждая на три разные части. 
  % Даша потратила на подарок для дяди Алеши меньше всех - 3 рубля. 
  for(A, 3, 20), 
  for(F, 3, 20),
  for(M, 3, 20),
  % На подарки для дяди Алеши расходуйте наименьшую часть денег. 
  A < F,
  % На подарки для отца тратьте среднюю из частей. 
  F < M,
  % А самые дорогие подарки покупайте для тети Маргариты. 
  % Каждая из вас может истратить по двадцати рублей. 
  20 is M + F + A.

% sum_by_idx(List, I, Sum) - Сумма i-х элементов элементов списка List
sum_by_idx([], _, 0).
sum_by_idx([H|T], I, S) :-
  % nth0(индекс, список, элемент)
  nth0(I, H, V),
  sum_by_idx(T, I, S1),
  S is S1 + V.

check_only_one_dasha(S) :-
  setof([M, F, 3], member([M, F, 3], S), L),
  length(L, 1).

launch :-
  % Только постарайтесь разделить деньги каждая по-разному".
  setof(X, create_the_list(X), L),
  % Перебираем подмножества девушек.
  sublist(L, S),
  % Известно, что они израсходовали на подарки тете Маргарите в общей сложности 52 рубля. 
  sum_by_idx(S, 0, 52),
  % Но Даша, по условию задачи, должна быть одна.
  check_only_one_dasha(S),
  % Сколько денег израсходовали девушки на подарки для отца?
  sum_by_idx(S, 1, F),
  write("The amount of money spent on gifts for the father: "), write(F), nl, !.

