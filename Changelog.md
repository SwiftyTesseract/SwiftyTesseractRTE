#### 1.0.4 - May 5, 2018
* Internal `ImageProcessor` struct was redrawing the captured image at a much lower size which was causing image degradation. Instead of redrawing the image at the scale of `regionOfInterest`, `regionOfInterest` is now scaled to the size of the image.

#### 1.0.3 - April 20, 2018
* Fixed a bug where SwiftyTesseractRTE was evalutating the previous frames' OCR results. When the frames all matched, the result returned was not among the evaluated results that may have not had the level of accuracy defined.

* Cleaned up non-user facing code for better maintainability and clarity at internal callsites.

#### 1.0.2 - April 4, 2018
* Documentation fix

#### 1.0.1 - March 31, 2018
* Added Travis support