%%%-------------------------------------------------------------------
%%% @author anton
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. maj 2021 16:25
%%%-------------------------------------------------------------------
-module(pollution_tests).
-author("anton").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([]).

adding_getting_value_test()->
  D = pollution:createMonitor(),
  D1 = pollution:addStation("Ala",{3,3},D),
  D2 = pollution:addValue("Ala", {{2000,5,13},{13,13}},"Pm10",12,D1),
  12 = pollution:getOneValue("Ala",{2000,5,13},"Pm10",D2),
  error = pollution:getOneValue("Ala",{2001,5,12},"Pm10",D2).

adding_getting_remove_value_test()->
  D = pollution:createMonitor(),
  D1 = pollution:addStation("Ala",{3,3},D),
  D2 = pollution:addValue("Ala", {{2000,5,13},{13,13}},"Pm10",12,D1),
  12 = pollution:getOneValue("Ala",{2000,5,13},"Pm10",D2),
  D3 = pollution:removeValue("Ala", {{2000,5,13},{13,13}},"Pm10",D2).

getting_mean_test()->
  D = pollution:createMonitor(),
  D1 = pollution:addStation("Ala",{3,3},D),
  D2 = pollution:addValue("Ala", {{2000,5,13},{13,13}},"Pm10",5,D1),
  D3 = pollution:addValue("Ala", {{2000,6,13},{13,13}},"Pm10",1,D2),
  D4 = pollution:addValue("Ala", {{2000,7,13},{13,13}},"Pm10",6,D3),
  4.0 = pollution:getStationMean("Ala","Pm10",D4).

air_quality_test()->
  D = pollution:createMonitor(),
  D1 = pollution:addStation("Ala",{3,3},D),
  D2 = pollution:addValue("Ala", {{2000,5,13},{13,13,12}},"PM10",5,D1),
  D3 = pollution:addValue("Ala", {{2000,5,13},{13,23,12}},"PM10",1,D2),
  D4 = pollution:addValue("Ala", {{2000,5,13},{13,33,12}},"PM10",6,D3),
  12.0 = pollution:getAirQualityIndex({3,3},{{2000,5,13},{13,33,12}},D4).

get_max_test()->
  D = pollution:createMonitor(),
  D1 = pollution:addStation("Ala",{3,3},D),
  D2 = pollution:addValue("Ala", {{2000,5,13},{13,13,12}},"PM10",5,D1),
  D3 = pollution:addValue("Ala", {{2000,5,13},{13,23,12}},"PM10",6,D2),
  D4 = pollution:addValue("Ala", {{2000,5,13},{13,33,12}},"PM10",1,D3),
  6 = pollution:getMax({3,3},"PM10",D4).

get_min_test()->
  D = pollution:createMonitor(),
  D1 = pollution:addStation("Ala",{3,3},D),
  D2 = pollution:addValue("Ala", {{2000,5,13},{13,13,12}},"PM10",5,D1),
  D3 = pollution:addValue("Ala", {{2000,5,13},{13,23,12}},"PM10",1,D2),
  D4 = pollution:addValue("Ala", {{2000,5,13},{13,33,12}},"PM10",2,D3),
  1 = pollution:getMin({3,3},"PM10",D4).


