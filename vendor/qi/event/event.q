\d .event

handlers:(0#`)!()
fire:{[event;arg] handlers[event]@\:arg;}
addhandler:{[event;handler] c:count handlers event;.[`.event;(`handlers;event);union;handler];if[c=0;event set fire event]}

\d .
