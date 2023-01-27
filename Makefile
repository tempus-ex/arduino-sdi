software/Sketch/app.h software/Sketch/signature.h: Makefile scripts/make_composite_binary.go firmware/projects/MKRVIDOR4000/output_files/MKRVIDOR4000.ttf
	go run scripts/make_composite_binary.go -i 'firmware/projects/MKRVIDOR4000/output_files/MKRVIDOR4000.ttf:1:512' -o 'software/Sketch/app.h' -t 1 > 'software/Sketch/signature.h'
