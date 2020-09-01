#@ String (label=" ", value="<html><font size=6><b>Assess segmentation</font><br><font color=teal>Semantic & Instance</font></b></html>", visibility=MESSAGE, persist=false) heading
#@ File(label="Select dir (target):", persist=true, style="directory") dirTarget
#@ File(label="Select dir (prediction):", persist=true, style="directory") dirPrediction
#@ String (label="Postfix", value="_prediction", persist=false) postfix
#@ String (label="Extension", choices={"tif", "png"}, value="tif", persist=true, style="listBox") extension
#@ String (label="<html>Black Background:</html>", choices={"Yes", "No"}, value="Yes", persist=true, style="radioButtonHorizontal") background
#@ String (label=" ", value="<html><img src=\"https://live.staticflickr.com/65535/48557333566_d2a51be746_o.png\"></html>", visibility=MESSAGE, persist=false) logo
#@ String (label=" ", value="<html><font size=2><b>Neuromolecular Biology Lab</b><br>ERI BIOTECMED, Universitat de València (Valencia, Spain)</font></html>", visibility=MESSAGE, persist=false) message

// set up
if (background == "Yes") {
	setOption("BlackBackground", true);
} else {
	setOption("BlackBackground", false);
}
setOption("ExpandableArrays", true);
roiManager("reset");
print("\\Clear");

// get file list
listTarget=getFileList(dirTarget);

// batch mode
//setBatchMode(true);
for (i=0; i<listTarget.length; i++) {
	if (endsWith(listTarget[i], extension)) {
		open(dirTarget+File.separator+listTarget[i]);
		rename("target");
		indexDot=indexOf(listTarget[i], ".");
		filenameTarget=substring(listTarget[i], 0, indexDot);
		open(dirPrediction+File.separator+filenameTarget+postfix+"."+extension);
		rename("prediction");

		// get starting coordinates from target
		scTarget=getStartingCoordinates("target");
		arrayLength=scTarget.length;
		targetX=Array.slice(scTarget,0,arrayLength/2-1);
		targetY=Array.slice(scTarget,arrayLength/2,arrayLength-1);
		run("Clear Results");
		//selectImage("target");
		//makeSelection("point", targetX, targetY);

		// get starting coordinates from prediction
		scPrediction=getStartingCoordinates("prediction");
		arrayLength=scPrediction.length;
		predictionX=Array.slice(scPrediction,0,arrayLength/2-1);
		predictionY=Array.slice(scPrediction,arrayLength/2,arrayLength-1);
		run("Clear Results");
		//selectImage("prediction");
		//makeSelection("point", predictionX, predictionY);

		// get the RCC image
		run("RCC8D UF Multi", "x=target y=prediction show=RCC5D details");
		selectImage("RCC");
		getDimensions(widthRCC, heightRCC, channelsRCC, slicesRCC, framesRCC);

		// create IC image (instance segmentation)
		newImage("IC", "8-bit black", widthRCC, heightRCC, 1);
		run("glasbey ");
		
		// fill the IC table
		for (x=0; x<widthRCC; x++) {
			for (y=0; y<heightRCC; y++) {
				
				// get the code
				selectImage("RCC");
				code=getPixel(x, y);
				
				// get ROIs of connected objects on the 'prediction' 
				if (code!=0) {
					selectImage("prediction");
					doWand(predictionX[y], predictionY[y]);
					roiManager("add");
					roiCount=roiManager("count");
					roiManager("select", roiCount-1);
					roiManager("rename", y);
				}
			}

			// compare
			roiCount=roiManager("count");
			if (roiCount != 0) {
				roiManager("deselect");
				roiManager("combine");
				run("Create Mask");
				rename("connected_masks");
				selectImage("target");
				doWand(predictionX[x], predictionY[x]);
				run("Create Mask");
				rename("assessed_object");
				exit();
			}
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////

// get the starting coordinates of the objects on a binary mask
function getStartingCoordinates (image) {
	selectImage(image);
	run("Particles8 ", "white show=Particles minimum=0 maximum=9999999 display redirect=None");
	scX=newArray(nResults);
	scY=newArray(nResults);
	for (a=0; a<scX.length; a++) {
		scX[a]=getResult("XStart", a);
		scY[a]=getResult("YStart", a);
		scConcat=Array.concat(scX,scY);
	}
	return scConcat;
}