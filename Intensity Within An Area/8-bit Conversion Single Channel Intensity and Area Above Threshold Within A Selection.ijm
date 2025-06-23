//Set Max Value
Dialog.create("Maximum Brightness Value")
		Dialog.addMessage("If converting from a 12 or 16 bit image to 8 bit, enter the appropriate maximum brightness value");
			Dialog.addNumber("Maximum Value", "");
			Dialog.show();
			maxvalue = Dialog.getNumber();

//Set Threshold Value
Dialog.create("Threshold Value")
		Dialog.addMessage("If converting from a 12 or 16 bit image to 8 bit, enter the appropriate maximum brightness value");
			Dialog.addNumber("Threshold Value", "");
			Dialog.show();
			threshold_value = Dialog.getNumber();
	
//Closing any open tabs or rois or results
run("ROI Manager...");
if (RoiManager.size > 0) {
	roiManager("Deselect");
	roiManager("Delete");
	run("Close");
	}
run("Clear Results");
close("Results");
close("*");


//selecting the file
Dialog.create("Choose your file");
	Dialog.addDirectory("Choose your file", "");
	Dialog.show();
folder = Dialog.getString();
result_csv_file = "Summary.csv";

//retrieve all files in the folder in an array
filelist = getFileList(folder);
run("Colors...", "background=black");
run("Set Measurements...", "area mean modal min display redirect=None decimal=3" );
RoiManager.useNamesAsLabels(true);

//setting a loop for each image in the file 
//Note:the file suffix listed below is ".tif" you can change that depending on your image file type
for (i = 0; i < lengthOf(filelist); i++) {
	image_file = filelist [i];
	if ( endsWith(image_file, ".tif")) {

		open(folder + image_file);

	//create a 8-bit visible display of the image
	selectImage(image_file);
	run("Duplicate...", " ");
	rename(image_file + " 8-bit");
	setMinAndMax(0, maxvalue);
	run("Apply LUT");
	saveAs(folder + image_file + " 8-bit");

	//select out desired area
	selectImage(image_file + " 8-bit");
	waitForUser("Select the desired area. Click OK when you are done");
	roiManager("Add");
	
	//create cropped image of selected area
	roiManager("Select", i*2);
	run("Clear Outside");
	saveAs(folder + image_file + " cropped");	

	//measure Full Selected Area and Brightness
	selectImage(image_file);
	roiManager("Select", i*2);
	roiManager("Rename", image_file);
	run("Clear Outside");
	roiManager("Measure");
	max_in_selected_area = getResult("Max", nResults-1);
	roiManager("Deselect");

	//measure Area Above Threshold Value
	if (max_in_selected_area > threshold_value) {
	setThreshold(threshold_value,65535);
	run("Create Selection");
	roiManager("Add");
	roiManager("Select", (i*2)+1);
	rename(image_file + " Area Above Threshold");
	roiManager("Rename", image_file + " Area Above Threshold");
	roiManager("Measure");
	area_above_threshold_value = getResult("Area", nResults-1);
	setResult("Area Above Threshold", nResults-2, area_above_threshold_value);
	Table.deleteRows(nResults-1, nResults-1);
	} 
	else {
	roiManager("Add");
	roiManager("Select", (i*2)+1);
	rename(image_file + " Area Above Threshold");
	roiManager("Measure");
	setResult("Area Above Threshold", nResults-2, 0);
	Table.deleteRows(nResults-1, nResults-1);
	}
	}}

//Save Data Table
saveAs("Results", folder + result_csv_file);
	
//Close all open tabs 
//Note:You can remove the following 4 lines if you would like to leave the images open 
close("*");
close("Results");
close("ROI Manager");
close("Threshold");