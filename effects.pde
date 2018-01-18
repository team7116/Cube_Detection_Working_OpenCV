
ArrayList<MatOfPoint> contours = new ArrayList<MatOfPoint>();
ArrayList<MatOfPoint> findContoursOutput = new ArrayList<MatOfPoint>();
ArrayList<MatOfPoint> filterContoursOutput = new ArrayList<MatOfPoint>();
ArrayList<MatOfPoint> convexHullsOutput = new ArrayList<MatOfPoint>();


void effects(){
  
  opencv.useColor(HSB);
  
  input = opencv.getColor();
  
  Imgproc.cvtColor(input, output, Imgproc.COLOR_BGR2HSV);
  
  Core.inRange(output, new Scalar(huemin, satmin, minbri), new Scalar(huemax, satmax, maxbri), output);
  
  
  double blurRadius = 5.405405405405404;
  int radius = (int)(blurRadius + 0.5);
  int kernelSize;
  
  kernelSize = 2 * radius + 1;
  Imgproc.medianBlur(output, output, kernelSize);
  
  Mat hierarchy = new Mat();
  contours.clear();
  int mode = Imgproc.RETR_LIST;
  int method = Imgproc.CHAIN_APPROX_SIMPLE;
  Imgproc.findContours(output, contours, hierarchy, mode, method);
  
  
  ArrayList<MatOfPoint> filterContoursContours = contours;
  
  double filterContoursMinArea = 0.0;
  double filterContoursMinPerimeter = 100.0;
  double filterContoursMinWidth = 200.0;
  double filterContoursMaxWidth = 1000.0;
  double filterContoursMinHeight = 0.0;
  double filterContoursMaxHeight = 1000.0;
  double[] filterContoursSolidity = {0, 100};
  double filterContoursMaxVertices = 1000000.0;
  double filterContoursMinVertices = 0.0;
  double filterContoursMinRatio = 0.0;
  double filterContoursMaxRatio = 1000.0;
  
  
  filterContours(filterContoursContours, filterContoursMinArea, filterContoursMinPerimeter, filterContoursMinWidth, filterContoursMaxWidth, filterContoursMinHeight, filterContoursMaxHeight, filterContoursSolidity, filterContoursMaxVertices, filterContoursMinVertices, filterContoursMinRatio, filterContoursMaxRatio, filterContoursOutput);
  
  ArrayList<MatOfPoint> convexHullsContours = filterContoursOutput;
  convexHulls(convexHullsContours, convexHullsOutput);
  
  
  
  
  opencv.setGray(output);
  
}



void filterContours(ArrayList<MatOfPoint> inputContours, double minArea,
  double minPerimeter, double minWidth, double maxWidth, double minHeight, double
  maxHeight, double[] solidity, double maxVertexCount, double minVertexCount, double
  minRatio, double maxRatio, ArrayList<MatOfPoint> output) {
  final MatOfInt hull = new MatOfInt();
  output.clear();
  //operation
  for (int i = 0; i < inputContours.size(); i++) {
    final MatOfPoint contour = inputContours.get(i);
    final Rect bb = Imgproc.boundingRect(contour);
    if (bb.width < minWidth || bb.width > maxWidth) continue;
    if (bb.height < minHeight || bb.height > maxHeight) continue;
    final double area = Imgproc.contourArea(contour);
    if (area < minArea) continue;
    if (Imgproc.arcLength(new MatOfPoint2f(contour.toArray()), true) < minPerimeter) continue;
    Imgproc.convexHull(contour, hull);
    MatOfPoint mopHull = new MatOfPoint();
    mopHull.create((int) hull.size().height, 1, CvType.CV_32SC2);
    for (int j = 0; j < hull.size().height; j++) {
      int index = (int)hull.get(j, 0)[0];
      double[] point = new double[] { contour.get(index, 0)[0], contour.get(index, 0)[1]};
      mopHull.put(j, 0, point);
    }
    final double solid = 100 * area / Imgproc.contourArea(mopHull);
    if (solid < solidity[0] || solid > solidity[1]) continue;
    if (contour.rows() < minVertexCount || contour.rows() > maxVertexCount)  continue;
    final double ratio = bb.width / (double)bb.height;
    if (ratio < minRatio || ratio > maxRatio) continue;
    output.add(contour);
  }
}

void convexHulls(ArrayList<MatOfPoint> inputContours, ArrayList<MatOfPoint> outputContours) {
  final MatOfInt hull = new MatOfInt();
  outputContours.clear();
  for (int i = 0; i < inputContours.size(); i++) {
    final MatOfPoint contour = inputContours.get(i);
    final MatOfPoint mopHull = new MatOfPoint();
    Imgproc.convexHull(contour, hull);
    mopHull.create((int) hull.size().height, 1, CvType.CV_32SC2);
    for (int j = 0; j < hull.size().height; j++) {
      int index = (int) hull.get(j, 0)[0];
      double[] point = new double[] {contour.get(index, 0)[0], contour.get(index, 0)[1]};
      mopHull.put(j, 0, point);
    }
    outputContours.add(mopHull);
  }
}