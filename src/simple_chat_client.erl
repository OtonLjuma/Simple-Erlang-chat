-module(simple_chat_client).
-export([user/1, subscribe/1, login/1, unsubscribe/1, send/2, init/1, loop/1]). 

%% Api functions %%
user(Name) ->									
	spawn(fun()-> init(Name) end).

subscribe(Name)->
	spawn(fun()-> login(Name) end).
	
login(Name) ->
	UserPid = user(Name),
	UserPid ! subscribe.

unsubscribe(Name) ->
	Pid = list_to_atom(string:lowercase(Name)),
	Pid ! unsubscribe.
	
send(Name, Msg) ->
	Pid = list_to_atom(string:lowercase(Name)),
	Pid ! {Msg, msg}.
	
%% Process internals %%
init(Name) ->								%init function služi za inicijalizaciju svega što ide u loop
	loop(Name).

loop(Name) ->
	receive
		subscribe ->
			register(list_to_atom(string:lowercase(Name)),self()),
			io:format("Proces spawned ~p~n",[self()]),
			io:format("User: ~p subscribe.~n",[Name]),
			simple_chat_server ! {self(), subscribe},
			loop(Name);
		unsubscribe ->
			io:format("Logged out!~n"),
			simple_chat_server ! {self(),unsubscribe},
			loop(Name);
		{Msg, msg} ->
			simple_chat_server ! {Msg, msg},
			loop(Name);
		{Msg, from_server} ->
			io:format("Message: ~p~n",[Msg]),
			loop(Name);
    end.
