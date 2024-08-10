The CoAP socket will restart at the client whenever there is a time sync issue.
If the Delay client because unsynchronized in the middle of the experiment,
no more packets will be sent, even when the client becomes time sycned again.

Solution is to print out an error message when this happens so I know that
I need to rerun the experiment.