
%%%-------------------------------------------------------------------
%%% @author anton
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. maj 2021 18:57
%%%-------------------------------------------------------------------
-module(pol_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).


start_link() ->
  supervisor:start_link({local, varSupervisor},
    ?MODULE, []),
    unlink(whereis(varSupervisor)).

init([]) ->
  {ok, {
    #{ strategy => one_for_one, intensity => 2,
      period => 3
    },
    [#{id => 'pollution_gen_server',
      start => {pollution_gen_server, start, []},
      restart => permanent,shutdown => 2000,
      type => worker, modules => [pollution_gen_server]} ]} }.