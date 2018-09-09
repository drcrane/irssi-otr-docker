Simple irssi-otr Docker Image
=============================

Building
--------

    docker build --tag irssi-otr:latest .

Running
-------

You should make a directory `$HOME/.irssi` so you can save your
settings, private keys etc.

    docker run -it --name my-running-irssi -e TERM \
        -u $(id -u):$(id -g) --log-driver=none \
	-v $HOME/.irssi:/home/user/.irssi:rw \
	-v /etc/localtime:/etc/localtime:ro irssi-otr

To use OTR, first load it:

    /load otr

Add the notification in the bottom of your chatting window:

    /statusbar window add otr

Then when in a chat you want to keep private:

    /otr init

If you have no keys they will be generated and saved in
`$HOME/.irssi/otr`... pretty useful.

That is all very brief so please see the project's README file
on GitHub.

