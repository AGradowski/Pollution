-module(pollution_gen_server).
-behaviour(gen_server).


-export([start/0,stop/0,addStation/2,addValue/4,
  getOneValue/3, removeValue/3, getStationMean/2,
  getDailyMean/2, getAirQualityIndex/2, getMax/2, getMin/2]).

-export([init/1,handle_call/3,handle_cast/2,terminate/2,crash/0]).

start()->
  gen_server:start_link(
    {local,?MODULE},
    ?MODULE,
    pollution:createMonitor(), []).

init(M)->
  {ok,M}.

%%interfejs klinet ->server

addStation(Name,{X,Y})->
  gen_server:call(?MODULE,{add,Name,{X,Y}}).

addValue(Key,Date,Type,Val)->
  gen_server:call(?MODULE,{addV,Key,Date,Type,Val}).

getOneValue(Key,Date,Type)->
  gen_server:call(?MODULE,{get,Key,Date,Type}).

removeValue(Key,Date,Type)->
  gen_server:call(?MODULE,{remove,Key,Date,Type}).

getStationMean(Key, Type)->
  gen_server:call(?MODULE,{getSMean,Key,Type}).

getDailyMean(Type,Date)->
  gen_server:call(?MODULE,{getDMean,Type,Date}).

getAirQualityIndex(Coord, Date)->
  gen_server:call(?MODULE, {getIndex,Coord,Date}).

getMax(Coord,Type)->
  gen_server:call(?MODULE, {getMax, Coord,Type}).

getMin(Coord,Type)->
  gen_server:call(?MODULE,{getMin,Coord,Type}).

stop()->
  gen_server:call(?MODULE,terminate).

crash()->
  gen_server:cast(?MODULE, crash).

%%wiadomosci

handle_call({add,Name,{X,Y}},_From,M)->
  {reply,ok,pollution:addStation(Name,{X,Y},M)};

handle_call({addV,Key,Date,Type,Val},_From,M)->
  {reply,ok,pollution:addValue(Key,Date,Type,Val,M)};

handle_call({get,Key,Date,Type},_From,M)->
  {reply,pollution:getOneValue(Key,Date,Type,M),M};

handle_call({remove,Key,Date,Type},_From,M)->
  {reply,pollution:removeValue(Key,Date,Type,M),M};

handle_call({getSMean,Key,Type},_From,M)->
  {reply,pollution:getStationMean(Key,Type,M),M};

handle_call({getDMean,Type,Date},_From,M)->
  {reply,pollution:getDailyMean(Type,Date,M),M};

handle_call({getIndex,Coord,Type},_From,M)->
  {reply,pollution:getAirQualityIndex(Coord,Type,M),M};

handle_call({getMax,Coord,Type},_From,M)->
  {reply,pollution:getMax(Coord,Type,M),M};

handle_call({getMin,Coord,Type},_From,M)->
  {reply,pollution:getMin(Coord,Type,M),M};

handle_call(terminate,_From,M)->{stop, normal, ok, M}.

handle_cast(crash,_)->1/0.

terminate(normal,_)->io:format("Server closed~n"), ok;
terminate(Reason,_)->io:format("Server exit~n"), Reason.



