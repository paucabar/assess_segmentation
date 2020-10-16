# Assess Segmentation

## Description

This repository contains tools to evaluate image segmentation models for both semantic and instance segmentation. The first one is easier to assess, since semantic segmentation just produce a mask assigning different classess to pixels. However, instance segmentation is more complicate to assess, since it has the aim to identify objects in the image. For example, semantic segmentation can be used to distinguish between background or cell pixels, while instance segmentation allows to count the number of cells and quantify the desired features per cell (e.g., size, shape, intensity...).

On one hand, the macro to assess semantic segmentation calculates the Intersection over Union (IoU) of the target and the prediction masks. On the other hand, the macro to assess instance segmentation calculates the F1 Score for a given IoU threshold.

Learn more about [methods to evaluate image segmentation models](https://www.jeremyjordan.me/evaluating-image-segmentation-models/).

## Requirements

* [Fiji](https://fiji.sc/)
* [RCC8D plugin](https://blog.bham.ac.uk/intellimic/spatial-reasoning-with-imagej-using-the-region-connection-calculus/)

## Installation

1. Start [FIJI](https://fiji.sc/)
2. Start the **ImageJ Updater** (<code>Help > Update...</code>)
3. Click on <code>Manage update sites</code>
4. Click on <code>Add update site</code>
5. A new blank row is to be created at the bottom of the update sites list
6. Type **NeuroMol Lab** in the **Name** column
7. Type **http://sites.imagej.net/Paucabar/** in the **URL** column
8. <code>Close</code> the update sites window
9. <code>Apply changes</code>
10. Restart FIJI
11. Check if <code>NeuroMol Lab</code> appears now in the <code>Plugins</code> dropdown menu (note that it will be hidden at the bottom of the plugin list)

## Test Dataset

Download an [example dataset](https://drive.google.com/drive/folders/1GWtc_4BzsjopVYPYSRw-dscO7DxhoTPq?usp=sharing).

**Brief description of the dataset:**

The example dataset consists in two sets of binary images: i) the target folder contains a ground truth and ii) the prediction folder contains the segmentation output to be assessed. On one hand, the different target images are duplicates of the same image. On the other hand, each prediction mask presents different levels of segmentation quality: i) The prediction for Mask1 is just a duplicate of the ground truth, so represents the ideal segmentation; ii) The prediction for Mask2 is not perfectly alineated with the ground truth, but contains most of the expected objects (just 1 missing iobject and 1 added object); iii) The prediction for Mask3 contains merging and splitting events, in addition to the already mentioned alignment problems. 

![image](https://user-images.githubusercontent.com/39589980/96153231-bd4f1480-0f0d-11eb-88a7-1b34a405e3ef.png)

Colored images show the intersection between the ground truth and the different prediction masks: green = ground truth; red = prediction; yellow = intersection.

## Usage

## Data Preparation

* Use ImageJ binary images, i.e., 8-bit images containing only 0 (background) and 255 (object) pixels.
* Store target and prediction masks on separated folders.
* Prediction masks should be named adding a tag after the target filename. E.g., if the target filename is _Mask1_, the corresponding prediction filename could be _Mask_prediction_.

## Semantic Segmentation

1. Run the **Semantic Segmentation** macro (<code>Plugins > NeuroMol Lab > Assess Segmentation > Semantic Segmentation</code>)
2. Select the directory containing the target images (ground truth)
3. Select the directory containing the prediction images
4. Type the tag identifying the prediction images
5. Select the image format of your images
6. Set the background (black or white)
7. Ok
8. A result table (.csv) will be saved within the target folder.

## Instance Segmentation

1. Run the **Instance Segmentation** macro (<code>Plugins > NeuroMol Lab > Assess Segmentation > Instance Segmentation</code>)
2. Select the directory containing the target images (ground truth)
3. Select the directory containing the prediction images
4. Type the tag identifying the prediction images
5. Select the image format of your images
6. Set the threshold of the IoU
7. Set the background (black or white)
8. Ok
9. A result table (.csv) will be saved within the target folder.
