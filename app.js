// Set constraints for the video stream
var constraints = { video: { facingMode: "user" }, audio: false };
// Define constants
const cameraView = document.querySelector("#camera--view"),
    cameraOutput = document.querySelector("#camera--output"),
    cameraSensor = document.querySelector("#camera--sensor"),
    cameraTrigger = document.querySelector("#camera--trigger")
	
	
	function is_touch_device() {
  var prefixes = ' -webkit- -moz- -o- -ms- '.split(' ');
  var mq = function(query) {
    return window.matchMedia(query).matches;
  }

  if (('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch) {
    return true;
  }

  // include the 'heartz' as a way to have a non matching MQ to help terminate the join
  // https://git.io/vznFH
  var query = ['(', prefixes.join('touch-enabled),('), 'heartz', ')'].join('');
  return mq(query);
}

// Access the device camera and stream to cameraView
function cameraStart() {
	alert(is_touch_device());
	try
	{
		//setTimeout(function(){ cameraView.removeAttribute("controls"); }, 1000);
		
    navigator.mediaDevices
        .getUserMedia(constraints)
        .then(function(stream) {
        track = stream.getTracks()[0];
        cameraView.srcObject = stream;
    });
		
	}
    catch(error) {
        //console.error("Oops. Something is broken.", error);
		$("#camera").hide();
		$("#imgInp").show();
		$("#blah").show();
    };
}
// Take a picture when cameraTrigger is tapped
cameraTrigger.onclick = function() {
    //cameraSensor.width = cameraView.videoWidth;
    //cameraSensor.height = cameraView.videoHeight;
    cameraSensor.getContext("2d").drawImage(cameraView, 0, 0, 270, 350);
    //cameraOutput.src = cameraSensor.toDataURL("image/webp");
    //cameraOutput.classList.add("taken");
};
// Start the video stream when the window loads
window.addEventListener("load", cameraStart, false);