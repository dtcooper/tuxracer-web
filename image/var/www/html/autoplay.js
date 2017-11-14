/* Append an <audio> element to the bottom of the screen and stream */
var audioElem = document.createElement('audio');
document.body.appendChild(audioElem);
audioElem.src = '/audio.ogg';
audioElem.play();
