(print "Script loading started")

(define (script-fu-cleanup-signature infile outfile)
  (print (string-append "Function called with infile: " infile " and outfile: " outfile))
  (let* (
    (image (car (gimp-file-load RUN-NONINTERACTIVE infile infile)))
    (drawable (car (gimp-image-get-active-layer image)))
    )
    (print "Image loaded")
    ; Add alpha channel if necessary
    (if (= (car (gimp-drawable-has-alpha drawable)) FALSE)
        (gimp-layer-add-alpha drawable)
    )
    (print "Alpha channel added if necessary")
    
    ; Convert to grayscale
    (gimp-image-convert-grayscale image)
    
    ; Adjust levels to increase contrast
    (gimp-levels drawable HISTOGRAM-VALUE 80 220 1.0 0 255)
    
    ; Use threshold to separate signature from background
    (gimp-threshold drawable 100 255)
    
    ; Remove small artifacts (slightly increased radius)
    (plug-in-despeckle RUN-NONINTERACTIVE image drawable 3 2 1 245)
    
    ; Slightly blur the image to smooth edges
    (plug-in-gauss RUN-NONINTERACTIVE image drawable 0.5 0.5 1)
    
    ; Invert the image
    (gimp-invert drawable)
    
    ; Color to alpha (black to transparent)
    (plug-in-colortoalpha RUN-NONINTERACTIVE image drawable '(0 0 0))
    
    ; Invert back
    (gimp-invert drawable)
    
    (print "Background removed")
    
    ; Save the image
    (file-png-save RUN-NONINTERACTIVE image drawable outfile outfile 0 9 0 0 0 0 0)
    (print "Image saved")
    (gimp-image-delete image)
    (print "Image deleted from memory")
  )
)

(print "Function defined")

(script-fu-register
 "script-fu-cleanup-signature"
 "Cleanup Signature"
 "Clean up a signature image by converting background to transparency."
 "Your Name"
 "Your Name"
 "2023"
 ""
 SF-STRING "Input File" ""
 SF-STRING "Output File" ""
)

(print "Function registered")

(print "Script loading completed")
