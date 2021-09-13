%%%-------------------------------------------------------------------
%%% @author anton
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. maj 2021 19:15
%%%-------------------------------------------------------------------
-module(pollution_value_collector_gen_statem).
-author("anton").
-behaviour(gen_statem).
%% API
-export([start_link/0, stop/0, set_station/1, add_value/3, store_data/0, init/1, s_set_station/3, callback_mode/0, s_add_value/3, terminate/3]).

%% PUBLIC API
set_station(Key) -> gen_statem:cast(serv_statem, {s_set_station,Key}).
add_value(Date,Type, Value) -> gen_statem:cast(serv_statem, {s_add_value,Date,Type,Value}).
store_data() -> gen_statem:cast(serv_statem, {s_flush}).

start_link() ->
  gen_statem:start_link({local, serv_statem}, ?MODULE, [], []).
init([]) -> {ok, s_set_station, []}.
callback_mode()->state_functions.
%% HANDLERS

s_set_station(_Event,{s_set_station,Key},[])->{next_state,s_add_value,[Key]}.

s_add_value(_Event,{s_add_value,Date,Type,Value},Tab)->{next_state,s_add_value,Tab++[{Date,Type,Value}]};
s_add_value(_Event,{s_flush},[Key])->{next_state,s_set_station,[]};
s_add_value(_Event,{s_flush},[Key,{Date,Type,Value}|T])->
  pollution_gen_server:addValue(Key,Date,Type,Value),
  s_add_value(_Event,{s_flush},[Key]++T).

stop()->gen_statem:stop(serv_statem).

terminate(Reason, StateName, StateData) -> ok.