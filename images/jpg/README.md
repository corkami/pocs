# JPEG PoCs
- `small.jpg` smallest valid JPG (no Application chunk)
 - `small-invalid.jpg` same file w/o End of Image (invalid structure).
- `20scans.jpg`: a JPEG made of 20 scans with JPEGTran to keep all scans under 64Kb (size = 847kb, 1944x2508px, q=100%) ([original PNG for reference](20scans_std.png)).
 - scan definitions:
  ```
  0: 0-0, 0, 0;
  0: 1-1, 0, 0;
  0: 2-6, 0, 0;
  0: 7-10, 0, 0;
  0: 11-13, 0, 0;
  0: 14-20, 0, 0;
  0: 21-26, 0, 0;
  0: 27-32, 0, 0;
  0: 33-40, 0, 0;
  0: 41-48, 0, 0;
  0: 49-54, 0, 0;
  0: 55-63, 0, 0;
  # blue
  1: 0-0, 0, 0;
  1: 1-16, 0, 0;
  1: 17-32, 0, 0;
  1: 33-63, 0, 0;
  # red
  2: 0-0, 0, 0;
  2: 1-16, 0, 0;
  2: 17-32, 0, 0;
  2: 33-63, 0, 0;
  ```
- `lossless.jpg`: a JPEG abused to store data losslessly (grayscale, 100%, with data padded and replicated 8 times).
 - `lossless.pdf`: a PDF making use of that JPEG (non-browser compatible), referencing the image as (losslessly-stored) page content and as image.
