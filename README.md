# _Wow!_ It's Tux Racer In Your Browser!

## tl;dr

Run the following in your shell on Linux or macOS,

```shell
docker run -dp 80:80 dtcooper/tuxracer-web && sleep 2 && python -m webbrowser http://localhost/
```

ZOMG! Holy moly! It's Tux Racer! What great fun! This is dumb! Yes it is! I like
exclamation marks? Probably! Okay?

## More Info

Wow! Now you can run [Extreme Tux Racer](https://sourceforge.net/projects/extremetuxracer/)
in a [Docker](https://www.docker.com/) container, playing it in your web browser
using [noVNC](http://novnc.com/) over a
[VNC](http://www.karlrunge.com/x11vnc/)-to-websocket bridge.

Why? _Because you can._ ¯\\\_(ツ)\_/¯

## Running - It's Easy Peasy Lemon Squeezy!

Make sure you have [Docker](https://www.docker.com/) installed, then run the
container exposing port `80`,

```
docker run -p 80:80 dtcooper/tuxracer-web
```

Finally, navigate to http://localhost/ in your web browser et voilà!

## Screenshot

![Screenshot](https://raw.githubusercontent.com/dtcooper/tuxracer-web/master/screenshot.png)

## Configuration

You shouldn't _need_ to configure this ridiculous piece of software, but if you
want to it's as easy as setting one of the following environment variables,

* `RESOLUTION` - Resolution in `<WIDTH>x<HEIGHT>` format, by default `800x600`.
    - Note the larger this is, the slower the container may run.
* `PASSWORD` - VNC password, by default there is none.
* `VERBOSE` - If set to `1`, spew out log information at the terminal.
* `ICECAST` - If set to `1`, use experimental [Icecast](http://icecast.org/)
  sound server. More details below.
    - Note this suffers from a **massive** delay.

For example, the following runs at `1024x768` resolution, sets the VNC password
to `shrimp`, and prints verbose log information,

```shell
docker run -p 80:80 -e RESOLUTION=1024x768 -e PASSWORD=shrimp -e VERBOSE=1 dtcooper/tuxracer-web
```

## Sound

### Out Of The Box (Icecast)

If you want to give the experimental [Icecast](http://icecast.org/) sound
backend a try, just set the environment variable `ICECAST=1`. It should start
playing in your browser. Note that this will be **massively delayed** due to
encoding and buffering by the server, as well as buffering by your browser.

```shell
docker run -p 80:80 -e ICECAST=1 dtcooper/tuxracer-web
```

### Linux

To make sound work on Linux, just expose your `/dev/snd` device while starting
up the container.

```shell
docker run -p 80:80 --device /dev/snd dtcooper/tuxracer-web
```

### macOS (Using PulseAudio)

On macOS, first install [PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/),
for example here using [Homebrew](https://brew.sh/),

```shell
brew install pulseaudio
```

Next, start PulseAudio loading the `native-protocol-tcp` module and share its
configuration directory. This way the Pulse daemon's auth cookie can be shared
with the container and it can forward sound.

```shell
pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
docker run -p 80:80 -v ~/.config/pulse:/root/.config/pulse dtcooper/tuxracer-web
```

## Running a Program In The Container

If you for some odd reason want a shell or to run a program inside of the
container, provide it as an argument. For example to shell into `bash`,

```shell
docker run -it -p 80:80 dtcooper/tuxracer-web bash
```

## Building The Container Yourself

Clone this repo and build the container,

```shell
git clone https://github.com/dtcooper/tuxracer-web
docker build -t tuxracer-web tuxracer-web
```

Finally run it locally,

```shell
docker run -p 80:80 tuxracer-web
```

That's all folks!

## Author and License

This project was created by [David Cooper](http://dtcooper.com/) and is licensed
under the MIT License. See the
[`LICENSE`](https://github.com/dtcooper/tuxracer-web/blob/master/LICENSE) file
for details.
