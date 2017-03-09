####################################################################################
####### Object:  core buffer periphery
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2017/02/13                                          
####################################################################################

start <- Sys.time()

setwd("bgd_core_buffer_periphery/")

#im_input   <- "forest.tif"
#im_input   <- "loss.tif"

im_input   <- "gain.tif"

workdir    <-  paste0(substr(im_input,1,nchar(im_input)-4),"_core_buffer/")

dir.create(workdir)

class <- 1
size  <- 1

################################################################################
## Extract binary product
################################################################################
system(sprintf("gdal_calc.py -A %s --outfile=%s --calc=\"%s\"",
               im_input,
               paste0(workdir,"tmp_binary_class_",class,".tif"),
               paste0("A==",class))
)

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(workdir,"tmp_binary_class_",class,".tif"),
               paste0(workdir,"binary_class_",class,".tif")
))

################################################################################
## Dilate Binary
################################################################################
system(sprintf("otbcli_BinaryMorphologicalOperation -in %s -out %s -structype.ball.xradius %s -structype.ball.yradius %s -filter %s",
               paste0(workdir,"binary_class_",class,".tif"),
               paste0(workdir,"tmp_dilate_class_",class,".tif"),
               size,
               size,
               "dilate"
))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(workdir,"tmp_dilate_class_",class,".tif"),
               paste0(workdir,"dilate_class_",class,".tif")
))

################################################################################
## Erode Binary
################################################################################
system(sprintf("otbcli_BinaryMorphologicalOperation -in %s -out %s -structype.ball.xradius %s -structype.ball.yradius %s -filter %s",
               paste0(workdir,"binary_class_",class,".tif"),
               paste0(workdir,"tmp_erode_class_",class,".tif"),
               size,
               size,
               "erode"
))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(workdir,"tmp_erode_class_",class,".tif"),
               paste0(workdir,"erode_class_",class,".tif")
))

################################################################################
## Combine three masks 1:Class Core, 2:Class Periphery, 3:Class Buffer, 4:NonClass Core
################################################################################
system(sprintf("gdal_calc.py -A %s -B %s -C %s --outfile=%s --calc=\"%s\"",
               paste0(workdir,"binary_class_",class,".tif"),
               paste0(workdir,"dilate_class_",class,".tif"),
               paste0(workdir,"erode_class_",class,".tif"),
               paste0(workdir,"tmp_core_buffer_class_",class,".tif"),
               paste0("(B==0)*4+((B-A)==1)*3+((A-C)==1)*2+(C==1)")
))

system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(workdir,"tmp_core_buffer_class_",class,".tif"),
               paste0(workdir,"core_buffer_class_",class,".tif")
))


system(sprintf(paste0("rm ",workdir,"/","tmp*.tif")))




(time <- Sys.time() - start)


