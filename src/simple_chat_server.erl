-module(simple_chat_server).
-export([start/0, stop/0, loop/1]).

start() ->
	ServerPid = spawn(?MODULE, loop, [[]]),																	
	register(?MODULE, ServerPid).											%Pid = serverov pid

stop() ->																	%terminacija servera
	?MODULE ! shutdown.
	
loop(ListOfUser) ->
	receive
		{Pid, subscribe} ->
			io:format("Server detected user login!~n"),
			loop([Pid | ListOfUser]);
		{Pid, unsubscribe} ->
			loop(lists:delete(Pid, ListOfUser));
		{Msg, msg} ->
			lists:foreach(fun(PiD) -> PiD ! {Msg, from_server} end, ListOfUser),
			loop(ListOfUser);
		shutdown ->
			exit(io:format("Server has "))
	end.
	