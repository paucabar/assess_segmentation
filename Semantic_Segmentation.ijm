#@ String (label=" ", value="<html><font size=6><b>Assess Segmentation</font><br><font color=teal>Intersection over Union (IoU)</font></b></html>", visibility=MESSAGE, persist=false) heading
#@ File(label="Select dir (target):", persist=true, style="directory") dirTarget
#@ File(label="Select dir (prediction):", persist=true, style="directory") dirPrediction
#@ String (label="Postfix", value="_prediction", persist=false) postfix
#@ String (label="Extension", choices={"tif", "png"}, value="tif", persist=true, style="listBox") extension
#@ String (label="<html>Black Background:</html>", choices={"Yes", "No"}, value="Yes", persist=true, style="radioButtonHorizontal") background
#@ String (label=" ", value="<html><img src=\"https://live.staticflickr.com/65535/48557333566_d2a51be746_o.png\"></html>", visibility=MESSAGE, persist=false) logo
#@ String (label=" ", value="<html><font size=2><b>Neuromolecular Biology Lab</b><br>ERI BIOTECMED, Universitat de València (Valencia, Spain)</font></html>", visibility=MESSAGE, persist=false) message

// set background
if (background == "Yes") {
	setOption("BlackBackground", true);
} else {
	setOption("BlackBackground", false);
}

// get file list & define variables
listTarget=getFileList(dirTarget);
intersectionArea=0;
unionArea=0;

// create results table
title1 = "Results table";
title2 = "["+title1+"]";
f = title2;
run("Table...", "name="+title2+" width=600 height=500");
headings="\\Headings:n\tFilename\tIntersection\tUnion\tIoU";
print(f, headings);

// batch mode
setBatchMode(true);
for (i=0; i<listTarget.length; i++) {
	if (endsWith(listTarget[i], extension)) {
		open(dirTarget+File.separator+listTarget[i]);
		rename("target");
		indexDot=indexOf(listTarget[i], ".");
		filenameTarget=substring(listTarget[i], 0, indexDot);
		open(dirPrediction+File.separator+filenameTarget+postfix+"."+extension);
		rename("prediction");
		// intersection over union
		run("Set Measurements...", "area redirect=None decimal=2");
		imageCalculator("AND create", "target", "prediction");
		rename("intersection");
		run("Analyze Particles...", "pixel summarize");
		IJ.renameResults("Summary", "Results");
		intersectionArea=getResult("Total Area", 0);
		run("Close");
		imageCalculator("OR create", "target", "prediction");
		rename("union");
		run("Analyze Particles...", "pixel summarize");
		IJ.renameResults("Summary", "Results");
		unionArea=getResult("Total Area", 0);
		run("Close");
		//imageCalculator("XOR create", "target", "prediction");
		//rename("disjunctive union");
		run("Close All");
		//fill results table
		IoU=intersectionArea/unionArea;
		n=d2s(i+1, 0);
		rowData= n + "\t" + listTarget[i] + "\t" + intersectionArea + "\t" + unionArea + "\t" + IoU;
		print(f, rowData);
	}
}

selectWindow("Results table");
saveAs("Text", dirPrediction+File.separator+"ResultsTable_IoU.csv");