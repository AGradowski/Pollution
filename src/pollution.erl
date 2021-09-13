-module(pollution).
-author("anton").


%% API
-export([createMonitor/0, addStation/3,addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3,getAirQualityIndex/3
  ,getMax/3, getMin/3]).

%I added getMax/3 i getMin/3, ktore zwracaja oddpowiednio najwieksza i najmniejsza wartosc dla zadanych koordynatow
% i dla zadanego typu



%dane przechowuje w slowniku dict, w ktorym przechowuje dwukrtnie kazda stacje, raz pod kluczem nazwy, a raz pod kluczem
% wspolrzednych. Wartosci pod kluczem sa postaci [Name, {X,Y}, {Date, Type, Val}], kolejne pomiary sa dodawnae do tablicy
%tablic wartosci



createMonitor()
  ->dict:new().

addStation(Name, {X,Y},D)->
  addStationHelp(dict:find(Name,D),dict:find({X,Y},D),Name,{X,Y},D).

addStationHelp(error,error,Name, {X,Y},D)->
  D1 = dict:append(Name, [Name,{X,Y}, {}],D),
  D2 = dict:append({X,Y},[Name,{X,Y},{}],D1),
  D2;

addStationHelp(_,_,_,_,D)->
  io:fwrite("station already exists\n"),
  D.

addValue({X,Y},Date,Type,Val,D)->
  addValueHelp(dict:find({X,Y},D),{Date,Type,Val},D, 0,{0,0});

addValue(Name,Date,Type,Val,D)->
  addValueHelp(dict:find(Name,D),{Date,Type,Val},D,0,{0,0}).



addValueHelp(error,_,D,_,_)->
  io:fwrite("station does not exist\n"),
  D;

%first data
addValueHelp({ok,[[Name, {X,Y},{}]]},{Date,Type,Val},D,_,_)->
  D1 = dict:append(Name, [Name,{X,Y},{Date,Type,Val}],D),
  D2 = dict:append({X,Y},[Name,{X,Y},{Date,Type,Val}],D1),
  D2;

addValueHelp({ok,[]},{Date,Type,Val},D,Name,{X,Y})->
  D1 = dict:append(Name, [Name,{X,Y},{Date,Type,Val}],D),
  D2 = dict:append({X,Y},[Name,{X,Y},{Date,Type,Val}],D1),
  D2;

addValueHelp({ok,[[Name, {X,Y},{DateIn, TypeIn,_}]|Tail]},{Date,Type,Val},D, _,_)->
  if
    (DateIn == Date) and (TypeIn == Type)->io:fwrite("recor already in\n") ,D;
    true -> addValueHelp({ok,Tail},{Date,Type,Val},D,Name,{X,Y})
  end;

addValueHelp({ok,[[Name, {X,Y},{}]|Tail]},{Date,Type,Val},D, _,_)->
  addValueHelp({ok,Tail},{Date,Type,Val},D,Name,{X,Y}).


removeValue(Name,Date,Type,D)->
  check_inside(dict:find(Name,D),Date,Type,D).



check_inside(error,_,_,D)->
  io:fwrite("station does not exist\n"),
  D;

check_inside({ok,[[Name, {X,Y},_]|_]},Date,Type,D)->
  D1 = dict:store(Name,removeValueHelp(dict:find(Name,D),{Date,Type}),D),
  D2 = dict:store({X,Y},removeValueHelp(dict:find({X,Y},D1),{Date,Type}),D1),
  D2.

removeValueHelp({ok,[]},{_,_})->
  [];

removeValueHelp({ok,[[Name, {X,Y},{}]]},{_,_})->
  [[Name, {X,Y},{}]];

removeValueHelp({ok,[[Name, {X,Y},{}]|Tail]},{Date,Type})->
  [[[Name, {X,Y},{}]|removeValueHelp({ok,Tail},{Date,Type})]];

removeValueHelp({ok,[[Name, {X,Y},{DateIn, TypeIn,Val}]|Tail]},{Date,Type})->
  if
    (DateIn==Date) and (TypeIn == Type) -> [Tail];
    true -> [[[Name, {X,Y},{DateIn, TypeIn,Val}]|removeValueHelp({ok,Tail},{Date,Type})]]
  end.

getOneValue({X,Y},Date,Type,D)->
  getOneValueHelp(dict:find({X,Y},D),{Date,Type},D);

getOneValue(Name,Date,Type,D)->
  getOneValueHelp(dict:find(Name,D),{Date,Type},D).



getOneValueHelp(error,_,_)->
  error;

getOneValueHelp({ok,[]},{_,_},_)->
  error;

getOneValueHelp({ok,[[_, {_,_},{}]]},{_,_},_)->
  error;

getOneValueHelp({ok,[[_, {_,_},{DateIn, TypeIn,Val}]|Tail]},{Date,Type},D)->
  {Day,_} = DateIn,
  if
    (Day==Date) and (TypeIn == Type) -> Val;
    true -> getOneValueHelp({ok,Tail},{Date,Type},D)
  end;

getOneValueHelp({ok,[[_, {_,_},{}]|Tail]},{Date,Type},D)->
  getOneValueHelp({ok,Tail},{Date,Type},D).

getStationMean({X,Y},Type,D)->
  getStationMeanHelp(dict:find({X,Y},D),Type,0,0);

getStationMean(Name,Type,D)->
  getStationMeanHelp(dict:find(Name,D),Type,0,0).

getStationMeanHelp(error,_,_,_)->
  io:fwrite("station does not exist\n"),
  error;

getStationMeanHelp({ok,[[_, {_,_},{}]]},_,_,_)->
  error;

getStationMeanHelp({ok,[]},_,Acc,Nr)->
  Acc/Nr;

getStationMeanHelp({ok,[[_, {_,_},{}]|Tail]},Type,Acc,Nr)->
  getStationMeanHelp({ok,Tail},Type,Acc,Nr);

getStationMeanHelp({ok,[[_, {_,_},{_,TypeIn,Val}]|Tail]},Type,Acc,Nr)->
  if
    (TypeIn == Type) ->getStationMeanHelp({ok,Tail},Type,Acc+Val,Nr+1);
    true -> getStationMeanHelp({ok,Tail},Type,Acc,Nr)
  end.

getDailyMean(Type, Date, D)->
  getDailyMeanHelp(dict:fetch_keys(D),Type,Date,D,0,0,error).

getDailyMeanHelp([],_,_,_,Acc,Nr,Last)->
  if
    (Last == error) -> Acc/Nr;
    true -> (Acc +Last)/ (Nr+1)
  end;

getDailyMeanHelp([{X,Y}|Tail],Type,Date,D,Acc,Nr,Last)->
  if
    (Last == error) -> getDailyMeanHelp(Tail,Type,Date,D,Acc,Nr,getOneValue({X,Y},Date,Type,D));
    true -> getDailyMeanHelp(Tail,Type,Date,D,Acc+Last,Nr+1,getOneValue({X,Y},Date,Type,D))
  end;

getDailyMeanHelp([_|Tail],Type,Date,D,Acc,Nr,Last)->
  getDailyMeanHelp(Tail,Type,Date,D,Acc,Nr,Last).

%znajduje wartosc indeksu jakosci powietrza(max z procentowych stezen zanieczyszczen) dla zadanych
%wspolrzednych i daty dziennej i godziny


getAirQualityIndex({X,Y},{Date,{H,_,_}},D)->
  getMaxVal(dict:find({X,Y},D),Date,H,0).

getMaxVal(error, _,_,_)->
  io:fwrite("station does not exist\n"),
  error;

getMaxVal({ok,[]},_,_,Acc)->
  Acc;

getMaxVal({ok,[[_, {_,_},{}]]},_,_,_)->
  error;

getMaxVal({ok,[[_, {_,_},{}]|Tail]},Date,Hour,Acc)->
  getMaxVal({ok,Tail},Date,Hour,Acc);



getMaxVal({ok,[[_, {_,_},{DateIn,TypeIn,Val}]|Tail]},Date,Hour,Acc)->
  {Dat,{H,_,_}} = DateIn,
  Density = getDensity(TypeIn,Val),
  if
    (Density > Acc) and(Dat ==Date) and(H ==Hour) -> getMaxVal({ok,Tail},Date,Hour,Density);
    true -> getMaxVal({ok,Tail},Date,Hour,Acc)
  end.





%dane ze strony https://powietrze.gios.gov.pl/pjp/content/annual_assessment_air_acceptable_level

getDensity(TypeIn,Val)->
  case TypeIn of
    "PM10"->(Val / 50) *100;
    "PM2,5"->(Val / 25) * 100;
    "C6H6"->(Val / 5)*100;
    "NO2"->(Val / 200)*100;
    "SO2"->(Val / 350)*100;
    "CO"->(Val/10000)*100;
    "Pb"->(Val / 0.5)*100;
    _->0
  end.

%znajduje Maksymalna wartosc zadanego pomiaru
getMax({X,Y},Type,D)->
  getMaxHelp(dict:find({X,Y},D), Type, 0).

getMaxHelp(error,_,_)->
  error;

getMaxHelp({ok,[]},_,Acc)->
  Acc;

getMaxHelp({ok,[[_, {_,_},{}]]},_,_)->
  error;

getMaxHelp({ok,[[_, {_,_},{}]|Tail]},Type,Acc)->
  getMaxHelp({ok,Tail},Type,Acc);

getMaxHelp({ok,[[_, {_,_},{_,TypeIn,Val}]|Tail]} ,Type ,Acc)->
  if
    (TypeIn == Type) and (Val > Acc)->getMaxHelp({ok,Tail},Type, Val);
    true -> getMaxHelp({ok,Tail},Type, Acc)
  end.

%znajduje Minimalna wartosc zadanego pomiaru
getMin({X,Y},Type,D)->
  getMinHelp(dict:find({X,Y},D), Type, getMax({X,Y},Type,D)).

getMinHelp(error,_,_)->
  error;

getMinHelp({ok,[]},_,Acc)->
  Acc;

getMinHelp({ok,[[_, {_,_},{}]]},_,_)->
  error;

getMinHelp({ok,[[_, {_,_},{}]|Tail]},Type,Acc)->
  getMinHelp({ok,Tail},Type,Acc);

getMinHelp({ok,[[_, {_,_},{_,TypeIn,Val}]|Tail]} ,Type ,Acc)->
  if
    (TypeIn == Type) and (Val < Acc)->getMinHelp({ok,Tail},Type, Val);
    true -> getMinHelp({ok,Tail},Type, Acc)
  end.

