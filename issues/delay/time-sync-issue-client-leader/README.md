If the Delay Client is started *before* the Delay Server, an issue may arise where the first few Delays recoreded
by the client will be significantly longer than the other Delays.

The best fix I found so far is to start the Delay Server first, and make sure it is in a Thread network by itself
as the leader. Then, after doing so, I can start the Delay Client.