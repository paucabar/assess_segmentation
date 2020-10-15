#@ String (label=" ", value="<html><font size=6><b>Assess Segmentation</font><br><font color=teal>F1 Score - IoU</font></b></html>", visibility=MESSAGE, persist=false) heading
#@ File(label="Select dir (target):", persist=true, style="directory") dirTarget
#@ File(label="Select dir (prediction):", persist=true, style="directory") dirPrediction
#@ String (label="Postfix", value="_prediction", persist=false) postfix
#@ String (label="Format", choices={"tif", "png"}, value="tif", persist=true, style="listBox") format
#@ Float (label="Threshold IoU", value=0.5, max=1, min=0, stepSize=0.05, style="slider", persist=true) thresholdIoU
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
//roiManager("reset");
print("\\Clear");

// get file list
listTarget=getFileList(dirTarget);

// batch mode
//setBatchMode(true);
for (i=0; i<listTarget.length; i++) {
	if (endsWith(listTarget[i], format)) {
		print(listTarget[i]);
		open(dirTarget+File.separator+listTarget[i]);
		rename("target");
		indexDot=indexOf(listTarget[i], ".");
		filenameTarget=substring(listTarget[i], 0, indexDot);
		open(dirPrediction+File.separator+filenameTarget+postfix+"."+format);
		rename("prediction");

		// get starting coordinates from target
		scTarget=getStartingCoordinates("target");
		arrayLength=scTarget.length;
		targetX=Array.slice(scTarget,0,arrayLength/2);
		targetY=Array.slice(scTarget,arrayLength/2,arrayLength);
		run("Clear Results");
		//selectImage("target");
		//makeSelection("point", targetX, targetY);

		// get starting coordinates from prediction
		scPrediction=getStartingCoordinates("prediction");
		arrayLength=scPrediction.length;
		predictionX=Array.slice(scPrediction,0,arrayLength/2);
		predictionY=Array.slice(scPrediction,arrayLength/2,arrayLength);
		run("Clear Results");
		//selectImage("prediction");
		//makeSelection("point", predictionX, predictionY);

		// get the RCC image
		run("RCC8D UF Multi", "x=target y=prediction show=RCC5D details");
		selectImage("RCC");
		getDimensions(widthRCC, heightRCC, channelsRCC, slicesRCC, framesRCC);

		// create IC image (instance segmentation)
		newImage("IC", "8-bit black", widthRCC, heightRCC, 1);
		
		// fill the IC table
		for (x=0; x<widthRCC; x++) {

			// check for the number of objects overlapping
			nOverlap=0;
			for (y=0; y<heightRCC; y++) {
				selectImage("RCC");
				code=getPixel(x, y);
				if (code > 0) {
					nOverlap++;
				}
			}

			// if there is one or more objects overlapping
			if (nOverlap > 0) {
				selectImage("target");
				doWand(targetX[x], targetY[x]);
				run("Create Mask");
				rename("target-"+x);
				objectMatchID=-1;
				IoU=0;
				for (y=0; y<heightRCC; y++) {
					
					// find the obects (code > 0)
					selectImage("RCC");
					code=getPixel(x, y);
					
					// compare with target
					if (code!=0) {
						selectImage("prediction");
						doWand(predictionX[y], predictionY[y]);
						run("Create Mask");
						rename("prediction-"+y);

						// intersection over union
						IoU_xy=getIoU (x, y);

						// update objectMatchID & IoR
						if (IoU_xy > IoU) {
							IoU=IoU_xy;
							objectMatchID=y;
						}
					}
				}
			}
			if (IoU >= thresholdIoU) {
				selectImage("IC");
				setPixel(x, objectMatchID, 255);
			}
			if (isOpen("target-"+x)) {
				close("target-"+x);
			}
			run("Clear Results");
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

// calculate the IoU of two masks
function getIoU (a, b) {
	run("Set Measurements...", "area redirect=None decimal=2");
	imageCalculator("AND create", "target-"+a, "prediction-"+b);
	rename("intersection-"+b);
	run("Analyze Particles...", "pixel summarize");
	IJ.renameResults("Summary", "Results");
	intersectionArea=getResult("Total Area", 0);
	close("intersection-"+b);
	imageCalculator("OR create", "target-"+a, "prediction-"+b);
	rename("union-"+b);
	run("Analyze Particles...", "pixel summarize");
	IJ.renameResults("Summary", "Results");
	unionArea=getResult("Total Area", 0);
	close("union-"+b);
	IoU_iteration=intersectionArea/unionArea;
	close("prediction-"+y);
	print(a, "vs", b, IoU_iteration);
	return IoU_iteration;
}
